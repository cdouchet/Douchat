import 'package:intl/intl.dart';

class GroupMessage {
  final String id;
  dynamic content;
  final String group;
  final String from;
  String type;
  final DateTime timeStamp;
  List<String> readBy;

  GroupMessage(
      {required this.id,
      required this.content,
      required this.group,
      required this.from,
      required this.type,
      required this.timeStamp,
      required this.readBy});

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'from': from,
        'type': type,
        'timestamp': DateFormat().format(timeStamp),
        'readBy': readBy
      };

  factory GroupMessage.fromJson(Map<String, dynamic> json) => GroupMessage(
      id: json['id'],
      content: json['content'],
      group: json['group'],
      from: json['from'],
      type: json['type'],
      timeStamp: DateFormat().parse(json['timestamp']),
      readBy: json['readBy'].cast<String>());

  void updateMessageReadState(String userId) => readBy.add(userId);
  void updateTypeState(String t) => type = t;
}
