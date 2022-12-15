import 'package:douchat3/models/conversations/message_reaction.dart';
import 'package:intl/intl.dart';

class GroupMessage {
  final String id;
  dynamic content;
  final String group;
  final String from;
  String type;
  final DateTime timeStamp;
  List<String> readBy;
  List<MessageReaction> reactions;

  GroupMessage(
      {required this.id,
      required this.content,
      required this.group,
      required this.from,
      required this.type,
      required this.timeStamp,
      required this.readBy,
      required this.reactions});

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'from': from,
        'type': type,
        'timestamp': DateFormat().format(timeStamp),
        'readBy': readBy,
        'reactions': reactions.map((e) => e.toJson()).toList()
      };

  factory GroupMessage.fromJson(Map<String, dynamic> json) => GroupMessage(
      id: json['id'],
      content: json['content'],
      group: json['group'],
      from: json['from'],
      type: json['type'],
      timeStamp: DateFormat().parse(json['timestamp']),
      readBy: json['readBy'].cast<String>(),
      reactions: (json['reactions'] as List)
          .map((e) => MessageReaction.fromJson(e))
          .toList());

  void updateMessageReadState(String userId) {
    if (!readBy.contains(userId)) {
      readBy.add(userId);
    }
  }

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
