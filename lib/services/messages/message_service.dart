import 'package:douchat3/main.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MessageService {
  final Socket socket;

  MessageService({required this.socket});

  void sendMessage(dynamic data) {
    socket.emit('conversation-message', data);
  }

  void sendTypingEvent(dynamic data) {
    socket.emit('conversation-typing', data);
  }

  void removeMessage(dynamic data) {
    socket.emit('remove-conversation-message', data);
  }

  void sendAllReceipts(
      {required List<String> messages,
      required String userId,
      required String clientId}) {
    socket.emit('conversation-receipts',
        {'messages': messages, 'userId': userId, 'clientId': clientId});
  }

  dynamic updateMessageReceipt(dynamic data) {
    final BuildContext context = globalKey.currentContext!;
    final client = Provider.of<ClientProvider>(context, listen: false).client;
    if (client.id != data['from']) {
      Provider.of<ConversationProvider>(context, listen: false)
          .updateReadState([data['id']], data['from'], notify: true);
      sendAllReceipts(
          messages: [data['id']], userId: data['from'], clientId: client.id);
    }
  }

  void subscribeToReceipts() {
    socket.on('conversation-message', updateMessageReceipt);
  }

  void cancelSubscriptionToReceipts() {
    socket.off('conversation-message', updateMessageReceipt);
  }
}
