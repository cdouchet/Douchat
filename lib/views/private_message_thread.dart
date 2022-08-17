import 'dart:async';

import 'package:douchat3/componants/home/douchat_drawer.dart';
import 'package:douchat3/componants/message_thread/receiver_message.dart';
import 'package:douchat3/componants/message_thread/sender_message.dart';
import 'package:douchat3/componants/shared/header_status.dart';
import 'package:douchat3/models/conversation_typing_event.dart';
import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/services/messages/message_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PrivateMessageThread extends StatefulWidget {
  final UserService userService;
  final User user;
  final MessageService messageService;

  String get routeName => 'private_thread';

  const PrivateMessageThread(
      {Key? key,
      required this.user,
      required this.userService,
      required this.messageService})
      : super(key: key);

  @override
  State<PrivateMessageThread> createState() => _PrivateMessageThreadState();
}

class _PrivateMessageThreadState extends State<PrivateMessageThread> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _startTypingTimer;
  Timer? _stopTypingTimer;

  @override
  void initState() {
    super.initState();
    Provider.of<RouteProvider>(context, listen: false)
        .changeRoute('private_thread');
  }

  @override
  Widget build(BuildContext context) {
    print(ModalRoute.of(context)!.settings.name);
    final clientProvider = Provider.of<ClientProvider>(context, listen: true);
    // final messageList = Provider.of<MessageProvider>(context, listen: true)
    //     .getConversationMessages(
    //         userId: widget.user.id, clientId: clientProvider.client.id);
    final messageList = Provider.of<ConversationProvider>(context, listen: true)
        .getConversation(widget.user)
        .messages
        .toList();

    return Scaffold(
        resizeToAvoidBottomInset: true,
        drawer: DouchatDrawer(userService: widget.userService),
        appBar: AppBar(
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: HeaderStatus(
                    username: widget.user.username,
                    online: widget.user.online,
                    typing: null,
                    photoUrl: widget.user.photoUrl)
                .applyPadding(const EdgeInsets.all(12))),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(children: [
              Flexible(
                  flex: 6,
                  child: _buildListOfMessages(
                      context: context,
                      messageList: messageList,
                      client: clientProvider.client)),
              Expanded(
                  child: Container(
                      height: 100,
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
                                Expanded(child: _buildMessageInput(context)),
                                Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: SizedBox(
                                        height: 45,
                                        width: 45,
                                        child: RawMaterialButton(
                                            fillColor: primary,
                                            shape: const CircleBorder(),
                                            elevation: 5,
                                            child: const Icon(Icons.send),
                                            onPressed: () => _sendMessage(
                                                client: clientProvider.client,
                                                context: context))))
                              ]))))
            ])));
  }

  Widget _buildListOfMessages(
          {required BuildContext context,
          required List<Message> messageList,
          required User client}) =>
      ListView.builder(
        reverse: true,
        padding: const EdgeInsets.only(top: 16, left: 20, bottom: 20),
        itemBuilder: (__, index) {
          if (messageList[index].from == widget.user.id) {
            _sendReceipt(messageList[index]);
            return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReceiverMessage(
                    message: messageList[index],
                    photoUrl: widget.user.photoUrl));
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

  _buildMessageInput(BuildContext context) {
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
          _dispatchTyping(TypingType.stop,
              Provider.of<ClientProvider>(context, listen: false).client.id);
        },
        child: TextFormField(
            controller: _textEditingController,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            style: Theme.of(context).textTheme.caption,
            cursorColor: primary,
            onChanged: (str) => _sendTypingNotification(str,
                Provider.of<ClientProvider>(context, listen: false).client.id),
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                enabledBorder: border,
                filled: true,
                fillColor: bubbleDark,
                focusedBorder: border)));
  }

  _sendMessage({required User client, required BuildContext context}) {
    if (_textEditingController.text.trim().isEmpty) return;
    final message = {};
    widget.messageService.sendMessage({
      'from': client.toJson(),
      'to': widget.user.toJson(),
      'content': _textEditingController.text,
      'type': 'text',
      'timestamp': DateFormat().format(DateTime.now())
    });
    _textEditingController.clear();
    _startTypingTimer?.cancel();
    _stopTypingTimer?.cancel();
    _dispatchTyping(TypingType.stop, client.id);
  }

  void _dispatchTyping(TypingType event, String clientId) {
    widget.messageService.sendTypingEvent({
      'from': clientId,
      'to': widget.user.id,
      'event': event.value(),
    });
  }

  void _sendTypingNotification(String text, String clientId) {
    if (text.trim().isEmpty) return;
    if (_startTypingTimer?.isActive ?? false) return;
    if (_stopTypingTimer?.isActive ?? false) _stopTypingTimer?.cancel();
    _dispatchTyping(TypingType.start, clientId);
    _startTypingTimer = Timer(const Duration(seconds: 5), () {});
    _stopTypingTimer = Timer(const Duration(seconds: 6),
        () => _dispatchTyping(TypingType.stop, clientId));
  }

  _sendReceipt(Message message) {}
}
