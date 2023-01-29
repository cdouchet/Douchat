import 'dart:convert';

import 'package:douchat3/api/api.dart';

class User {
  final String id;
  String username;
  String photoUrl;
  bool online;

  User(
      {required this.id,
      required this.username,
      required this.photoUrl,
      required this.online});

  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'photoUrl': photoUrl, 'online': online};

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['id'],
      username: json['username'],
      photoUrl: json['photoUrl'] ?? json["photo_url"],
      online: json['online']);

  static Future<User> fromNetwork(String id) async {
    final dynamic res = jsonDecode((await Api.getUserFromId(id: id)).body);
    if (res['status'] != null && res['status'] == 'success') {
      return User.fromJson(jsonDecode((await Api.getUserFromId(id: id)).body));
    } else {
      return User(id: 'user', online: false, photoUrl: '', username: 'User');
    }
  }

  setOnline(bool newOnline) => online = newOnline;
  setUsername(String newUsername) => username = newUsername;
  setPhotoUrl(String url) => photoUrl = url;
}
