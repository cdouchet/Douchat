import 'package:intl/intl.dart';

class Message {
  final String id;
  dynamic content;
  final String from;
  final String to;
  String type;
  final DateTime timeStamp;
  bool read;

  Message({
    required this.id,
    required this.content,
    required this.from,
    required this.to,
    required this.type,
    required this.timeStamp,
    required this.read,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "content": content,
        "from": from,
        "to": to,
        "type": type,
        "timestamp": DateFormat().format(timeStamp),
        "read": read,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        content: json['content'],
        from: json['from'],
        to: json['to'],
        type: json['type'],
        timeStamp: DateFormat().parse(json['timestamp']),
        read: json['read'],
      );

  void updateMessageState(bool update) => read = update;
  void updateTypeState(String t) => type = t;
}
