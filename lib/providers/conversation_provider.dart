import 'package:douchat3/models/conversation.dart';
import 'package:douchat3/models/message.dart';
import 'package:flutter/widgets.dart';

class ConversationProvider extends ChangeNotifier {
  late List<Conversation> _conversations;
  List<Conversation> get conversations => _conversations;

  void setConversations(List<Conversation> newConversations) {
    _conversations = newConversations;
  }

  Conversation getConversation(String userId) =>
      _conversations.firstWhere((c) => c.user.id == userId);

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

  void updateReadState(List<String> messagesToUpdate, String userId,
      {required bool notify}) {
    final msgs = _conversations.firstWhere((c) => c.user.id == userId).messages;
    for (int i = 0; i < messagesToUpdate.length; i++) {
      msgs
          .firstWhere((m) => m.id == messagesToUpdate[i])
          .updateMessageState(true);
    }
    if (notify) {
      notifyListeners();
    }
  }
}
