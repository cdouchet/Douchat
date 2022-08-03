import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';

class Conversation {
  final String id;
  final List<User> users;
  List<Message> messages;

  Conversation({required this.id, required this.users, required this.messages});

  Map<String, dynamic> toJson() => {
        'id': id,
        'users': users.map((e) => e.toJson()).toList(),
        'messages': messages.map((e) => e.toJson()).toList()
      };

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<Message> jsonMessages =
        (json['messages'] as List).map((e) => Message.fromJson(e)).toList();
    List<User> jsonUsers =
        (json['users'] as List).map((e) => User.fromJson(e)).toList();
    return Conversation(
        id: json['id'], users: jsonUsers, messages: jsonMessages);
  }

  factory Conversation.emptyFromJson(Map<String, dynamic> json) {
    final conv = Conversation.fromJson(json);
    conv.messages.clear();
    return conv;
  }
}
