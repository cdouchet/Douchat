import 'dart:convert';

import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/services/listeners/app_life_cycle_listener.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ListenerService {
  final Socket socket;

  ListenerService({required this.socket});

  getMessage() {}

  messages() {
    socket.on('test', (data) => print(data));
    print("started listening for messages");
  }

  startReceivingEvents(BuildContext context) {
    _startReceivingConnectionEvents(context);
    _startReceivingDisconnectEvents(context);
    _sendDisconnection();

    _startReceivingNewUsers(context);
    _startReceivingUsernameUpdate(context);
    _startReceivingPhotoUrlUpdate(context);

    _startReceivingMessages(context);
  }

  _startReceivingMessages(BuildContext context) {
    socket.on('message', (data) {});
  }

  _startReceivingConnectionEvents(BuildContext context) {
    socket.on('user-connection', (data) {
      Provider.of<UserProvider>(context, listen: false)
          .updateOnlineState(id: data['id'], online: true);
    });
  }

  _startReceivingDisconnectEvents(BuildContext context) {
    socket.on('user-disconnection', (data) {
      Provider.of<UserProvider>(context, listen: false)
          .updateOnlineState(id: data['id'], online: false);
    });
  }

  _startReceivingNewUsers(BuildContext context) {
    socket.on('user-created', (data) {
      Provider.of<UserProvider>(context, listen: false)
          .addUser(User.fromJson(data));
    });
  }

  _startReceivingUsernameUpdate(BuildContext context) {
    socket.on('username-updated', (data) {
      Provider.of<UserProvider>(context, listen: false)
          .updateUsername(username: data['username'], id: data['id']);
    });
  }

  _startReceivingPhotoUrlUpdate(BuildContext context) {
    socket.on('photoUrl-updated', (data) {
      Provider.of<UserProvider>(context, listen: false)
          .updatePhotoUrl(url: data['photoUrl'], id: data['id']);
    });
  }

  _sendDisconnection() {
    socket.onDisconnect((data) {
      print('Socket disconnected');
      // socket.emit('disconnected');
      // socket.disconnect();
    });
  }

  testMessage(String message) {
    socket.emit('test', jsonEncode({"content": "dididi", "from": "lambda"}));
    print("Sent message test");
  }
}
