import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ConnectedUsers extends StatelessWidget {
  final List<User> users;
  const ConnectedUsers({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<User> onlineUsers =
        users.where((u) => u.online == true).toList();
    final List<User> offlineUsers =
        users.where((u) => u.online == false).toList();
    return Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('Online'),
            Expanded(
              child: ListView.builder(
                  itemCount: onlineUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final u = onlineUsers[index];
                    return _buildListTile(
                        online: true,
                        username: u.username,
                        photoUrl: u.photoUrl);
                  }),
            ),
            const Text('Offline'),
            Expanded(
              child: ListView.builder(
                  itemCount: offlineUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final u = offlineUsers[index];
                    return _buildListTile(
                        online: false,
                        username: u.username,
                        photoUrl: u.photoUrl);
                  }),
            )
          ],
        ));
  }

  ListTile _buildListTile(
          {required bool online,
          required String username,
          required String photoUrl}) =>
      ListTile(
          leading: ProfileImage(online: online, photoUrl: photoUrl),
          title: Text(username));
}
