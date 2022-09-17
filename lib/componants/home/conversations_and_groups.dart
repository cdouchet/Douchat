import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
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
    List<Group> groups =
        Provider.of<GroupProvider>(context, listen: true).groups.toList();
    List<dynamic> all = [];
    all.addAll(convs);
    all.addAll(groups);
    Utils.logger.i(groups);
    return Container(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: all.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_isGroup(all[index])) {
                      return _buildGroup(id: all[index].id);
                    }
                    if (all[index].messages.isEmpty) {
                      return Container();
                    }
                    return _buildConversation(userId: all[index].user.id);
                  }))
        ]));
  }

  Widget _buildGroup({required String id}) {
    final Group group = Provider.of<GroupProvider>(context, listen: true)
        .groups
        .firstWhere((g) => g.id == id);
    final List<GroupMessage> msgs =
        group.messages.where((m) => !m.type.startsWith('temp')).toList();
    GroupMessage? lastMessage;
    User? lastUser;
    if (msgs.isNotEmpty) {
      lastMessage = msgs.first;
      try {
        List<User> lu = Provider.of<UserProvider>(context, listen: true)
            .users
            .where((u) => u.id == lastMessage!.from)
            .toList();
        if (lu.isNotEmpty) {
          lastUser = lu[0];
        } else {
          lastUser = group.users.firstWhere((u) => u.id == lastMessage!.from);
        }
      } catch (e, s) {
        Utils.logger.i(
            'No user found in componants/home/conversations_and_groups.dart',
            e,
            s);
      }
    }
    final String clientId =
        Provider.of<ClientProvider>(context, listen: true).client.id;
    final hasUnread =
        msgs.any((m) => !m.readBy.contains(clientId) && m.from != clientId);
    final lastMessageIsClient =
        Provider.of<ClientProvider>(context, listen: true).client.id ==
            (lastMessage != null ? lastMessage.from : '');
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, groupThread, arguments: {'id': id});
        },
        child: ListTile(
          leading: ProfileImage(
              online: Provider.of<UserProvider>(context, listen: true)
                  .users
                  .where((u) => group.users.contains(u.id))
                  .any((u) => u.online),
              photoUrl: group.photoUrl, isGroup: true),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name),
              if (lastMessage != null)
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
                                : lastUser!.username + ' a envoyé ') +
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
            ],
          ),
          trailing: hasUnread
              ? DecoratedBox(
                  decoration: BoxDecoration(
                      color: primary, borderRadius: BorderRadius.circular(60)),
                  child: Text(
                          msgs
                              .where((m) =>
                                  !m.readBy.contains(clientId) &&
                                  m.from != clientId)
                              .length
                              .toString(),
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontSize: 10))
                      .applyPadding(const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2)))
              : null,
        ));
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

  _isGroup(Object test) {
    if (test is Group) {
      return true;
    }
    return false;
  }
}
