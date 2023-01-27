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
import 'package:pull_to_reveal/pull_to_reveal.dart';

class ConversationsAndGroups extends StatefulWidget {
  const ConversationsAndGroups({Key? key}) : super(key: key);

  @override
  State<ConversationsAndGroups> createState() => _ConversationsAndGroupsState();
}

class _ConversationsAndGroupsState extends State<ConversationsAndGroups> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

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

    final bool hasConvOrGroup =
        Provider.of<GroupProvider>(context).groups.isNotEmpty ||
            Provider.of<ConversationProvider>(context).conversations.isNotEmpty;

    Utils.logger.i('Before build');
    List<Conversation> convs =
        Provider.of<ConversationProvider>(context, listen: true)
            .conversations
            .where((c) => c.messages.isNotEmpty)
            .toList();
    convs.sort((a, b) =>
        b.messages.first.timeStamp.compareTo(a.messages.first.timeStamp));
    List<Group> groups =
        Provider.of<GroupProvider>(context, listen: true).groups.toList();
    List<dynamic> all = [];
    all.addAll(convs);
    all.addAll(groups);
    all.sort((a, b) {
      if (a.messages.isNotEmpty && b.messages.isNotEmpty) {
        return b.messages.first.timeStamp.compareTo(a.messages.first.timeStamp);
      }
      return -10000000000000000;
    });
    final String s = searchController.text.trim().toLowerCase();
    all = all.where((e) {
      if (e is Group) {
        return e.name.trim().toLowerCase().contains(s) ||
            e.users.any((e) => e.username.trim().toLowerCase().contains(s));
      } else {
        return (e as Conversation)
            .user
            .username
            .trim()
            .toLowerCase()
            .contains(s);
      }
    }).toList();
    Utils.logger.i('After build');
    return Container(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          hasConvOrGroup
              ? Expanded(
                  child: PullToRevealTopItemList(
                  itemCount: all.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_isGroup(all[index])) {
                      return _buildGroup(id: all[index].id);
                    }
                    if (all[index].messages.isEmpty) {
                      return Container();
                    }
                    return _buildConversation(userId: all[index].user.id);
                  },
                  revealableHeight: 50,
                  revealableBuilder: (BuildContext context,
                      RevealableToggler opener,
                      RevealableToggler closer,
                      BoxConstraints constraints) {
                    return TextFormField(
                        autocorrect: false,
                        controller: searchController,
                        cursorColor: primary,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        minLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (String changes) {
                          setState(() {});
                        },
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(fontSize: 16),
                        decoration: InputDecoration(
                            suffixIcon: searchController.text.isEmpty
                                ? null
                                : GestureDetector(
                                    onTap: () {
                                      searchController.clear();
                                      setState(() {});
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Icon(Icons.close,
                                        color: Colors.white.withOpacity(0.3))),
                            isCollapsed: true,
                            hintText: "Recherche",
                            // contentPadding: const EdgeInsets.all(6),
                            prefixIcon:
                                Icon(Icons.search, size: 18, color: primary),
                            prefixIconColor: primary,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                                gapPadding: 6),
                            fillColor: bubbleDark,
                            filled: true));
                  },
                ))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Aucune conversation. Taper l'icône en bas à gauche pour commencer",
                            textAlign: TextAlign.center,
                          )
                        ]),
                  ),
                ),
          SizedBox(height: 120)
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
      // lastMessage = msgs.first;
      int i = 0;
      while (i < (msgs.length - 1) && msgs[i].type == 'system') {
        i++;
      }
      if (msgs[i].type != 'system') {
        lastMessage = msgs[i];
      }
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
    Utils.logger.i('Group photoUrl : ${group.photoUrl}');
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
              photoUrl: group.photoUrl,
              isGroup: true),
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
        .firstWhere((c) => c.user.id == userId)
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
              Text(Provider.of<UserProvider>(context, listen: true)
                  .users
                  .firstWhere((u) => u.id == userId)
                  .username),
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
                            Provider.of<ConversationProvider>(context,
                                    listen: true)
                                .conversations
                                .firstWhere((c) => c.user.id == user.id)
                                .messages
                                .where((m) => !m.type.startsWith('temp'))
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
