import 'package:douchat3/models/friend_request.dart';
import 'package:flutter/foundation.dart';

class FriendRequestProvider extends ChangeNotifier {
  late List<FriendRequest> _friendRequests;
  List<FriendRequest> get friendRequests => _friendRequests;

  void setFriendRequests(List<FriendRequest> fr) {
    _friendRequests = fr;
  }

  void addFriendRequest(FriendRequest fr) {
    _friendRequests.add(fr);
    notifyListeners();
  }

  void removeFriendRequest(String id) {
    _friendRequests.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}