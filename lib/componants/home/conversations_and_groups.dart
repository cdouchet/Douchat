import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/routes/router.dart';
import 'package:douchat3/themes/colors.dart';
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
    List<Group> groups = Provider.of<GroupProvider>(context, listen: true)
        .groups
        .where((g) => g.messages.isNotEmpty)
        .toList();
    List<dynamic> all = convs + groups;
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
                    return _buildConversation(userId: convs[index].user.id);
                  }))
        ]));
  }

  Widget _buildConversation({required String userId}) {
    final user = Provider.of<UserProvider>(context, listen: true)
        .users
        .firstWhere((u) => u.id == userId);
    final msgs = Provider.of<ConversationProvider>(context, listen: true)
        .conversations
        .firstWhere((c) => c.user.id == user.id)
        .messages
        .where((m) => !m.type.startsWith('temp'));
    final lastMessage = msgs.first;
    final hasUnread = msgs.any((m) =>
        m.read == false &&
        m.from != Provider.of<ClientProvider>(context, listen: true).client.id);
    final lastMessageIsClient =
        Provider.of<ClientProvider>(context, listen: true).client.id ==
            lastMessage.from;
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
                  lastMessage.type == 'text'
                      ? (Provider.of<ClientProvider>(context, listen: true)
                                      .client
                                      .id ==
                                  lastMessage.from
                              ? 'Vous: '
                              : '') +
                          lastMessage.content
                      : (lastMessageIsClient
                              ? 'Vous avez envoyé '
                              : Provider.of<UserProvider>(context, listen: true)
                                      .users
                                      .firstWhere((u) => u.id == user.id)
                                      .username +
                                  ' a envoyé ') +
                          (lastMessage.type == 'image'
                              ? 'une image.'
                              : lastMessage.type == 'video'
                                  ? 'une vidéo.'
                                  : 'un gif.'),
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      fontWeight:
                          hasUnread ? FontWeight.bold : FontWeight.normal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)
            ]),
            trailing: hasUnread
                ? DecoratedBox(
                    decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(60)),
                    child: Text(
                            msgs
                                .where((m) => m.read == false)
                                .length
                                .toString(),
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(fontSize: 10))
                        .applyPadding(const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2)))
                : null));
  }
}
