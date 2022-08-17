import 'package:douchat3/models/conversation.dart';
import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';
import 'package:flutter/widgets.dart';

class ConversationProvider extends ChangeNotifier {
  late List<Conversation> _conversations;
  List<Conversation> get conversations => _conversations;

  void setConversations(List<Conversation> newConversations) {
    _conversations = newConversations;
  }

  Conversation getConversation(User user) =>
      _conversations.firstWhere((c) => c.user.id == user.id);

  void addConversation(Conversation conversation) {
    _conversations.add(conversation);
    notifyListeners();
  }

  void addConversationMessage(Message message) {
    _conversations
        .firstWhere((c) => c.user.id == message.from,
            orElse: () =>
                _conversations.firstWhere((conv) => conv.user.id == message.to))
        .messages
        .insert(0, message);
    notifyListeners();
  }
}
