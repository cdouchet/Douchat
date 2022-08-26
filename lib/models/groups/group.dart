import 'package:douchat3/models/groups/group_message.dart';

class Group {
  String id;
  List<String> users;
  List<GroupMessage> messages;
  Group({required this.id, required this.users, required this.messages});

  Map<String, dynamic> toJson() =>
      {'users': users, 'messages': messages.map((m) => m.toJson()).toList()};

  factory Group.fromJson(Map<String, dynamic> json) {
    final List<GroupMessage> ms = (json['messages'] as List)
        .map((e) => GroupMessage.fromJson(e))
        .toList();
    return Group(
        id: json['id'], users: json['users'].cast<String>(), messages: ms);
  }
}
