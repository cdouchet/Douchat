import 'package:douchat3/models/conversation.dart';
import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/message_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> setProviders(BuildContext context,
    {required User user,
    required List<User> users,
    required List<Message> messages,
    required List<Conversation> conversations}) async {
  Provider.of<ClientProvider>(context, listen: false).setClient(user);
  Provider.of<UserProvider>(context, listen: false).setUsers(users);
  Provider.of<MessageProvider>(context, listen: false).setMessages(messages);
  Provider.of<ConversationProvider>(context, listen: false)
      .setConversations(conversations);
}
