import 'package:douchat3/main.dart';
import 'package:douchat3/models/conversations/message_reaction.dart';
import 'package:intl/intl.dart';

extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == "true";
  }
}

class Message {
  final String id;
  dynamic content;
  final String from;
  final String to;
  String type;
  final DateTime timeStamp;
  bool read;
  List<MessageReaction> reactions;
  DateTime updatedAt;
  bool deleted;

  Message(
      {required this.id,
      required this.content,
      required this.from,
      required this.to,
      required this.type,
      required this.timeStamp,
      required this.read,
      required this.reactions,
      required this.updatedAt,
      required this.deleted});

  Map<String, dynamic> toJson() => {
        "id": id,
        "content": content,
        "from": from,
        "to": to,
        "type": type,
        "timestamp": DateFormat().format(timeStamp),
        "read": read,
        "reactions": reactions.map((e) => e.toJson()).toList(),
        "updated_at": DateFormat().format(updatedAt),
        "deleted": deleted
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
      id: json['id'],
      content: json['content'],
      from: json['from'] ?? json["from_id"],
      to: json['to'] ?? json["to_id"],
      type: json['type'],
      timeStamp: DateFormat().parse(json['timestamp']),
      read: json["read"] is bool
          ? json["read"]
          : (json["read"] as String).parseBool(),
      reactions: (json["reactions"] as List)
          .map((e) => MessageReaction.fromJson(e))
          .toList(),
      updatedAt: (double.tryParse(json["updated_at"][0]) != null)
          ? DateFormat("yyyy-MM-ddThh:mm:ss").parse(json['updated_at'])
          : DateFormat().parse(json["updated_at"]),
      deleted: json["deleted"] ?? false);

  void updateMessageState(bool update) => read = update;
  void updateTypeState(String t) => type = t;
  void addReaction({required String user, required String emoji}) {
    if (reactions.any((e) => e.emoji == emoji)) {
      final toUpdate = reactions.firstWhere((e) => e.emoji == emoji);
      toUpdate.ids.add(user);
      db.updateConversationReaction(toUpdate.ids, id);
    } else {
      final newReaction = MessageReaction(emoji: emoji, ids: [user]);
      db.insertConversationReaction(newReaction, id);
      reactions.add(newReaction);
    }
  }

  void removeReaction({required String user, required String emoji}) {
    if (reactions.any((e) => e.emoji == emoji)) {
      final reaction = reactions.firstWhere((e) => e.emoji == emoji);
      reaction.ids.remove(user);
      if (reaction.ids.isEmpty) {
        db.deleteConversationReaction(id, emoji);
        reactions.remove(reaction);
      } else {
        db.updateGroupReaction(reaction.ids, id);
      }
    } else {
      throw Exception("Tried to remove a non existing reaction");
    }
  }

  Message copyWith({
    String? id,
    dynamic? content,
    String? from,
    String? to,
    String? type,
    DateTime? timeStamp,
    bool? read,
    List<MessageReaction>? reactions,
    DateTime? updatedAt,
    bool? deleted,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      from: from ?? this.from,
      to: to ?? this.to,
      type: type ?? this.type,
      timeStamp: timeStamp ?? this.timeStamp,
      read: read ?? this.read,
      reactions: reactions ?? this.reactions,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }
}
