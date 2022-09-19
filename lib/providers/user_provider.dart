import 'package:douchat3/models/user.dart';
import 'package:flutter/widgets.dart';

class UserProvider extends ChangeNotifier {
  late List<User> _users;
  List<User> get users => _users;

  void setUsers(List<User> newUsers) {
    _users = newUsers;
  }

  addUser(User user) {
    _users.add(user);
    print('Added user ${user.id}');
    notifyListeners();
  }

  removeUser(String id) {
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  updateOnlineState({required bool online, required String id}) {
    _users.firstWhere((u) => u.id == id).setOnline(online);
    notifyListeners();
  }

  updateUsername({required String username, required String id}) {
    _users.firstWhere((u) => u.id == id).setUsername(username);
    notifyListeners();
  }

  updatePhotoUrl({required String url, required String id}) {
    _users.firstWhere((u) => u.id == id).setPhotoUrl(url);
    notifyListeners();
  }

  List<User> getConnectedUsers() {
    return _users.where((user) => user.online == true).toList();
  }
}
