import 'package:douchat3/models/message.dart';
import 'package:douchat3/models/user.dart';

class Conversation {
  final User user;
  List<Message> messages;

  Conversation({required this.user, required this.messages});

  Map<String, dynamic> toJson() => {
        'users': user.toJson(),
        'messages': messages.map((e) => e.toJson()).toList()
      };

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<Message> jsonMessages =
        (json['messages'] as List).map((e) => Message.fromJson(e)).toList();
    return Conversation(
        user: User.fromJson(json['user']), messages: jsonMessages);
  }

  factory Conversation.emptyFromJson(Map<String, dynamic> json) {
    final conv = Conversation.fromJson(json);
    conv.messages.clear();
    return conv;
  }
}
