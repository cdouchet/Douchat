import 'package:douchat3/componants/shared/header_status.dart';
import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/services/message/message_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final MessageService messageService;

  const Home({Key? key, required this.messageService}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    widget.messageService.messages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: HeaderStatus(
                username: Provider.of<ClientProvider>(context, listen: true)
                    .client
                    .username,
                online: true,
                typing: null),
            bottom: TabBar(
                indicatorPadding: const EdgeInsets.symmetric(vertical: 10),
                tabs: [
                  Tab(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text('Messages')))),
                  Tab(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text("Online (number)"))))
                ])),
        backgroundColor: background,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
            onPressed: () =>
                widget.messageService.testMessage("OH BOI DOES IT WORKS ?????"),
            backgroundColor: primary,
            child: const Icon(Icons.group_add, color: Colors.white)),
        body: SafeArea(child: Column(children: [])),
      ),
    );
  }
}
