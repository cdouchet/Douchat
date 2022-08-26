import 'package:douchat3/models/conversations/message.dart';

import 'package:flutter/widgets.dart';

class MessageProvider extends ChangeNotifier {
  late List<Message> _messages;
  List<Message> get messages => _messages;

  void setMessages(List<Message> newMessages) {
    _messages = newMessages;
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  List<Message> getConversationMessages(
      {required String userId, required String clientId}) {
    return _messages
        .where((m) =>
            (m.from == userId && m.to == clientId) ||
            (m.from == clientId && m.to == userId))
        .toList();
  }
}
