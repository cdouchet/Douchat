import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/services/listeners/listener_service.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/views/home.dart';
import 'package:douchat3/views/login.dart';
import 'package:douchat3/views/register.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CompositionRoot {
  static late final ListenerService messageService;
  static late final UserService userService;

  static configure(String id) async {
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
    IO.Socket socket = IO.io(
        'https://192.168.204.6:2585',
        IO.OptionBuilder().setTransports(['websocket']).setQuery({
          'id': id,
          'token': await const FlutterSecureStorage().read(key: 'access_token')
        }).build());
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });

    socket.on('event', (data) => print(data));

    socket.onError((_) {
      print("Socket error");
    });
    socket.on('fromServer', (_) => print(_));

    print('instantiating ListenerService');
    messageService = ListenerService(socket: socket);
    userService = UserService(socket);

    // destroyAndSetup(r, connection);
  }

  static Future<Widget> restart(User client, List<User> users) async {
    await configure(client.id);
    return composeHome(client, users);
  }

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
      final User user = User.fromJson(isConnected['client']);
      print('after client setup');
      Utils.logger.d((await Api.getUsers()).body);
      final List<User> users =
          (jsonDecode((await Api.getUsers()).body)['payload']['users'] as List)
              .map((e) => User.fromJson(e))
              .toList();
      print('after settings users');
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
        await configure(user.id);
        print('connected');
        return composeHome(user, users);
      } else {
        return composeLogin();
      }
    } catch (e) {
      print(e);
      return Login();
    }
  }

  static Widget composeLogin() {
    return const Login();
  }

  static Widget composeHome(User client, List<User> users) {
    return Home(
        messageService: messageService,
        userService: userService,
        client: client,
        users: users);
  }

  static Widget composeRegister() {
    return const Register();
  }
}
