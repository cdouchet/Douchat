import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/home/douchat_drawer.dart';
import 'package:douchat3/componants/message_thread/receiver_message.dart';
import 'package:douchat3/componants/message_thread/sender_message.dart';
import 'package:douchat3/componants/shared/header_status.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/services/messages/message_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PrivateMessageThread extends StatefulWidget {
  final UserService userService;
  final String userId;
  final MessageService messageService;

  String get routeName => 'private_thread';

  const PrivateMessageThread(
      {Key? key,
      required this.userId,
      required this.userService,
      required this.messageService})
      : super(key: key);

  @override
  State<PrivateMessageThread> createState() => _PrivateMessageThreadState();
}

class _PrivateMessageThreadState extends State<PrivateMessageThread>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _startTypingTimer;
  Timer? _stopTypingTimer;

  @override
  void initState() {
    super.initState();
    _initialSetup();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.messageService.cancelSubscriptionToReceipts();
    super.dispose();
  }

  _initialSetup() {
    final conv = Provider.of<ConversationProvider>(context, listen: false)
        .conversations
        .firstWhere((c) => c.user.id == widget.userId);
    if (conv.messages.any((m) => m.read == false)) {
      final messagesToUpdate = conv.messages
          .where((m) => m.from == widget.userId && m.read == false);
      final msgs = messagesToUpdate.map((e) => e.id).toList();
      widget.messageService.sendAllReceipts(
          messages: msgs,
          userId: widget.userId,
          clientId:
              Provider.of<ClientProvider>(context, listen: false).client.id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ConversationProvider>(context, listen: false)
            .updateReadState(msgs, widget.userId, notify: true);
        Provider.of<RouteProvider>(context, listen: false)
            .changePrivateThreadPresence(true);
        Provider.of<RouteProvider>(context, listen: false)
            .changePrivateThreadId(widget.userId);
      });
    }
    widget.messageService.subscribeToReceipts();
  }

  @override
  Widget build(BuildContext context) {
    print(ModalRoute.of(context)!.settings.name);
    final clientProvider = Provider.of<ClientProvider>(context, listen: true);
    // final messageList = Provider.of<MessageProvider>(context, listen: true)
    //     .getConversationMessages(
    //         userId: widget.user.id, clientId: clientProvider.client.id);
    final messageList = Provider.of<ConversationProvider>(context, listen: true)
        .getConversation(widget.userId)
        .messages
        .toList();
    final user = Provider.of<UserProvider>(context, listen: true)
        .users
        .firstWhere((u) => u.id == widget.userId);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<RouteProvider>(context, listen: false)
            .changePrivateThreadPresence(false);
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          drawer: DouchatDrawer(userService: widget.userService),
          appBar: AppBar(
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () => Navigator.pop(context)),
                Expanded(
                  child: HeaderStatus(
                          username: user.username,
                          online: user.online,
                          typing: null,
                          photoUrl: user.photoUrl)
                      .applyPadding(const EdgeInsets.all(12)),
                ),
              ],
            ),
          ),
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
                        user: user)),
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
                                              context: context, user: user)),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12),
                                          child: SizedBox(
                                              height: 45,
                                              width: 45,
                                              child: RawMaterialButton(
                                                  shape: const CircleBorder(),
                                                  elevation: 5,
                                                  child: const Icon(Icons.send,
                                                      color: primary),
                                                  onPressed: () => _sendMessage(
                                                      client:
                                                          clientProvider.client,
                                                      context: context,
                                                      user: user))))
                                    ])
                                  ])),
                            ])))
              ]))),
    );
  }

  Widget _buildListOfMessages(
          {required BuildContext context,
          required List<Message> messageList,
          required User user,
          required User client}) =>
      ListView.builder(
        reverse: true,
        padding: const EdgeInsets.only(top: 16, left: 20, bottom: 20),
        itemBuilder: (__, index) {
          if (messageList[index].from == widget.userId) {
            _sendReceipt(messageList[index]);
            return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReceiverMessage(
                    message: messageList[index], photoUrl: user.photoUrl));
          } else {
            return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SenderMessage(message: messageList[index]));
          }
        },
        itemCount: messageList.length,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        addAutomaticKeepAlives: true,
      );

  _buildMessageInput({required BuildContext context, required User user}) {
    final border = OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(90)),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)));
    return Focus(
        onFocusChange: (focus) {
          if (_startTypingTimer == null ||
              (_startTypingTimer != null && focus)) {
            return;
          }
          _stopTypingTimer?.cancel();
          // _dispatchTyping(TypingType.stop,
          //     Provider.of<ClientProvider>(context, listen: false).client.id);
        },
        child: Padding(
          padding:
              // EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              EdgeInsets.only(bottom: 0),
          child: TextFormField(
              controller: _textEditingController,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: Theme.of(context).textTheme.caption,
              cursorColor: primary,
              cursorHeight: 18,
              textCapitalization: TextCapitalization.sentences,
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
                          user: user)),
                  contentPadding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  enabledBorder: border,
                  filled: true,
                  fillColor: bubbleDark,
                  focusedBorder: border)),
        ));
  }

  _handleMedia(
      {required BuildContext context,
      required User client,
      required User user}) async {
    final res = await Utils.showMediaPickFile(context);
    if (res != null) {
      if (res['type'] == "photo_taken") {
        final dynamic file = res['file'];
        final int r = Random().nextInt(5000);
        Provider.of<ConversationProvider>(context, listen: false)
            .addTempMessages([
          Message(
              id: 'temp$r',
              content: "${file.path}",
              from: client.id,
              to: widget.userId,
              type: 'temp_loading_image',
              timeStamp: DateTime.now(),
              read: false,
              reactions: [])
        ]);
        Api.uploadFile(file: kIsWeb ? file : File(file.path), type: "image", thread: "conv")
            .then((path) {
          if (path != null) {
            widget.messageService.sendMessage({
              'from': client.toJson(),
              'to': user.toJson(),
              'content': path,
              'type': 'image',
              'timestamp': DateFormat().format(DateTime.now()),
              'read': false,
              'reactions': []
            });
            Provider.of<ConversationProvider>(context, listen: false)
                .removeTempMessage(mId: 'temp$r', uId: user.id);
          }
        });
      } else if (res['type'] == 'medias') {
        final List<File> fs = res['medias'];
        List<Message> ms = [];
        for (int i = 0; i < fs.length; i++) {
          ms.add(Message(
              id: 'temp$i',
              content: "${fs[i].path}",
              from: client.id,
              to: widget.userId,
              type:
                  'temp_loading_${Utils.isImage(fs[i].path) ? 'image' : 'video'}',
              timeStamp: DateTime.now(),
              read: false,
              reactions: []));
        }
        Provider.of<ConversationProvider>(context, listen: false)
            .addTempMessages(ms);
        for (int i = 0; i < fs.length; i++) {
          final String type = Utils.isImage(fs[i].path) ? 'image' : 'video';
          Api.uploadFile(file: fs[i], type: type, thread: "conv").then((path) {
            if (path != null) {
              widget.messageService.sendMessage({
                'from': client.toJson(),
                'to': user.toJson(),
                'content': path,
                'type': type,
                'timestamp': DateFormat().format(DateTime.now()),
                'read': false,
                'reactions': []
              });
              Provider.of<ConversationProvider>(context, listen: false)
                  .removeTempMessage(mId: 'temp$i', uId: user.id);
            } else {
              Provider.of<ConversationProvider>(context, listen: false)
                  .updateTempMessageState(
                      uId: user.id, mId: 'temp$i', nT: 'temp_error_$type');
            }
          });
        }
      } else if (res['type'] == 'gif') {
        widget.messageService.sendMessage({
          'from': client.toJson(),
          'to': user.toJson(),
          'content': res['url'],
          'type': 'gif',
          'timestamp': DateFormat().format(DateTime.now()),
          'read': false,
          'reactions': []
        });
      }
    }
  }

  _sendMessage(
      {required User client,
      required BuildContext context,
      required User user}) {
    if (_textEditingController.text.trim().isEmpty) return;
    widget.messageService.sendMessage({
      'from': client.toJson(),
      'to': user.toJson(),
      'content': _textEditingController.text,
      'type': 'text',
      'timestamp': DateFormat().format(DateTime.now()),
      'read': false,
      'reactions': []
    });
    _textEditingController.clear();
    _startTypingTimer?.cancel();
    _stopTypingTimer?.cancel();
    // _dispatchTyping(TypingType.stop, client.id);
  }

  // void _dispatchTyping(TypingType event, String clientId) {
  //   widget.messageService.sendTypingEvent({
  //     'from': clientId,
  //     'to': widget.userId,
  //     'event': event.value(),
  //   });
  // }

  void _sendTypingNotification(String text, String clientId) {
    // if (text.trim().isEmpty) return;
    // if (_startTypingTimer?.isActive ?? false) return;
    // if (_stopTypingTimer?.isActive ?? false) _stopTypingTimer?.cancel();
    // _dispatchTyping(TypingType.start, clientId);
    // _startTypingTimer = Timer(const Duration(seconds: 5), () {});
    // _stopTypingTimer = Timer(const Duration(seconds: 6),
    //     () => _dispatchTyping(TypingType.stop, clientId));
  }

  _sendReceipt(Message message) {}

  @override
  bool get wantKeepAlive => true;
}
