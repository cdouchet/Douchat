import 'package:douchat3/providers/friend_request_provider.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendRequestView extends StatefulWidget {
  final UserService userService;
  const FriendRequestView({super.key, required this.userService});

  @override
  State<FriendRequestView> createState() => _FriendRequestViewState();
}

class _FriendRequestViewState extends State<FriendRequestView> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fRP = Provider.of<FriendRequestProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        // Provider.of<RouteProvider>(context, listen: false)
        //     .changeFriendRequestPresence(false);
        return true;
      },
      child: Scaffold(
          appBar: AppBar(centerTitle: true, title: Text("Requêtes d'amis")),
          body: Container(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: fRP.friendRequests.length,
                        itemBuilder: (BuildContext context, int index) {
                          final fr = fRP.friendRequests[index];
                          return ListTile(
                              leading: Text(fr.fromUsername),
                              title: Padding(
                                padding: const EdgeInsets.only(left: 120),
                                child: IconButton(
                                    onPressed: () => fr.respond(
                                        context: context,
                                        accept: true,
                                        clientId: fr.to,
                                        userId: fr.from,
                                        id: fr.id,
                                        userService: widget.userService),
                                    icon:
                                        Icon(Icons.check, color: Colors.green)),
                              ),
                              trailing: IconButton(
                                  onPressed: () => fr.respond(
                                      context: context,
                                      accept: false,
                                      clientId: fr.to,
                                      userId: fr.from,
                                      id: fr.id,
                                      userService: widget.userService),
                                  icon: Icon(Icons.cancel, color: Colors.red)));
                        }))
              ]))),
    );
  }
}
