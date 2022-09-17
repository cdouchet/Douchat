import 'dart:convert';

import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/friend_request.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/friend_request_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as flnp;
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:vibration/vibration.dart';

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

  setup() {
    notificationsPlugin.cancelAll();
  }

  startReceivingEvents(BuildContext context) {
    _startReceivingConnectionEvents(context);
    _startReceivingDisconnectEvents(context);
    _sendDisconnection();

    _startReceivingUsernameUpdate(context);
    _startReceivingPhotoUrlUpdate(context);
    _startReceivingNewUsers(context);
    _startReceivingFriendRequests(context);
    _startReceivingFriendRequestResponses(context);

    _startReceivingConversationMessages(context);
    _startReceivingConversationReceipts(context);
    _startReceivingConversationMessageRemovals(context);

    _startReceivingGroupMessages(context);
    _startReceivingGroupReceipts(context);
    _startReceivingGroupMessageRemovals(context);
    // _startReceivingSelfConversationMessages(context);
  }

  _startReceivingConversationMessages(BuildContext context) {
    socket.on('conversation-message', (data) {
      print('new Message : $data');
      Provider.of<ConversationProvider>(context, listen: false)
          .addConversationMessage(Message.fromJson(data));
      if (
          // data['to'] !=
          //       Provider.of<ClientProvider>(context, listen: false).client.id
          //      &&
          // Provider.of<RouteProvider>(context, listen: false).route !=
          //     'private_thread'
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
        final String from = data['from'];

        notificationsPlugin.show(
            id,
            user.username,
            data['type'] == 'text'
                ? data['content']
                : data['type'] == 'image'
                    ? 'a envoyé une image.'
                    : data['type'] == 'video'
                        ? 'a envoyé une vidéo'
                        : 'a envoyé un gif',
            flnp.NotificationDetails(
                android: flnp.AndroidNotificationDetails(
                    data['from'], user.username,
                    enableVibration: true,
                    groupKey: data['from'],
                    setAsGroupSummary: true,
                    category: "CATEGORY_MESSAGE",
                    priority: flnp.Priority.max,
                    importance: flnp.Importance.max)),
            payload: '{"type": "conversation", "id": "$from"}');
      } else {
        Vibration.hasVibrator().then((value) {
          if (value ?? false) {
            if (Provider.of<RouteProvider>(context, listen: false)
                .isOnPrivateThread) {
              if (Provider.of<RouteProvider>(context, listen: false)
                      .privateThreadId ==
                  data['from']) {
                Vibration.vibrate(duration: 100, amplitude: 40);
              }
            } else {
              Vibration.vibrate(duration: 100, amplitude: 40);
            }
          }
        });
      }
    });
  }

  _startReceivingConversationReceipts(BuildContext context) {
    socket.on('conversation-receipts', (data) {
      Utils.logger.i('MESSAGES TO UPDATE : ' + data['messages'].toString());
      Provider.of<ConversationProvider>(context, listen: false).updateReadState(
          data['messages'].cast<String>(), data['clientId'],
          notify: true);
    });
  }

  _startReceivingConversationMessageRemovals(BuildContext context) {
    socket.on('remove-conversation-message', (data) {
      Provider.of<ConversationProvider>(context, listen: false)
          .removeConversationMessage(data);
    });
  }

  _startReceivingGroupMessages(BuildContext context) {
    socket.on('group-message', (data) {
      print('new Group Message : $data');
      Provider.of<GroupProvider>(context, listen: false).addGroupMessage(GroupMessage.fromJson(data));
      if (Provider.of<AppLifeCycleProvider>(context, listen: false).state != AppLifecycleState.resumed) {
        int id = 0;
        while (notificationIds.contains(id)) {
          id++;
        }
        notificationIds.add(id);
        final group = Provider.of<GroupProvider>(context, listen: false).getGroup(data['group']);
        final username = Provider.of<UserProvider>(context, listen: false).users.firstWhere((u) => u.id == data['from'], orElse: () => group.users.firstWhere((us) => us.id == data['from'])).username;
        notificationsPlugin.show(
          id,
          group.name,
          '$username' + data['type'] == 'text' ?
            ": ${data['content']}" :
            data['type'] == 'image' ?
              ' a envoyé une image' :
              data['type'] == 'video' ?
                ' a envoyé une vidéo' :
                  ' a envoyé un gif',
          flnp.NotificationDetails(
            android: flnp.AndroidNotificationDetails(
              data['from'], username,
              enableVibration: true,
              groupKey: data['from'],
              setAsGroupSummary: true,
              category: "CATEGORY_MESSAGE",
              priority: flnp.Priority.max,
              importance: flnp.Importance.max
            )
          ),
          payload: '{"type": "group", "id": "${group.id}"}'
        );
      } else {
        Vibration.hasVibrator().then((value) {
          if (value ?? false) {
            if (Provider.of<RouteProvider>(context, listen: false)
                .isOnGroupThread) {
              if (Provider.of<RouteProvider>(context, listen: false)
                      .groupThreadId ==
                  data['from']) {
                Vibration.vibrate(duration: 100, amplitude: 40);
              }
            } else {
              Vibration.vibrate(duration: 100, amplitude: 40);
            }
          }
        });
      }
    });
  }

  _startReceivingGroupReceipts(BuildContext context) {
    socket.on('group-receipts', (data) {
      Provider.of<GroupProvider>(context, listen: false).updateReadState(messagesToUpdate: data['messages'].cast<String>(), groupId: data['group'], readBy: data['userId'], notify: true);
    });
  }

  _startReceivingGroupMessageRemovals(BuildContext context) {
    socket.on('remove-group-message', (data) {
      Provider.of<GroupProvider>(context, listen: false).removeGroupMessage(data);
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

  _startReceivingFriendRequests(BuildContext context) {
    try {
      socket.on('friend-request', (data) {
        Provider.of<FriendRequestProvider>(context, listen: false)
            .addFriendRequest(FriendRequest.fromJson(data));
        int id = 0;
        while (notificationIds.contains(id)) {
          id++;
        }
        notificationIds.add(id);
        notificationsPlugin.show(
            id,
            "Nouvelle demande d'ami",
            "${data['fromUsername']}",
            flnp.NotificationDetails(
                android: flnp.AndroidNotificationDetails(
                    data['from'], data['to'],
                    enableVibration: true,
                    category: "CATEGORY_MESSAGE",
                    priority: flnp.Priority.max,
                    importance: flnp.Importance.max)),
            payload:
                '{"type": "friend_request", "username": "${data["fromUsername"]}"}');
      });
    } catch (e, s) {
      Utils.logger.i(e);
      Utils.logger.i(s);
    }
  }

  _startReceivingFriendRequestResponses(BuildContext context) {
    socket.on('friend-request-response', (data) {
      if (data['accept']) {
        final User u = User.fromJson(data['user']);
        Provider.of<UserProvider>(context, listen: false).addUser(u);
        Provider.of<ConversationProvider>(context, listen: false)
            .addConversation(Conversation(user: u, messages: []));
      }
      Provider.of<FriendRequestProvider>(context, listen: false)
          .removeFriendRequest(data['id']);
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
