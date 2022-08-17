import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MessageService extends ChangeNotifier {
  final Socket socket;

  MessageService({required this.socket});

  void sendMessage(dynamic data) {
    socket.emit('conversation-message', data);
  }

  void sendTypingEvent(dynamic data) {
    socket.emit('conversation-typing', data);
  }
}
