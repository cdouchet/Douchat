import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/group_thread/group_receiver_message.dart';
import 'package:douchat3/componants/group_thread/group_sender_message.dart';
import 'package:douchat3/componants/home/douchat_drawer.dart';
import 'package:douchat3/componants/shared/header_status.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/services/groups/group_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/views/group_settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:douchat3/utils/utils.dart';

class GroupMessageThread extends StatefulWidget {
  final String groupId;
  final UserService userService;
  final GroupService groupService;
  const GroupMessageThread(
      {super.key,
      required this.groupId,
      required this.userService,
      required this.groupService});

  @override
  State<GroupMessageThread> createState() => _GroupMessageThreadState();
}

class _GroupMessageThreadState extends State<GroupMessageThread>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _startTypingTimer;
  Timer? _stopTypingTimer;

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
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
    _initialSetup();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.groupService.cancelSubscriptionToReceipts();
    super.dispose();
  }

  _initialSetup() {
    final group = Provider.of<GroupProvider>(context, listen: false)
        .groups
        .firstWhere((g) => g.id == widget.groupId);
    final String clientId =
        Provider.of<ClientProvider>(context, listen: false).client.id;
    if (group.messages
        .any((m) => m.from != clientId && !m.readBy.contains(clientId))) {
      final Iterable<GroupMessage> messagesToUpdate = group.messages
          .where((m) => m.from != clientId && !m.readBy.contains(clientId));
      final msgs = messagesToUpdate.map((e) => e.id).toList();
      Utils.logger.i("Messages to update: $msgs");
      Utils.logger.i(
          "Does any message have not been read: ${group.messages.any((m) => !m.readBy.contains(clientId))}");
      if (msgs.isNotEmpty) {
        widget.groupService.sendAllReceipts(
            messages: msgs, groupId: widget.groupId, userId: clientId);
      }
      WidgetsBinding.instance.addPostFrameCallback((t) {
        // Provider.of<GroupProvider>(context, listen: false).updateReadState(
        //     messagesToUpdate: msgs,
        //     groupId: widget.groupId,
        //     readBy: clientId,
        //     notify: true);
        Provider.of<RouteProvider>(context, listen: false)
            .changeGroupThreadPresence(true);
        Provider.of<RouteProvider>(context, listen: false)
            .changeGroupThreadId(widget.groupId);
      });
    }
    widget.groupService.subscribeToReceipts();
  }

  @override
  Widget build(BuildContext context) {
    print(ModalRoute.of(context)!.settings.name);
    final Group group = Provider.of<GroupProvider>(context, listen: true)
        .getGroup(widget.groupId);
    Utils.logger.i('group users : ', group.users.map((e) => e.toJson()));
    final ClientProvider clientProvider =
        Provider.of<ClientProvider>(context, listen: true);
    final List<GroupMessage> messageList = group.messages.toList();
    messageList.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    List<User> users = [];
    final List<User> contactUsers =
        Provider.of<UserProvider>(context, listen: true).users;
    final List<String> groupsUsersIds = group.users.map((e) => e.id).toList();
    for (int i = 0; i < contactUsers.length; i++) {
      if (groupsUsersIds.contains(contactUsers[i].id)) {
        users.add(contactUsers[i]);
        groupsUsersIds.remove(contactUsers[i]);
      }
    }
    for (int i = 0; i < groupsUsersIds.length; i++) {
      users.add(group.users.firstWhere((u) => u.id == groupsUsersIds[i]));
    }
    return WillPopScope(
        onWillPop: () async {
          Provider.of<RouteProvider>(context, listen: false)
              .changeGroupThreadPresence(false);
          return true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            drawer: DouchatDrawer(userService: widget.userService),
            appBar: AppBar(
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                    Expanded(
                      child: HeaderStatus(
                        username: group.name,
                        online: users.any((element) => element.online),
                        typing: null,
                        photoUrl: group.photoUrl,
                        isGroup: true,
                      ).applyPadding(const EdgeInsets.all(12)),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => GroupSettings(
                                    groupId: widget.groupId,
                                    groupService: widget.groupService)));
                      })
                ]),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(children: [
                  Flexible(
                      flex: 5,
                      child: _buildListOfMessages(
                          context: context,
                          messageList: messageList,
                          client: clientProvider.client,
                          users: users)),
                  Container(
                      decoration: const BoxDecoration(
                          color: appBarDark,
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, -3),
                                blurRadius: 6.0,
                                color: Colors.black12)
                          ]),
                      alignment: Alignment.topCenter,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Column(children: [
                                      Row(children: [
                                        Expanded(
                                            child: _buildMessageInput(
                                                context: context,
                                                users: users)),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(left: 12),
                                            child: SizedBox(
                                                height: 45,
                                                width: 45,
                                                child: RawMaterialButton(
                                                    shape: const CircleBorder(),
                                                    elevation: 5,
                                                    child: const Icon(
                                                        Icons.send,
                                                        color: primary),
                                                    onPressed: () =>
                                                        _sendMessage(
                                                          client: clientProvider
                                                              .client,
                                                          context: context,
                                                        ))))
                                      ])
                                    ]))
                              ])))
                ]))));
  }

  Widget _buildListOfMessages(
      {required BuildContext context,
      required List<GroupMessage> messageList,
      required List<User> users,
      required User client}) {
    return ListView.builder(
        reverse: true,
        padding: const EdgeInsets.only(top: 16, left: 20, bottom: 20),
        itemCount: messageList.length,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        addAutomaticKeepAlives: true,
        itemBuilder: (__, int index) {
          if (messageList[index].type == 'system') {
            return Center(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(messageList[index].content,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.white.withOpacity(0.3)))),
            );
          }
          if (messageList[index].from == client.id) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GroupSenderMessage(
                    message: messageList[index], isLastMessage: index == 0));
          }
          // Utils.logger.i(messageList[index].toJson());
          // Utils.logger.i(users.map((e) => e.toJson()));
          return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GroupReceiverMessage(
                  message: messageList[index],
                  isLastMessage: index == 0,
                  photoUrl: users
                      .firstWhere((u) => u.id == messageList[index].from)
                      .photoUrl));
        });
  }

  Widget _buildMessageInput(
      {required BuildContext context, required List<User> users}) {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(90)),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)));
    return Focus(
        onFocusChange: (focus) {
          if (_startTypingTimer == null ||
              (_startTypingTimer != null && focus)) {
            return;
          }
          _stopTypingTimer?.cancel();
        },
        child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: TextFormField(
                controller: _textEditingController,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: Theme.of(context).textTheme.caption,
                cursorColor: primary,
                cursorHeight: 18,
                onChanged: (str) => _sendTypingNotification(
                    str,
                    Provider.of<ClientProvider>(context, listen: false)
                        .client
                        .id),
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                        icon: Icon(Icons.add, color: primary),
                        onPressed: () => _handleMedia(
                            context: context,
                            client: Provider.of<ClientProvider>(context,
                                    listen: false)
                                .client,
                            users: users)),
                    contentPadding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    enabledBorder: border,
                    filled: true,
                    fillColor: bubbleDark,
                    focusedBorder: border))));
  }

  Future<void> _handleMedia(
      {required BuildContext context,
      required User client,
      required List<User> users}) async {
    final res = await Utils.showMediaPickFile(context);
    if (res != null) {
      if (res['type'] == "photo_taken") {
        final XFile file = res['file'];
        final int r = Random().nextInt(5000);
        Provider.of<GroupProvider>(context, listen: false).addTempMessages([
          GroupMessage(
              id: 'temp$r',
              content: "${file.path}",
              group: widget.groupId,
              from: client.id,
              type: 'temp_loading_image',
              timeStamp: DateTime.now(),
              readBy: [],
              reactions: [])
        ]);
        Api.uploadFile(file: File(file.path), type: "image", thread: "group")
            .then((path) {
          if (path != null) {
            widget.groupService.sendMessage({
              'content': path,
              'from': client.id,
              'group': widget.groupId,
              'type': 'image',
              'timestamp': DateFormat().format(DateTime.now()),
              'readBy': [],
              'reactions': []
            });
            Provider.of<GroupProvider>(context, listen: false)
                .removeTempMessage(mId: 'temp$r', gId: widget.groupId);
          }
        });
      } else if (res['type'] == 'medias') {
        final List<File> fs = res['medias'];
        List<GroupMessage> ms = [];
        for (int i = 0; i < fs.length; i++) {
          ms.add(GroupMessage(
              id: 'temp$i',
              content: "${fs[i].path}",
              group: widget.groupId,
              from: client.id,
              type:
                  "temp_loading_${Utils.isImage(fs[i].path) ? 'image' : 'video'}",
              timeStamp: DateTime.now(),
              readBy: [],
              reactions: []));
        }
        Provider.of<GroupProvider>(context, listen: false).addTempMessages(ms);
        for (int i = 0; i < fs.length; i++) {
          final String type = Utils.isImage(fs[i].path) ? 'image' : 'video';
          Api.uploadFile(file: fs[i], type: type, thread: "group").then((path) {
            if (path != null) {
              widget.groupService.sendMessage({
                'content': path,
                'from': client.id,
                'group': widget.groupId,
                'type': type,
                'timestamp': DateFormat().format(DateTime.now()),
                'readBy': [],
                'reactions': []
              });
              Provider.of<GroupProvider>(context, listen: false)
                  .removeTempMessage(mId: 'temp$i', gId: widget.groupId);
            } else {
              Provider.of<GroupProvider>(context, listen: false)
                  .updateTempMessageState(
                      gId: widget.groupId,
                      mId: 'temp$i',
                      nT: 'temp_error_$type');
            }
          });
        }
      } else if (res['type'] == 'gif') {
        widget.groupService.sendMessage({
          'from': client.id,
          'group': widget.groupId,
          'content': res['url'],
          'type': 'gif',
          'timestamp': DateFormat().format(DateTime.now()),
          'readBy': [],
          'reactions': []
        });
      }
    }
  }

  void _sendMessage({required User client, required BuildContext context}) {
    if (_textEditingController.text.trim().isEmpty) return;
    widget.groupService.sendMessage({
      'from': client.id,
      'group': widget.groupId,
      'content': _textEditingController.text,
      'type': 'text',
      'timestamp': DateFormat().format(DateTime.now()),
      'readBy': [],
      'reactions': []
    });
    _textEditingController.clear();
    _startTypingTimer?.cancel();
    _stopTypingTimer?.cancel();
  }

  void _sendTypingNotification(String text, String clientId) {
    // if (text.trim().isEmpty) return;
    // if (_startTypingTimer?.isActive ?? false) return;
    // if (_stopTypingTimer?.isActive ?? false) _stopTypingTimer?.cancel();
    // _dispatchTyping(TypingType.start, clientId);
    // _startTypingTimer = Timer(const Duration(seconds: 5), () {});
    // _stopTypingTimer = Timer(const Duration(seconds: 6),
    //     () => _dispatchTyping(TypingType.stop, clientId));
  }

  @override
  bool get wantKeepAlive => true;
}
