import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/routes/router.dart';
import 'package:flutter/material.dart';

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
            const Text('En ligne'),
            Expanded(
              child: ListView.builder(
                  itemCount: onlineUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final u = onlineUsers[index];
                    return _buildListTile(
                        online: true, user: u, context: context);
                  }),
            ),
            const Text('Hors ligne'),
            Expanded(
              child: ListView.builder(
                  itemCount: offlineUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final u = offlineUsers[index];
                    return _buildListTile(
                        online: false, user: u, context: context);
                  }),
            )
          ],
        ));
  }

  Widget _buildListTile(
          {required User user,
          required bool online,
          required BuildContext context}) =>
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, privateThread,
              arguments: {'user': user});
          // Navigator.push(context, MaterialPageRoute(builder: (_) {
          //   // bool conversationExists = false;
          //   // final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
          //   // for (final Conversation conversation
          //   //     in conversationProvider
          //   //         .conversations) {
          //   //   if (conversation.user.id == user.id) {
          //   //     conversationExists = true;
          //   //     break;
          //   //   }
          //   // }
          //   // if (!conversationExists) {
          //   //   conversationProvider.addConversation(Conversation(id: id, user: user, messages: messages))
          //   // }
          //   return CompositionRoot.composePrivateMessageThread(user: user);
          // }));
        },
        child: ListTile(
            leading: ProfileImage(online: online, photoUrl: user.photoUrl),
            title: Text(user.username)),
      );
}
