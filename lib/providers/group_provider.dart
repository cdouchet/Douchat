import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
import 'package:flutter/material.dart';

class GroupProvider extends ChangeNotifier {
  late List<Group> _groups;
  List<Group> get groups => _groups;

  void setGroups(List<Group> g) {
    _groups = g;
  }

  Group getGroup(String i) => _groups.firstWhere((g) => g.id == i);

  void addGroup(Group g) {
    _groups.add(g);
    notifyListeners();
  }

  void removeGroup(String id) {
    _groups.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  void addGroupMessage(GroupMessage gm) {
    _groups.firstWhere((g) => g.id == gm.group).messages.insert(0, gm);
    notifyListeners();
  }

  void removeGroupMessage(String id) {
    bool didBreak = false;
    for (Group g in _groups) {
      for (GroupMessage m in g.messages) {
        if (m.id == id) {
          _groups
              .elementAt(_groups.indexOf(g))
              .messages
              .removeWhere((e) => e.id == id);
          didBreak = true;
          break;
        }
      }
      if (didBreak) {
        break;
      }
    }
  }

  void updateReadState(
      {required List<String> messagesToUpdate,
      required String groupId,
      required String readBy,
      required bool notify}) {
    final msgs = _groups.firstWhere((g) => g.id == groupId).messages;
    for (int i = 0; i < messagesToUpdate.length; i++) {
      msgs
          .firstWhere((m) => m.id == messagesToUpdate[i])
          .updateMessageReadState(readBy);
    }
    if (notify) {
      notifyListeners();
    }
  }

  void addTempMessages(List<GroupMessage> gs) {
    final Group g = _groups.firstWhere((g) => g.id == gs.first.group);
    for (final GroupMessage gm in gs) {
      g.messages.insert(0, gm);
    }
    notifyListeners();
  }

  void removeTempMessage({required String mId, required String gId}) {
    _groups
        .firstWhere((g) => g.id == gId)
        .messages
        .removeWhere((e) => e.id == mId);
    notifyListeners();
  }

  void updateTempMessageState(
      {required String gId, required String mId, required String nT}) {
    _groups
        .firstWhere((g) => g.id == gId)
        .messages
        .firstWhere((m) => m.id == mId)
        .updateTypeState(nT);
    notifyListeners();
  }

  Group _getGroup(String id) => _groups.firstWhere((g) => g.id == id);

  void updateGroupName({required String name, required String id}) {
    _getGroup(id).updateName(name);
    notifyListeners();
  }

  void updateGroupPhoto({required String url, required String id}) {
    _getGroup(id).updatePhotoUrl(url);
    notifyListeners();
  }

  void updateGroupAdmin({required String admin, required String id}) {
    _getGroup(id).updateAdmin(admin);
    notifyListeners();
  }

  void removeUser({required String userId, required String id}) {
    _getGroup(id).removeUser(userId);
    notifyListeners();
  }

  void addUser({required User user, required String id}) {
    _getGroup(id).addUser(user);
    notifyListeners();
  }

  void addReaction(
      {required String id, required String userId, required String emoji}) {
    bool didBreak = false;
    for (Group g in _groups) {
      for (GroupMessage m in g.messages) {
        if (m.id == id) {
          _groups
              .elementAt(_groups.indexOf(g))
              .messages
              .firstWhere((e) => e.id == id)
              .addReaction(user: userId, emoji: emoji);
          didBreak = true;
          break;
        }
      }
      if (didBreak) {
        break;
      }
    }
    notifyListeners();
  }

  void removeReaction(
      {required String id, required String userId, required String emoji}) {
    bool didBreak = false;
    for (Group g in _groups) {
      for (GroupMessage m in g.messages) {
        if (m.id == id) {
          _groups
              .elementAt(_groups.indexOf(g))
              .messages
              .firstWhere((e) => e.id == id)
              .removeReaction(user: userId, emoji: emoji);
          didBreak = true;
          break;
        }
      }
      if (didBreak) {
        break;
      }
    }
    notifyListeners();
  }
}
