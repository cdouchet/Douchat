import 'package:douchat3/main.dart';
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
  DateTime updatedAt;
  bool deleted;

  GroupMessage(
      {required this.id,
      required this.content,
      required this.group,
      required this.from,
      required this.type,
      required this.timeStamp,
      required this.readBy,
      required this.reactions,
      required this.updatedAt,
      required this.deleted});

  Map<String, dynamic> toJson() => {
        'id': id,
        'group': group,
        'content': content,
        'from': from,
        'type': type,
        'timestamp': DateFormat().format(timeStamp),
        'readBy': readBy,
        'reactions': reactions.map((e) => e.toJson()).toList(),
        'updated_at': DateFormat().format(updatedAt),
        'deleted': deleted
      };

  factory GroupMessage.fromJson(Map<String, dynamic> json) => GroupMessage(
      id: json['id'],
      content: json['content'],
      group: json['group'] ?? json["group_id"],
      from: json['from'] ?? json["from_id"],
      type: json['type'],
      timeStamp: DateFormat().parse(json['timestamp']),
      readBy: json['readBy'].cast<String>(),
      reactions: (json['reactions'] as List)
          .map((e) => MessageReaction.fromJson(e))
          .toList(),
      updatedAt: (double.tryParse(json["updated_at"][0]) != null)
          ? DateFormat("yyyy-MM-ddThh:mm:ss").parse(json['updated_at'])
          : DateFormat().parse(json["updated_at"]),
      deleted: json["deleted"] ?? false);

  void updateMessageReadState(String userId) {
    if (!readBy.contains(userId)) {
      readBy.add(userId);
    }
  }

  void updateTypeState(String t) => type = t;

  void addReaction({required String user, required String emoji}) {
    if (reactions.any((e) => e.emoji == emoji)) {
      final toUpdate = reactions.firstWhere((e) => e.emoji == emoji);
      toUpdate.ids.add(user);
      db.updateGroupReaction(toUpdate.ids, id);
    } else {
      final newReaction = MessageReaction(emoji: emoji, ids: [user]);
      db.insertGroupReaction(newReaction, id);
      reactions.add(newReaction);
    }
  }

  void removeReaction({required String user, required String emoji}) {
    if (reactions.any((e) => e.emoji == emoji)) {
      final reaction = reactions.firstWhere((e) => e.emoji == emoji);
      reaction.ids.remove(user);
      if (reaction.ids.isEmpty) {
        db.deleteGroupReaction(id, emoji);
        reactions.remove(reaction);
      } else {
        db.updateGroupReaction(reaction.ids, id);
      }
    } else {
      throw Exception("Tried to remove a non existing reaction");
    }
  }
}
