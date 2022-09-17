import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';

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

  void removeConversationMessage(String id) {
    bool didBreak = false;
    for (Conversation c in _conversations) {
      for (Message m in c.messages) {
        if (m.id == id) {
          _conversations.elementAt(_conversations.indexOf(c)).messages.removeWhere((e) => e.id == id);
          didBreak = true;
          break;
        }
      }
      if (didBreak) {
        break;
      }
    }
    notifyListeners();
  }

  void addTempMessages(List<Message> ms) {
    final Conversation c =
        _conversations.firstWhere((c) => c.user.id == ms.first.to);
    for (final Message m in ms) {
      c.messages.insert(0, m);
    }
    notifyListeners();
  }

  void removeTempMessage({required String uId, required String mId}) {
    _conversations
        .firstWhere((c) => c.user.id == uId)
        .messages
        .removeWhere((e) => e.id == mId);
    notifyListeners();
  }

  void updateTempMessageState(
      {required String uId, required String mId, required String nT}) {
    _conversations
        .firstWhere((c) => c.user.id == uId)
        .messages
        .firstWhere((e) => e.id == mId)
        .updateTypeState(nT);
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
