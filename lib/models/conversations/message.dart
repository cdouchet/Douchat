import 'package:douchat3/models/conversations/message_reaction.dart';
import 'package:intl/intl.dart';

class Message {
  final String id;
  dynamic content;
  final String from;
  final String to;
  String type;
  final DateTime timeStamp;
  bool read;
  List<MessageReaction> reactions;

  Message(
      {required this.id,
      required this.content,
      required this.from,
      required this.to,
      required this.type,
      required this.timeStamp,
      required this.read,
      required this.reactions});

  Map<String, dynamic> toJson() => {
        "id": id,
        "content": content,
        "from": from,
        "to": to,
        "type": type,
        "timestamp": DateFormat().format(timeStamp),
        "read": read,
        "reactions": reactions.map((e) => e.toJson()).toList()
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
      id: json['id'],
      content: json['content'],
      from: json['from'],
      to: json['to'],
      type: json['type'],
      timeStamp: DateFormat().parse(json['timestamp']),
      read: json['read'],
      reactions: (json["reactions"] as List)
          .map((e) => MessageReaction.fromJson(e))
          .toList());

  void updateMessageState(bool update) => read = update;
  void updateTypeState(String t) => type = t;
  void addReaction({required String user, required String emoji}) {
    if (reactions.any((e) => e.emoji == emoji)) {
      reactions.firstWhere((e) => e.emoji == emoji).ids.add(user);
    } else {
      reactions.add(MessageReaction(emoji: emoji, ids: [user]));
    }
  }

  void removeReaction({required String user, required String emoji}) {
    if (reactions.any((e) => e.emoji == emoji)) {
      final reaction = reactions.firstWhere((e) => e.emoji == emoji);
      reaction.ids.remove(user);
      if (reaction.ids.isEmpty) {
        reactions.remove(reaction);
      }
    } else {
      throw Exception("Tried to remove a non existing reaction");
    }
  }
}
