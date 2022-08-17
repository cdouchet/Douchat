import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/models/conversation.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/routes/router.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationsAndGroups extends StatefulWidget {
  const ConversationsAndGroups({Key? key}) : super(key: key);

  @override
  State<ConversationsAndGroups> createState() => _ConversationsAndGroupsState();
}

class _ConversationsAndGroupsState extends State<ConversationsAndGroups> {
  @override
  Widget build(BuildContext context) {
    // print('USERS : ${Provider.of<UserProvider>(context, listen: false).users}');
    // List<User> usersConversations =
    //     Provider.of<MessageProvider>(context, listen: true)
    //         .messages
    //         .map((e) => Provider.of<UserProvider>(context, listen: false)
    //             .users
    //             .firstWhere((u) => u.id == e.from,
    //                 orElse: () => User(
    //                     id: 'id',
    //                     username: 'username',
    //                     photoUrl: 'photoUrl',
    //                     online: true)))
    //         .toList();
    // if (usersConversations.isEmpty) {
    //   usersConversations = [];
    // }
    List<Conversation> convs =
        Provider.of<ConversationProvider>(context, listen: true)
            .conversations
            .where((c) => c.messages.isNotEmpty)
            .toList();
    Utils.logger.i(convs);
    convs.sort((a, b) =>
        b.messages.first.timeStamp.compareTo(a.messages.first.timeStamp));
    return Container(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: convs.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (convs[index].messages.isEmpty) {
                      return Container();
                    }
                    return _buildConversation(user: convs[index].user);
                  }))
        ]));
  }

  Widget _buildConversation({required User user}) {
    final lastMessage = Provider.of<ConversationProvider>(context, listen: true)
        .conversations
        .firstWhere((c) => c.user.id == user.id)
        .messages
        .first;
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, privateThread,
              arguments: {'user': user});
          // Navigator.push(context, MaterialPageRoute(builder: (_) {
          //   return CompositionRoot.composePrivateMessageThread(user: user);
          // }));
        },
        child: ListTile(
            leading: ProfileImage(
                online: Provider.of<UserProvider>(context, listen: true)
                    .users
                    .firstWhere((u) => u == user)
                    .online,
                photoUrl: Provider.of<UserProvider>(context, listen: true)
                    .users
                    .firstWhere((u) => u == user)
                    .photoUrl),
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.username),
              Text(
                  (Provider.of<ClientProvider>(context, listen: true)
                                  .client
                                  .id ==
                              lastMessage.from
                          ? 'Vous: '
                          : '') +
                      lastMessage.content,
                  style: Theme.of(context).textTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)
            ])));
  }
}
