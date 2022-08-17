import 'dart:convert';

import 'package:douchat3/models/conversation.dart';
import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as flnp;
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ListenerService {
  final Socket socket;
  final flnp.FlutterLocalNotificationsPlugin notificationsPlugin;

  ListenerService({required this.socket, required this.notificationsPlugin});

  final List<int> notificationIds = <int>[];

  getMessage() {}

  messages() {
    socket.on('test', (data) => print(data));
    print("started listening for messages");
  }

  startReceivingEvents(BuildContext context) {
    _startReceivingConnectionEvents(context);
    _startReceivingDisconnectEvents(context);
    _sendDisconnection();

    _startReceivingUsernameUpdate(context);
    _startReceivingPhotoUrlUpdate(context);
    _startReceivingNewUsers(context);

    _startReceivingConversationMessages(context);
    // _startReceivingSelfConversationMessages(context);
  }

  _startReceivingConversationMessages(BuildContext context) {
    socket.on('conversation-message', (data) {
      print('new Message : $data');
      Provider.of<ConversationProvider>(context, listen: false)
          .addConversationMessage(Message.fromJson(data));
      if (data['from'] !=
              Provider.of<ClientProvider>(context, listen: false).client.id &&
          Provider.of<AppLifeCycleProvider>(context, listen: false).state !=
              AppLifecycleState.resumed) {
        int id = 0;
        while (notificationIds.contains(id)) {
          id++;
        }
        notificationIds.add(id);
        print("NOTIFICATION ID : " + id.toString());
        final user = Provider.of<UserProvider>(context, listen: false)
            .users
            .firstWhere((u) => u.id == data['from']);

        notificationsPlugin.show(
            id,
            user.username,
            data['content'],
            flnp.NotificationDetails(
                android: flnp.AndroidNotificationDetails(
                    data['from'], user.username,
                    enableVibration: true,
                    groupKey: data['from'],
                    setAsGroupSummary: true,
                    priority: flnp.Priority.max,
                    importance: flnp.Importance.max)),
            payload: "{'type': 'conversation', 'id': ${data['from']}}");
      }
    });
  }

  // _startReceivingSelfConversationMessages(BuildContext context) {
  //   socket.on('self-conversation-message', (data) {
  //     print('new Self Message : $data');
  //     Provider.of<ConversationProvider>(context, listen: false)
  //         .addSelfConversationMessage(Message.fromJson(data));
  //   });
  // }

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
    socket.on('user-added', (data) {
      Provider.of<UserProvider>(context, listen: false)
          .addUser(User.fromJson(data['user']));
      Provider.of<ConversationProvider>(context, listen: false).addConversation(
          Conversation(user: User.fromJson(data['user']), messages: []));
    });
  }

  _startReceivingUsernameUpdate(BuildContext context) {
    socket.on('change-username', (data) {
      Provider.of<UserProvider>(context, listen: false)
          .updateUsername(username: data['username'], id: data['id']);
    });
  }

  _startReceivingPhotoUrlUpdate(BuildContext context) {
    socket.on('change-photoUrl', (data) {
      Provider.of<UserProvider>(context, listen: false)
          .updatePhotoUrl(url: data['photoUrl'], id: data['id']);
    });
  }

  _sendDisconnection() {
    socket.onDisconnect((data) {
      Utils.logger.i('Socket disconnected');
      // socket.emit('disconnected');
      // socket.disconnect();
    });
  }

  testMessage(String message) {
    socket.emit('test', jsonEncode({"content": "dididi", "from": "lambda"}));
    print("Sent message test");
  }
}
