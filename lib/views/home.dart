import 'package:douchat3/componants/home/connected_users.dart';
import 'package:douchat3/componants/home/douchat_drawer.dart';
import 'package:douchat3/componants/shared/header_status.dart';
import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/set_providers.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/services/listeners/listener_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final ListenerService messageService;
  final UserService userService;
  final User client;
  final List<User> users;

  const Home(
      {Key? key,
      required this.messageService,
      required this.userService,
      required this.client,
      required this.users})
      : super(key: key);

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

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context, listen: true);
    return DefaultTabController(
      length: 2,
      child: FutureBuilder(
          future: _initialSetup(),
          builder: (BuildContext context, AsyncSnapshot snapshot) => Scaffold(
                key: _key,
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
                        indicatorPadding:
                            const EdgeInsets.symmetric(vertical: 10),
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
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          "Online ${Provider.of<UserProvider>(context, listen: true).users.length}"))))
                        ])),
                backgroundColor: background,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                floatingActionButton: FloatingActionButton(
                    onPressed: () => widget.messageService
                        .testMessage("OH BOI DOES IT WORKS ?????"),
                    backgroundColor: primary,
                    child: const Icon(Icons.group_add, color: Colors.white)),
                body: TabBarView(children: [
                  Container(),
                  ConnectedUsers(
                      users: Provider.of<UserProvider>(context, listen: true)
                          .users)
                ]),
              )),
    );
  }

  Future<void> _initialSetup() async {
    widget.messageService.startReceivingEvents(context);
    await setProviders(context, user: widget.client, users: widget.users);
  }
}
