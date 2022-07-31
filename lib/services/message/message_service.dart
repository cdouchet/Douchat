import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart';

class MessageService {
  final Socket socket;

  MessageService({required this.socket});

  getMessage() {}

  messages() {
    socket.on('test', (data) => print(data));
    print("started listening for messages");
  }

  testMessage(String message) {
    socket.emit('test', jsonEncode({"content": "dididi", "from": "lambda"}));
    print("Sent message test");
  }
}
