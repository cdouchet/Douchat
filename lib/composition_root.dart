import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/services/listeners/listener_service.dart';
import 'package:douchat3/services/messages/message_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/views/home.dart';
import 'package:douchat3/views/login.dart';
import 'package:douchat3/views/private_message_thread.dart';
import 'package:douchat3/views/register.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CompositionRoot {
  static late ListenerService listenerService;
  static late UserService userService;
  static late MessageService messageService;
  static late IO.Socket socket;

  static Future<void> configure(String id,
      {required bool freshRegister}) async {
    // final ca = await rootBundle.loadString('assets/chain.pem');
    // final fileCa = await (await File(
    //             '${(await getApplicationDocumentsDirectory()).path}/chain.pem')
    //         .create())
    //     .writeAsString(ca);
    // RethinkDb r = RethinkDb();
    // Connection connection = await r.connect(
    //     host: 'douchat.doggo-saloon.net',
    //     ssl: {"ca": fileCa.path},
    //     db: 'douchat',
    //     user: 'admin',
    //     password: dotenv.env['RETHINKDB_PASSWORD']!);
    // final Socket socket =
    //     io('http://192.168.1.21:2585', OptionBuilder().disableAutoConnect());
    // socket.onError((data) => print(data));
    // socket.onConnectTimeout((data) => print(data));
    // socket.connect();
    Utils.logger.d('Configuring Douchat...');
    socket = IO.io(
        'https://192.168.28.155:2585',
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
    // destroyAndSetup(r, connection);
  }

  static void disposeServices() {}

  static Future<Widget> start(BuildContext context) async {
    try {
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
      print('after client setup');
      Utils.logger.d((await Api.getUsers(clientId: user.id)).body);
      final List<User> users =
          (jsonDecode((await Api.getUsers(clientId: user.id)).body)['payload']
                  ['users'] as List)
              .map((e) => User.fromJson(e))
              .toList();
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
        return composeHome(user, users, messages, conversations, groups);
      } else {
        return composeLogin();
      }
    } catch (e) {
      print('composition root error 2');
      print(e);
      return const Login();
    }
  }

  static Widget composeLogin() {
    return const Login();
  }

  static Widget composeHome(
      User client,
      List<User> users,
      List<Message> messages,
      List<Conversation> conversations,
      List<Group> groups) {
    return Home(
        messageService: listenerService,
        userService: userService,
        client: client,
        messages: messages,
        users: users,
        conversations: conversations,
        groups: groups);
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
}
