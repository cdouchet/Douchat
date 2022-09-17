import 'package:flutter/widgets.dart';

class RouteProvider extends ChangeNotifier {
  String _route = '';
  bool _isOnPrivateThread = false;
  bool _isOnFriendRequestView = false;
  bool _isOnGroupThread = false;
  String _privateThreadId = '';
  String _groupThreadId = '';
  String get route => _route;
  bool get isOnPrivateThread => _isOnPrivateThread;
  bool get isOnFriendRequestView => _isOnFriendRequestView;
  bool get isOnGroupThread => _isOnGroupThread;
  String get privateThreadId => _privateThreadId;
  String get groupThreadId => _groupThreadId;

  void changeRoute(String newRoute) {
    _route = newRoute;
    notifyListeners();
  }

  void changePrivateThreadPresence(bool b) {
    _isOnPrivateThread = b;
    notifyListeners();
  }

  void changePrivateThreadId(String id) {
    _privateThreadId = id;
    notifyListeners();
  }

  void changeFriendRequestPresence(bool b) {
    _isOnFriendRequestView = b;
    notifyListeners();
  }

  void changeGroupThreadPresence(bool b) {
    _isOnGroupThread = b;
    notifyListeners();
  }

  void changeGroupThreadId(String id) {
    _groupThreadId = id;
    notifyListeners();
  }
}
