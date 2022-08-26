import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:flutter/material.dart';

class GroupProvider extends ChangeNotifier {
  late List<Group> _groups;
  List<Group> get groups => _groups;

  void setGroups(List<Group> g) {
    _groups = g;
  }

  Group getConversation(String i) => _groups.firstWhere((g) => g.id == i);

  void addGroup(Group g) {
    _groups.add(g);
    notifyListeners();
  }

  void addGroupMessage(GroupMessage gm) {
    _groups.firstWhere((g) => g.id == gm.group).messages.insert(0, gm);
    notifyListeners();
  }
}
