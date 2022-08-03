import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';

class Group {
  final String id;
  String name;
  List<User> users;
  List<Message> messages;

  Group(
      {required this.id,
      required this.name,
      required this.users,
      required this.messages});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'users': users.map((e) => e.toJson()).toList(),
        'messages': messages.map((e) => e.toJson()).toList()
      };

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
        id: json['id'],
        name: json['name'],
        users: (json['users'] as List).map((e) => User.fromJson(e)).toList(),
        messages: (json['messages'] as List)
            .map((e) => Message.fromJson(e))
            .toList());
  }
}
