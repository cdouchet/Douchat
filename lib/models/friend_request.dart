import 'package:douchat3/providers/friend_request_provider.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class FriendRequest {
  String id;
  String from;
  String fromUsername;
  String to;

  FriendRequest(
      {required this.id,
      required this.from,
      required this.fromUsername,
      required this.to});

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
      id: json['id'],
      from: json['from'],
      fromUsername: json['fromUsername'],
      to: json['to']);

  void respond(
      {required BuildContext context,
      required bool accept,
      required String clientId,
      required String userId,
      required String id,
      required UserService userService}) {
    userService.respondToFriendRequest(data: {
      'accept': accept,
      'clientId': clientId,
      'userId': userId,
      'id': id
    });
    if (accept) {
      Fluttertoast.showToast(
          msg: "Contact ajouté", gravity: ToastGravity.BOTTOM);
    }
    Provider.of<FriendRequestProvider>(context, listen: false)
        .removeFriendRequest(this.id);
  }
}
