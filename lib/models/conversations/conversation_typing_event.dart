import 'package:douchat3/models/user.dart';

enum TypingType { start, stop }

extension TypingTypeParsing on TypingType {
  String value() {
    return toString().split('.').last;
  }

  static TypingType fromString(String typingType) {
    return TypingType.values
        .firstWhere((element) => element.value() == typingType);
  }
}

class ConversationTypingEvent {
  final User from;
  final User to;
  final TypingType typingType;

  ConversationTypingEvent(
      {required this.from, required this.to, required this.typingType});

  Map<String, dynamic> toJson() => {
        'from': from.toJson(),
        'to': to.toJson(),
        'typingType': typingType.value()
      };

  factory ConversationTypingEvent.fromJson(Map<String, dynamic> json) =>
      ConversationTypingEvent(
          from: User.fromJson(json['from']),
          to: User.fromJson(json['to']),
          typingType: TypingTypeParsing.fromString(json['typingType']));
}
