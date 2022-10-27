class MessageReaction {
  final String emoji;
  final List<String> ids;

  const MessageReaction({required this.emoji, required this.ids});

  Map<String, dynamic> toJson() => {"emoji": emoji, "ids": ids};

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      MessageReaction(emoji: json["emoji"], ids: json["ids"].cast<String>());
}
