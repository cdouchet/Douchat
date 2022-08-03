import 'package:socket_io_client/socket_io_client.dart';

class UserService {
  final Socket socket;

  UserService(this.socket);

  void changeUsername(String username) {}
}
