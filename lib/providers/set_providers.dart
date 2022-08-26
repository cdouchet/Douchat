import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/message_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> setProviders(BuildContext context,
    {required User user,
    required List<User> users,
    required List<Message> messages,
    required List<Conversation> conversations,
    required List<Group> groups}) async {
  Provider.of<ClientProvider>(context, listen: false).setClient(user);
  Provider.of<UserProvider>(context, listen: false).setUsers(users);
  Provider.of<MessageProvider>(context, listen: false).setMessages(messages);
  Provider.of<ConversationProvider>(context, listen: false)
      .setConversations(conversations);
  Provider.of<GroupProvider>(context, listen: false).setGroups(groups);
}
