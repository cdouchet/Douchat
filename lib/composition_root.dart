import 'package:douchat3/services/message/message_service.dart';
import 'package:douchat3/views/home.dart';
import 'package:douchat3/views/register.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CompositionRoot {
  static late final MessageService messageService;

  static configure() async {
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
    IO.Socket socket = IO.io('https://cloud.doggo-saloon.net:2585',
        IO.OptionBuilder().setTransports(['websocket']).build());
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });

    socket.on('event', (data) => print(data));

    socket.onDisconnect((_) {
      print("Socket disconnected");
    });
    socket.onError((_) {
      print("Socket error");
    });
    socket.on('fromServer', (_) => print(_));

    messageService = MessageService(socket: socket);

    // destroyAndSetup(r, connection);
  }

  static Future<Widget> restart() async {
    await configure();
    return composeHome();
  }

  static Future<Widget> start() async {
    configure();
    if (await const FlutterSecureStorage().read(key: 'access_token') == null) {
      return composeRegister();
    }
    return composeHome();
  }

  static Widget composeHome() {
    return Home(messageService: messageService);
  }

  static Widget composeRegister() {
    return const Register();
  }
}
