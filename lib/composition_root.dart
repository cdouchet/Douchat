import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/friend_request.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/services/groups/group_service.dart';
import 'package:douchat3/services/listeners/listener_service.dart';
import 'package:douchat3/services/messages/message_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/utils/notification_photo_registar.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/views/friend_request_view.dart';
import 'package:douchat3/views/group_message_thread.dart';
import 'package:douchat3/views/home.dart';
import 'package:douchat3/views/login.dart';
import 'package:douchat3/views/private_message_thread.dart';
import 'package:douchat3/views/register.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CompositionRoot {
  static late ListenerService listenerService;
  static late UserService userService;
  static late MessageService messageService;
  static late GroupService groupService;
  static late IO.Socket socket;

  static Future<void> configure(String id,
      {required bool freshRegister}) async {
    Utils.logger.d('Configuring Douchat...');
    socket = IO.io(
        'https://${dotenv.env["DOUCHAT_URI"]}:2585',
        IO.OptionBuilder().setTransports(['websocket']).setQuery({
          'id': id,
          'token': await const FlutterSecureStorage().read(key: 'access_token'),
          'freshRegister': freshRegister ? 'true' : 'false'
        }).build());
    Utils.logger.d('Socket io object : ' + socket.toString());
    socket.onConnect((_) {
      Utils.logger.i('Socket connected');
    });
    socket.connect();

    socket.on('event', (data) => print(data));

    socket.onError((_) {
      print("Socket error");
    });
    socket.on('fromServer', (_) => print(_));

    print('instantiating ListenerService');
    listenerService = ListenerService(
        socket: socket, notificationsPlugin: notificationsPlugin);
    userService = UserService(socket);
    messageService = MessageService(socket: socket);
    groupService = GroupService(socket: socket);
    // destroyAndSetup(r, connection);
  }

  static void disposeServices() {}

  static Future<Widget> start(BuildContext context) async {
    try {
      final List<Permission> perms = [
        Permission.notification,
      ];
      for (final Permission p in perms) {
        if (await p.isDenied) {
          p.request();
        }
      }
      // await FlutterSecureStorage().delete(key: 'access_token');
      final token =
          await const FlutterSecureStorage().read(key: 'access_token');
      print('after read token');
      if (token == null) {
        return composeLogin();
      }
      print('token is not null');
      final isConnected =
          jsonDecode((await Api.isConnected(token)).body)['payload'];
      print(isConnected);
      print('after api call');
      final bool connected = isConnected['connected'];
      print('after is connected');
      if (!connected) {
        return composeLogin();
      }
      final User user = User.fromJson(isConnected['client']);
      final apiFriendRequests = await Api.getFriendRequests(clientId: user.id);
      final List<FriendRequest> friendRequests =
          (jsonDecode(apiFriendRequests.body)['payload']['friend_requests']
                  as List)
              .map((e) => FriendRequest.fromJson(e))
              .toList();
      print('after client setup');
      Utils.logger.d((await Api.getUsers(clientId: user.id)).body);
      final List<User> users =
          (jsonDecode((await Api.getUsers(clientId: user.id)).body)['payload']
                  ['users'] as List)
              .map((e) => User.fromJson(e))
              .toList();
      List<DouchatNotificationIcon> icons = [];
      for (int i = 0; i < users.length; i++) {
        Uint8List? bytes;
        if (users[i].photoUrl == '') {
          bytes = (await Api.getContactPhoto(url: users[i].photoUrl)).bodyBytes;
        }
        if (bytes != null) {
          bytes =
              await FlutterImageCompress.compressWithList(bytes, quality: 20);
        }
        icons.add(DouchatNotificationIcon(id: users[i].id, bytes: bytes));
      }
      Utils.logger.i('Composition Root icons : $icons');
      NotificationPhotoRegistar.populate(icons);
      await NotificationPhotoRegistar.setup();
      Utils.logger
          .d((await Api.getConversationMessages(clientId: user.id)).body);
      final List<Message> messages = (jsonDecode(
              (await Api.getConversationMessages(clientId: user.id))
                  .body)['payload']['messages'] as List)
          .map((e) => Message.fromJson(e))
          .toList();
      messages.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
      print('after settings users');

      List<Conversation> conversations = users
          .map((u) => Conversation(
              messages: messages
                  .where((m) =>
                      (m.from == u.id && m.to == user.id) ||
                      (m.from == user.id && m.to == u.id))
                  .toList(),
              user: u))
          .toList();
      final grps = jsonDecode((await Api.getGroups(clientId: user.id)).body);
      final List<Group> groups = (grps['payload']['groups'] as List)
          .map((g) => Group.fromJson(g))
          .toList();
      groups.forEach((g) {
        Utils.logger.i('GROUP PHOTO URL : ${g.photoUrl}');
      });
      List<DouchatNotificationIcon> groupIcons = [];
      for (int i = 0; i < groups.length; i++) {
        Uint8List? bytes;
        if (groups[i].photoUrl != null) {
          bytes =
              (await Api.getContactPhoto(url: groups[i].photoUrl!)).bodyBytes;
        }
        if (bytes != null) {
          bytes =
              await FlutterImageCompress.compressWithList(bytes, quality: 20);
        }
        groupIcons.add(DouchatNotificationIcon(id: groups[i].id, bytes: bytes));
      }
      NotificationPhotoRegistar.populateGroup(groupIcons);
      // final gmes =
      //     await Api.getGroupsMessages(groups: groups.map((e) => e.id).toList());
      // final List<GroupMessage> groupMessages =
      //     (jsonDecode(gmes.body)['payload']['messages'] as List)
      //         .map((e) => GroupMessage.fromJson(e))
      //         .toList();
      // for (final Group group in groups) {
      //   final List<GroupMessage> gm =
      //       groupMessages.where((m) => m.group == group.id).toList();
      //   Utils.logger.i('Hello les messages', gm);

      //   group.populate(gm);
      // }
      try {
        print('before remove user id');
        users.removeWhere((element) => element.id == user.id);
        print('after remove user id');
      } catch (e) {
        print(e);
        print(users);
        print(user.id);
      }
      if (connected) {
        await configure(user.id, freshRegister: false);
        print('connected');
        return composeHome(
            client: user,
            users: users,
            messages: messages,
            conversations: conversations,
            groups: groups,
            friendRequests: friendRequests);
      } else {
        return composeLogin();
      }
    } catch (e, s) {
      Utils.logger.i('Composition root error 2', e, s);
      return const Login();
    }
  }

  static Widget composeLogin() {
    return const Login();
  }

  static Widget composeHome(
      {required User client,
      required List<User> users,
      required List<Message> messages,
      required List<Conversation> conversations,
      required List<Group> groups,
      required List<FriendRequest> friendRequests}) {
    return Home(
        messageService: listenerService,
        userService: userService,
        client: client,
        messages: messages,
        users: users,
        conversations: conversations,
        groups: groups,
        friendRequests: friendRequests);
  }

  static Widget composeRegister() {
    return const Register();
  }

  static Widget composePrivateMessageThread({required User user}) {
    return PrivateMessageThread(
      userId: user.id,
      userService: userService,
      messageService: messageService,
    );
  }

  static Widget composeGroupMessageThread({required String id}) {
    return GroupMessageThread(
      groupId: id,
      groupService: groupService,
      userService: userService,
    );
  }

  static Widget composeFriendRequestView() {
    return FriendRequestView(userService: userService);
  }
}
