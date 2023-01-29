import 'package:douchat3/main.dart';
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

  void removeConversation(String convUserId) {
    _conversations.removeWhere((e) => e.user.id == convUserId);
    notifyListeners();
  }

  void addConversationMessage(Message message) {
    _conversations
        .firstWhere((c) => c.user.id == message.from,
            orElse: () =>
                _conversations.firstWhere((conv) => conv.user.id == message.to))
        .messages
        .insert(0, message);
    db.insertConversationMessage(message);
    notifyListeners();
  }

  bool doConversationMessageExists(String id) {
    return _conversations.any((c) => c.messages.any((m) => m.id == id));
  }

  void updateListConversationMessage(List<Message> msgs) {
    bool didBreak = false;
    List<String> msgsStr = msgs.map((e) => e.id).toList();
    for (int i = 0; i < _conversations.length; i++) {
      if (didBreak) {
        break;
      }
      for (int j = 0; j < _conversations[i].messages.length; j++) {
        if (didBreak) {
          break;
        }
        for (int k = 0; k < msgsStr.length; k++) {
          if (msgsStr.contains(_conversations[i].messages[j].id)) {
            _conversations[i].messages.replaceRange(j, j + 1, [msgs[k]]);
            msgsStr.removeAt(k);
            msgs.removeAt(k);
            db.updateConversationMessage(msgs[k]);
            if (msgsStr.isEmpty) {
              didBreak = true;
              break;
            }
          }
        }
      }
    }
    notifyListeners();
  }

  void updateConversationMessage(Message msg) {
    bool didBreak = false;
    for (int i = 0; i < _conversations.length; i++) {
      for (int j = 0; j < _conversations[i].messages.length; j++) {
        if (_conversations[i].messages[j].id == msg.id) {
          _conversations[i].messages.replaceRange(j, j + 1, [msg]);
          db.updateConversationMessage(msg);
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

  void removeConversationMessage(String id) {
    bool didBreak = false;
    for (Conversation c in _conversations) {
      for (Message m in c.messages) {
        if (m.id == id) {
          _conversations
              .elementAt(_conversations.indexOf(c))
              .messages
              .removeWhere((e) => e.id == id);
          db.deleteConversationMessage(id);
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
      final toUpdate = msgs.firstWhere((m) => m.id == messagesToUpdate[i]);
      toUpdate.updateMessageState(true);
      db.updateConversationMessage(toUpdate);
    }
    if (notify) {
      notifyListeners();
    }
  }

  void addReaction(
      {required String id, required String userId, required String emoji}) {
    bool didBreak = false;
    for (Conversation c in _conversations) {
      for (Message m in c.messages) {
        if (m.id == id) {
          final toUpdate = _conversations
              .elementAt(_conversations.indexOf(c))
              .messages
              .firstWhere((e) => e.id == id);
          toUpdate.addReaction(user: userId, emoji: emoji);
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

  void removeReaction(
      {required String id, required String userId, required String emoji}) {
    bool didBreak = false;
    for (Conversation c in _conversations) {
      for (Message m in c.messages) {
        if (m.id == id) {
          _conversations
              .elementAt(_conversations.indexOf(c))
              .messages
              .firstWhere((e) => e.id == id)
              .removeReaction(user: userId, emoji: emoji);
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
}
