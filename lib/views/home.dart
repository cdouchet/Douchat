import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/home/connected_users.dart';
import 'package:douchat3/componants/home/conversations_and_groups.dart';
import 'package:douchat3/componants/home/create_group.dart';
import 'package:douchat3/componants/home/douchat_drawer.dart';
import 'package:douchat3/componants/shared/header_status.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/set_providers.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/services/listeners/listener_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  String get routeName => 'home';

  const Home(
      {Key? key,
      required this.messageService,
      required this.userService,
      required this.client,
      required this.users,
      required this.messages,
      required this.conversations,
      required this.groups})
      : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  List<Message> messages = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("CHANGING APP LIFE CYCLE");
    print(state.toString());
    if (state == AppLifecycleState.resumed) {
      notificationsPlugin.cancelAll();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    _initialSetup();
    widget.messageService.messages();
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
            actions: <Widget>[Container()],
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
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text('Conversations')))),
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
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  builder: (BuildContext context) {
                    return CreateGroup();
                  }).then((i) {
                if (i != null) {
                  final cid =
                      Provider.of<ClientProvider>(context, listen: false)
                          .client;
                  showLoadingDialog(tapDismiss: false);
                  List<String> users = i['users'];
                  users.add(cid.id);
                  Api.createGroup(
                          groupName: i['title'], users: users, creator: cid.id)
                      .then((res) {
                    if (res.statusCode != 200) {
                      Fluttertoast.showToast(
                          msg: 'Erreur durant la création du groupe',
                          gravity: ToastGravity.BOTTOM);
                    } else {
                      final d = jsonDecode(res.body);
                      if (d['payload']['new_group'] != null) {
                        Provider.of<GroupProvider>(context, listen: false)
                            .addGroup(
                                Group.fromJson(d['payload']['new_group']));
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
            },
            backgroundColor: primary,
            child: const Icon(Icons.group_add, color: Colors.white)),
        body: TabBarView(children: [
          const ConversationsAndGroups(),
          ConnectedUsers(
              users: Provider.of<UserProvider>(context, listen: true).users)
        ]),
      ),
    );
  }

  void _initialSetup() {
    Provider.of<AppLifeCycleProvider>(context, listen: false)
        .setAppState(AppLifecycleState.resumed);
    setProviders(globalKey.currentContext!,
            user: widget.client,
            users: widget.users,
            messages: widget.messages,
            conversations: widget.conversations,
            groups: widget.groups)
        .then((_) {
      widget.messageService.startReceivingEvents(globalKey.currentContext!);
      print('after setting listeners');
    });
  }
}
