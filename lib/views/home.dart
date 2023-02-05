import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'dart:math' as math;

import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/home/connected_users.dart';
import 'package:douchat3/componants/home/conversations_and_groups.dart';
import 'package:douchat3/componants/home/create_group.dart';
import 'package:douchat3/componants/home/douchat_drawer.dart';
import 'package:douchat3/componants/home/expandable_fab.dart';
import 'package:douchat3/componants/shared/header_status.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/friend_request.dart';
import 'package:douchat3/providers/friend_request_provider.dart';
import 'package:douchat3/routes/router.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/set_providers.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/services/listeners/listener_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:load/load.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final ListenerService messageService;
  final UserService userService;
  final User client;
  final List<User> users;
  final List<Message> messages;
  final List<Conversation> conversations;
  final List<Group> groups;
  final List<FriendRequest> friendRequests;
  final List<Group> newGroups;
  final List<Message> newConversations;

  String get routeName => 'home';

  const Home({
    Key? key,
    required this.messageService,
    required this.userService,
    required this.client,
    required this.users,
    required this.messages,
    required this.conversations,
    required this.groups,
    required this.friendRequests,
    required this.newGroups,
    required this.newConversations,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List<Message> messages = [];
  ReceivePort _port = ReceivePort();
  late AnimationController _bottomIconController;
  late Animation<double> _bottomIconAnimation;
  bool _expanded = false;

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("CHANGING APP LIFE CYCLE");
    print(state.toString());
    if (state == AppLifecycleState.resumed) {
      notificationsPlugin.cancelAll();
    }
    Provider.of<AppLifeCycleProvider>(context, listen: false)
        .setAppState(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    _bottomIconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _bottomIconAnimation = CurvedAnimation(
        parent: _bottomIconController, curve: Curves.fastOutSlowIn);
    _initialSetup();
    WidgetsBinding.instance.addObserver(this);
    widget.messageService.messages();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context, listen: true);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: DouchatDrawer(
          userService: widget.userService,
        ),
        appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () {
                          Navigator.pushNamed(context, friendRequests);
                        }),
                    if (Provider.of<FriendRequestProvider>(context,
                                listen: true)
                            .friendRequests
                            .length >
                        0)
                      Positioned(
                          top: 6,
                          right: 6,
                          child: Text('!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: primary, fontSize: 20)))
                  ],
                ),
              )
            ],
            title: HeaderStatus(
              username: clientProvider.client.username,
              online: true,
              typing: null,
              photoUrl: clientProvider.client.photoUrl,
            ),
            bottom: TabBar(
                indicatorPadding: const EdgeInsets.symmetric(vertical: 10),
                tabs: [
                  Tab(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Builder(builder: (context) {
                                int unreadConv = 0;
                                int unreadGroup = 0;
                                String clientId = Provider.of<ClientProvider>(
                                        context,
                                        listen: false)
                                    .client
                                    .id;
                                for (Conversation c
                                    in Provider.of<ConversationProvider>(
                                            context,
                                            listen: true)
                                        .conversations) {
                                  unreadConv += c.messages
                                      .where((m) => m.to == clientId && !m.read)
                                      .length;
                                }
                                for (Group g in Provider.of<GroupProvider>(
                                        context,
                                        listen: true)
                                    .groups) {
                                  unreadGroup += g.messages
                                      .where((m) =>
                                          m.from != clientId &&
                                          !m.readBy.contains(clientId))
                                      .length;
                                }
                                final int total = unreadConv + unreadGroup;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Conversations'),
                                    total > 0
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(left: 6),
                                            child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60)),
                                                child: Text(total > 99
                                                        ? "99+"
                                                        : total.toString())
                                                    .applyPadding(
                                                        const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 5,
                                                            vertical: 2))),
                                          )
                                        : Container()
                                  ],
                                );
                              })))),
                  Tab(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                  "En ligne ${Provider.of<UserProvider>(context, listen: true).users.where((u) => u.online == true).length}"))))
                ])),
        backgroundColor: background,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: ExpandableFab(
          distance: 120,
          children: [
            ActionButton(
                icon: Icon(Icons.group_add, color: Colors.white),
                onPressed: () => _createGroupModal()),
            ActionButton(
                icon: Icon(Icons.person_add, color: Colors.white),
                onPressed: () => _addPersonRoute())
          ],
        ),
        body: TabBarView(children: [
          const ConversationsAndGroups(),
          ConnectedUsers(
              users: Provider.of<UserProvider>(context, listen: true).users)
        ]),
      ),
    );
  }

  Iterable<Widget> _createActionList() sync* {
    final List<Map<String, dynamic>> infos = [
      {"direction": 45, "icon": Icon(Icons.group_add, color: Colors.white)},
      {"direction": 90, "icon": Icon(Icons.person_add, color: Colors.white)}
    ];
    for (int i = 0; i < 2; i++) {
      yield AnimatedBuilder(
          animation: _bottomIconAnimation,
          builder: (context, child) {
            final offset = Offset.fromDirection(
                infos[i]["direction"] * (math.pi / 180.0),
                _bottomIconAnimation.value * 120);
            return Positioned(
                right: 4.0 + offset.dx,
                bottom: 4.0 + offset.dy,
                child: Transform.rotate(
                    angle: (1.0 - _bottomIconAnimation.value) * math.pi / 2,
                    child: child!));
          },
          child: FadeTransition(
              opacity: _bottomIconAnimation,
              child: RawMaterialButton(
                  shape: CircleBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.all(18),
                  fillColor: primary,
                  onPressed: () {},
                  child: infos[i]["icon"])));
    }
  }

  void _expandActionButton() {
    if (!_expanded) {}
  }

  void _addPersonRoute() {
    Navigator.pushNamed(context, idShare,
        arguments: {'userService': widget.userService});
  }

  void _createGroupModal() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        builder: (BuildContext context) {
          return CreateGroup();
        }).then((i) {
      if (i != null) {
        final cid = Provider.of<ClientProvider>(context, listen: false).client;
        showLoadingDialog(tapDismiss: false);
        List<String> users = i['users'];
        users.add(cid.id);
        Api.createGroup(groupName: i['title'], users: users, creator: cid.id)
            .then((res) {
          if (res.statusCode != 200) {
            Fluttertoast.showToast(
                msg: 'Erreur durant la création du groupe',
                gravity: ToastGravity.BOTTOM);
          } else {
            final d = jsonDecode(res.body);
            if (d['payload']['new_group'] != null) {
              CompositionRoot.groupService.sendNewGroup({
                "group": d['payload']['new_group'],
                "timestamp": DateFormat().format(DateTime.now())
              });
              Fluttertoast.showToast(
                  msg: 'Groupe créé', gravity: ToastGravity.BOTTOM);
            } else {
              Fluttertoast.showToast(
                  msg: 'Erreur durant la création du groupe',
                  gravity: ToastGravity.BOTTOM);
            }
          }
        });
        hideLoadingDialog();
      }
    });
  }

  void _initialSetup() {
    Provider.of<AppLifeCycleProvider>(context, listen: false)
        .setAppState(AppLifecycleState.resumed);
    CompositionRoot.listenerService.setup();
    setProviders(globalKey.currentContext!,
            user: widget.client,
            users: widget.users,
            messages: widget.messages,
            conversations: widget.conversations,
            groups: widget.groups,
            friendRequests: widget.friendRequests)
        .then((_) {
      Utils.manageNewMessages(
          context, widget.newConversations, widget.newGroups);
      widget.messageService.startReceivingEvents(globalKey.currentContext!);
      print('after setting listeners');
    });
  }
}
