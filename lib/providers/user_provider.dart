import 'package:douchat3/main.dart';
import 'package:douchat3/models/user.dart';
import 'package:flutter/widgets.dart';

class UserProvider extends ChangeNotifier {
  late List<User> _users;
  List<User> get users => _users;

  bool doUserAlreadyExists(String id) {
    return _users.any((u) => u.id == id);
  }

  void setUsers(List<User> newUsers) {
    _users = newUsers;
  }

  void changeUsers(List<User> newUsers) {
    _users = newUsers;
    notifyListeners();
  }

  addUser(User user) {
    _users.add(user);
    db.insertUser(user);
    print('Added user ${user.id}');
    notifyListeners();
  }

  removeUser(String id) {
    _users.removeWhere((u) => u.id == id);
    db.deleteUser(id);
    notifyListeners();
  }

  void updateUser(User user) {
    final toUpdate = _users.firstWhere((u) => u.id == user.id);
    toUpdate.setOnline(user.online);
    toUpdate.setUsername(user.username);
    toUpdate.setPhotoUrl(user.photoUrl);
    db.updateUser(user);
    notifyListeners();
  }

  updateOnlineState({required bool online, required String id}) {
    final toUpdate = _users.firstWhere((u) => u.id == id);
    toUpdate.setOnline(online);
    db.updateUser(toUpdate);
    notifyListeners();
  }

  updateUsername({required String username, required String id}) {
    final toUpdate = _users.firstWhere((u) => u.id == id);
    toUpdate.setUsername(username);
    db.updateUser(toUpdate);
    notifyListeners();
  }

  updatePhotoUrl({required String url, required String id}) {
    final toUpdate = _users.firstWhere((u) => u.id == id);
    toUpdate.setPhotoUrl(url);
    db.updateUser(toUpdate);
    notifyListeners();
  }

  List<User> getConnectedUsers() {
    return _users.where((user) => user.online == true).toList();
  }
}
