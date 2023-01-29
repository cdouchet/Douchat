import 'package:douchat3/models/conversation_or_group.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';

class Group implements ConversationOrGroup {
  String id;
  List<User> users;
  List<GroupMessage> messages;
  String? photoUrl;
  String name;
  String admin;
  Group(
      {required this.id,
      required this.users,
      required this.messages,
      required this.photoUrl,
      required this.name,
      required this.admin});

  Map<String, dynamic> toJson() => {
        'users': users.map((u) => u.toJson()).toList(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'photo_url': photoUrl,
        'name': name,
        'admin': admin
      };

  factory Group.fromJson(Map<String, dynamic> json) {
    final List<GroupMessage> ms = (json['messages'] as List)
        .map((e) => GroupMessage.fromJson(e))
        .toList();
    final List<User> us =
        (json['users'] as List).map((e) => User.fromJson(e)).toList();
    return Group(
        id: json['id'],
        users: us,
        messages: ms,
        photoUrl: json['photoUrl'] ?? json["photo_url"],
        name: json['name'],
        admin: json['admin']);
  }

  void populate(List<GroupMessage> population) {
    messages = population;
  }

  void updateName(String n) => name = n;
  void updatePhotoUrl(String? p) => photoUrl = p;
  void updateAdmin(String a) => admin = a;
  void removeUser(String id) => users.removeWhere((u) => u.id == id);
  void addUser(User u) => users.add(u);
  void updateUsers(List<User> us) => users = us;
}
