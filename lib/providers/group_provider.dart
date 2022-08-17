import 'package:douchat3/models/group.dart';
import 'package:flutter/widgets.dart';

class GroupProvider extends ChangeNotifier {
  late List<Group> _groups;
  List<Group> get groups => _groups;

  void setConversations(List<Group> newGroups) {
    _groups = newGroups;
    notifyListeners();
  }
}
