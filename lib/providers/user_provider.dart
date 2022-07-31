import 'package:douchat3/models/user.dart';
import 'package:flutter/widgets.dart';

class UserProvider extends ChangeNotifier {
  late List<User> _users;
  List<User> get users => _users;

  void setUsers(List<User> newUsers) {
    _users = newUsers;
    notifyListeners();
  }
}
