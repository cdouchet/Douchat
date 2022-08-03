import 'package:flutter/material.dart';

enum ThreadType { private, group }

class MessageThread extends StatefulWidget {
  final ThreadType threadType;
  final int id;
  const MessageThread({Key? key, required this.threadType, required this.id})
      : super(key: key);

  @override
  State<MessageThread> createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Row(children: [])));
  }
}
