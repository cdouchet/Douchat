import 'dart:convert';
import 'dart:io';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/friend_request.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/friend_request_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/utils/notification_photo_registar.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as flnp;
import 'package:intl/intl.dart';
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
    _messageRefresher(context);

    _startReceivingConnectionEvents(context);
    _startReceivingDisconnectEvents(context);
    _sendDisconnection();

    _startReceivingUsernameUpdate(context);
    _startReceivingPhotoUrlUpdate(context);
    _startReceivingNewUsers(context);
    _startReceivingFriendRequests(context);
    _startReceivingFriendRequestResponses(context);
    _startReceivingContactDelete(context);

    _startReceivingConversationMessages(context);
    _startReceivingConversationReceipts(context);
    _startReceivingConversationMessageRemovals(context);
    _startReceivingConversationReactionAddition(context);
    _startReceivingConversationReactionRemoval(context);

    _startReceivingNewGroups(context);
    _startReceivingGroupMessages(context);
    _startReceivingGroupReceipts(context);
    _startReceivingGroupMessageRemovals(context);
    _startReceivingGroupNameUpdate(context);
    _startReceivingGroupPhotoUpdate(context);
    _startReceivingGroupAdminUpdate(context);
    _startReceivingGroupUserAddition(context);
    _startReceivingGroupUserRemoval(context);
    _startReceivingGroupReactionAddition(context);
    _startReceivingGroupReactionRemoval(context);
    // _startReceivingSelfConversationMessages(context);
    print("Listeners set");
  }

  _messageRefresher(BuildContext context) {
    socket.onConnect((_) async {
      final groupsAndMessages = await Api.getGroupsAndConversationMessages();
      print(groupsAndMessages.body);
      final decodedGroupsAndMessages = jsonDecode(groupsAndMessages.body);
      final grps = decodedGroupsAndMessages["groups"];
      final List<Group> parsedApiGroups =
          (grps as List).map((g) => Group.fromJson(g)).toList();
      final convs = decodedGroupsAndMessages["conversations"];
      final List<Message> parsedApiConversations =
          (convs as List).map((c) => Message.fromJson(c)).toList();
      final List<User> users = (jsonDecode((await Api.getUsers(
                  clientId: Provider.of<ClientProvider>(context, listen: false)
                      .client
                      .id))
              .body)['payload']['users'] as List)
          .map((e) => User.fromJson(e))
          .toList();
      Provider.of<UserProvider>(context, listen: false).changeUsers(users);
      Utils.manageNewMessages(context, parsedApiConversations, parsedApiGroups);
      CompositionRoot.socket.emit("douchat-reconnect");
    });
    socket.onReconnect((data) {
      print("Reconnected");
      Utils.logger.i("Reconnected");
    });
  }

  _startReceivingConversationMessages(BuildContext context) {
    socket.on('conversation-message', (data) async {
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
        final user = Provider.of<UserProvider>(context, listen: false)
            .users
            .firstWhere((u) => u.id == data['from']);
        final String from = data['from'];
        final String messageText = data['type'] == 'text'
            ? data['content']
            : data['type'] == 'image'
                ? '${user.username} a envoyé une image.'
                : data['type'] == 'video'
                    ? '${user.username} a envoyé une vidéo'
                    : '${user.username} a envoyé un gif';
        if (Platform.isAndroid) {
          final List<flnp.ActiveNotification> activeNotifications =
              (await notificationsPlugin
                  .resolvePlatformSpecificImplementation<
                      flnp.AndroidFlutterLocalNotificationsPlugin>()
                  ?.getActiveNotifications())!;
          activeNotifications.forEach((element) {
            Utils.logger.i(element.title);
            Utils.logger.i(element.channelId);
          });
          // if (activeNotifications.any((element) => element.channelId == data['from'])) {
          //   final flnp.ActiveNotification notif = activeNotifications.firstWhere((n) => n.channelId == data['from']);
          //   finalText = '${notif.body}\n$messageText';
          //   notifId = notif.id;
          // } else {
          //   finalText = messageText;
          //   notifId = id;
          // }
          List<flnp.Message> notifMessages = activeNotifications
              .where((n) => n.channelId == data['from'])
              .map((e) => flnp.Message(
                  e.body!, DateFormat().parse(data['timestamp']), null))
              .toList();
          if (notifMessages.isNotEmpty) {
            id = activeNotifications
                .firstWhere((n) => n.channelId == data['from'])
                .id;
          }
          print("NOTIFICATION ID : " + id.toString());
          notifMessages.add(flnp.Message(
              messageText, DateFormat().parse(data['timestamp']), null));
          notificationsPlugin.show(
              id,
              user.username,
              messageText,
              flnp.NotificationDetails(
                  android: flnp.AndroidNotificationDetails(
                      data['from'], user.username,
                      enableVibration: true,
                      groupKey: data['from'],
                      setAsGroupSummary: !activeNotifications
                          .any((n) => n.channelId == data['from']),
                      category: "CATEGORY_MESSAGE",
                      priority: flnp.Priority.max,
                      styleInformation: flnp.MessagingStyleInformation(
                          flnp.Person(
                              bot: false,
                              name: user.username,
                              icon: flnp.ByteArrayAndroidIcon(
                                  NotificationPhotoRegistar.getBytesFromId(
                                          data['from']) ??
                                      NotificationPhotoRegistar.getBytesFromId(
                                          'person')!)),
                          conversationTitle: user.username,
                          messages: notifMessages),
                      importance: flnp.Importance.max)),
              payload: '{"type": "conversation", "id": "$from"}');
        } else {
          notificationsPlugin.show(id, user.username, messageText,
              flnp.NotificationDetails(iOS: flnp.IOSNotificationDetails()));
        }
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

  _startReceivingConversationReactionAddition(BuildContext context) {
    socket.on("add-conversation-reaction", (data) {
      Provider.of<ConversationProvider>(context, listen: false).addReaction(
          id: data["id"], userId: data["clientId"], emoji: data["emoji"]);
    });
  }

  _startReceivingConversationReactionRemoval(BuildContext context) {
    socket.on("remove-conversation-reaction", (data) {
      Provider.of<ConversationProvider>(context, listen: false).removeReaction(
          id: data["id"], userId: data["clientId"], emoji: data["emoji"]);
    });
  }

  _startReceivingNewGroups(BuildContext context) {
    socket.on('new-group', (data) {
      Utils.logger.i('NEW GROUP : $data');
      Provider.of<GroupProvider>(context, listen: false)
          .addGroup(Group.fromJson(data));
    });
  }

  _startReceivingGroupMessages(BuildContext context) {
    socket.on('group-message', (data) async {
      print('new Group Message : $data');
      Provider.of<GroupProvider>(context, listen: false)
          .addGroupMessage(GroupMessage.fromJson(data));
      Utils.logger.i('INCOMING GROUP MESSAGE : $data');
      if (Provider.of<AppLifeCycleProvider>(context, listen: false).state !=
              AppLifecycleState.resumed &&
          data['type'] != 'system') {
        int id = 0;
        while (notificationIds.contains(id)) {
          id++;
        }
        notificationIds.add(id);
        final group = Provider.of<GroupProvider>(context, listen: false)
            .getGroup(data['group']);
        final username = Provider.of<UserProvider>(context, listen: false)
            .users
            .firstWhere((u) => u.id == data['from'],
                orElse: () =>
                    group.users.firstWhere((us) => us.id == data['from']))
            .username;
        final String messageText = '$username' +
            (data['type'] == 'text'
                ? ": ${data['content']}"
                : data['type'] == 'image'
                    ? ' a envoyé une image'
                    : data['type'] == 'video'
                        ? ' a envoyé une vidéo'
                        : ' a envoyé un gif');
        if (Platform.isAndroid) {
          List<flnp.ActiveNotification> activeNotifications =
              (await notificationsPlugin
                  .resolvePlatformSpecificImplementation<
                      flnp.AndroidFlutterLocalNotificationsPlugin>()
                  ?.getActiveNotifications())!;
          activeNotifications.forEach((element) {
            Utils.logger.i(element.title);
            Utils.logger.i(element.channelId);
          });
          List<flnp.Message> notifMessages = activeNotifications
              .where((n) => n.channelId == group.id)
              .map((e) => flnp.Message(
                  e.body!, DateFormat().parse(data['timestamp']), null))
              .toList();
          if (notifMessages.isNotEmpty) {
            id = activeNotifications
                .firstWhere((n) => n.channelId == group.id)
                .id;
          }
          print('Notification id : ' + id.toString());
          notifMessages.add(flnp.Message(
              messageText, DateFormat().parse(data['timestamp']), null));
          notificationsPlugin.show(
              id,
              group.name,
              messageText,
              flnp.NotificationDetails(
                  android: flnp.AndroidNotificationDetails(group.id, username,
                      enableVibration: true,
                      groupKey: group.id,
                      setAsGroupSummary: !activeNotifications
                          .any((n) => n.channelId == group.id),
                      category: "CATEGORY_MESSAGE",
                      priority: flnp.Priority.max,
                      importance: flnp.Importance.max,
                      styleInformation: flnp.MessagingStyleInformation(
                          flnp.Person(
                              bot: false,
                              name: group.name,
                              icon: flnp.ByteArrayAndroidIcon(
                                  NotificationPhotoRegistar.getBytedFromGroupId(
                                          group.id) ??
                                      NotificationPhotoRegistar
                                          .getBytedFromGroupId('group')!)),
                          conversationTitle: group.name,
                          messages: notifMessages))),
              payload: '{"type": "group", "id": "${group.id}"}');
        } else {
          notificationsPlugin.show(id, group.name, messageText,
              flnp.NotificationDetails(iOS: flnp.IOSNotificationDetails()));
        }
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

  GroupProvider _groupProvider(BuildContext context, {bool listen = false}) {
    return Provider.of<GroupProvider>(context, listen: listen);
  }

  _startReceivingGroupReceipts(BuildContext context) {
    socket.on('group-receipts', (data) {
      _groupProvider(context).updateReadState(
          messagesToUpdate: data['messages'].cast<String>(),
          groupId: data['group'],
          readBy: data['userId'],
          notify: true);
    });
  }

  _startReceivingGroupMessageRemovals(BuildContext context) {
    socket.on('remove-group-message', (data) {
      _groupProvider(context).removeGroupMessage(data);
    });
  }

  _startReceivingGroupNameUpdate(BuildContext context) {
    socket.on('group-name-update', (data) {
      _groupProvider(context)
          .updateGroupName(name: data['name'], id: data['group']);
    });
  }

  _startReceivingGroupPhotoUpdate(BuildContext context) {
    socket.on('group-photo-update', (data) {
      _groupProvider(context)
          .updateGroupPhoto(url: data['url'], id: data['group']);
    });
  }

  _startReceivingGroupAdminUpdate(BuildContext context) {
    socket.on('group-admin-update', (data) {
      _groupProvider(context)
          .updateGroupAdmin(admin: data['admin'], id: data['group']);
    });
  }

  _startReceivingGroupUserRemoval(BuildContext context) {
    socket.on('group-user-removal', (data) {
      _groupProvider(context)
          .removeUser(userId: data['userId'], id: data['group']);
    });
  }

  _startReceivingGroupUserAddition(BuildContext context) {
    socket.on('group-user-addition', (data) {
      _groupProvider(context)
          .addUser(user: User.fromJson(data['user']), id: data['group']);
    });
  }

  _startReceivingGroupReactionAddition(BuildContext context) {
    socket.on('add-group-reaction', (data) {
      Utils.logger.i("Group reaction added");
      _groupProvider(context).addReaction(
          id: data["id"], userId: data["clientId"], emoji: data["emoji"]);
    });
  }

  _startReceivingGroupReactionRemoval(BuildContext context) {
    socket.on("remove-group-reaction", (data) {
      _groupProvider(context).removeReaction(
          id: data["id"], userId: data["clientId"], emoji: data["emoji"]);
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
    socket.on('user-added', (data) async {
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
    socket.on('friend-request-response', (data) async {
      if (data['accept']) {
        final User u = User.fromJson(data['user']);
        Provider.of<UserProvider>(context, listen: false).addUser(u);
        Provider.of<ConversationProvider>(context, listen: false)
            .addConversation(Conversation(user: u, messages: []));
        NotificationPhotoRegistar.addIcon(DouchatNotificationIcon(
            id: data['user']['id'],
            bytes: await FlutterImageCompress.compressWithList(
                (await Api.getContactPhoto(url: data['user']['photoUrl']))
                    .bodyBytes,
                quality: 20)));
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
    socket.on('change-photoUrl', (data) async {
      Provider.of<UserProvider>(context, listen: false)
          .updatePhotoUrl(url: data['photoUrl'], id: data['id']);
      NotificationPhotoRegistar.updateIconBytes(
          id: data['id'],
          bytes: await FlutterImageCompress.compressWithList(
              (await Api.getContactPhoto(url: data['photoUrl'])).bodyBytes,
              rotate: 90,
              quality: 20));
    });
  }

  _startReceivingContactDelete(BuildContext context) {
    socket.on('remove-contact', (data) async {
      Provider.of<UserProvider>(context, listen: false).removeUser(data["id"]);
      Provider.of<ConversationProvider>(context, listen: false)
          .removeConversation(data["id"]);
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
