import 'package:douchat3/main.dart';
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
    db.insertGroup(g);
    notifyListeners();
  }

  void removeGroup(String id) {
    _groups.removeWhere((g) => g.id == id);
    db.deleteGroup(id);
    notifyListeners();
  }

  void addGroupMessage(GroupMessage gm) {
    _groups.firstWhere((g) => g.id == gm.group).messages.insert(0, gm);
    db.insertGroupMessage(gm);
    notifyListeners();
  }

  void sortMessages() {
    _groups.forEach((g) {
      g.messages.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    });
    notifyListeners();
  }

  bool doGroupMessageExists(String id) {
    return _groups.any((g) => g.messages.any((m) => m.id == id));
  }

  void updateListGroupMessage(List<GroupMessage> msgs) {
    bool didBreak = false;
    List<String> msgsStr = msgs.map((e) => e.id).toList();
    for (int i = 0; i < _groups.length; i++) {
      if (didBreak) {
        break;
      }
      for (int j = 0; j < _groups[i].messages.length; j++) {
        if (didBreak) {
          break;
        }
        for (int k = 0; k < msgsStr.length; k++) {
          if (msgsStr.contains(_groups[i].messages[j].id)) {
            _groups[i].messages.replaceRange(j, j + 1, [msgs[k]]);
            msgsStr.removeAt(k);
            msgs.removeAt(k);
            db.updateGroupMessage(msgs[k]);
            if (msgsStr.isEmpty) {
              didBreak = true;
              break;
            }
          }
        }
      }
    }
    notifyListeners();
  }

  bool doGroupExists(String id) {
    return _groups.any((g) => g.id == id);
  }

  void updateGroup(Group g) {
    final grp = _groups.firstWhere((gr) => g.id == gr.id);
    grp.updateName(g.name);
    grp.updatePhotoUrl(g.photoUrl);
    grp.updateAdmin(g.admin);
    grp.updateUsers(g.users);
    db.updateGroup(g);
    notifyListeners();
  }

  void updateGroupMessage(GroupMessage msg) {
    bool didBreak = false;
    for (int i = 0; i < _groups.length; i++) {
      for (int j = 0; j < _groups[i].messages.length; j++) {
        if (_groups[i].messages[j].id == msg.id) {
          _groups[i].messages.replaceRange(j, j + 1, [msg]);
          db.updateGroupMessage(msg);
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

  void removeGroupMessage(String id) {
    bool didBreak = false;
    for (Group g in _groups) {
      for (GroupMessage m in g.messages) {
        if (m.id == id) {
          _groups
              .elementAt(_groups.indexOf(g))
              .messages
              .removeWhere((e) => e.id == id);
          db.deleteGroupMessage(id);
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

  void updateReadState(
      {required List<String> messagesToUpdate,
      required String groupId,
      required String readBy,
      required bool notify}) {
    final msgs = _groups.firstWhere((g) => g.id == groupId).messages;
    for (int i = 0; i < messagesToUpdate.length; i++) {
      final toUpdate = msgs.firstWhere((m) => m.id == messagesToUpdate[i]);
      toUpdate.updateMessageReadState(readBy);
      db.updateGroupMessage(toUpdate);
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
    db.updateGroup(_getGroup(id));
    notifyListeners();
  }

  void updateGroupPhoto({required String url, required String id}) {
    _getGroup(id).updatePhotoUrl(url);
    db.updateGroup(_getGroup(id));
    notifyListeners();
  }

  void updateGroupAdmin({required String admin, required String id}) {
    _getGroup(id).updateAdmin(admin);
    db.updateGroup(_getGroup(id));
    notifyListeners();
  }

  void removeUser({required String userId, required String id}) {
    _getGroup(id).removeUser(userId);
    db.updateGroup(_getGroup(id));
    notifyListeners();
  }

  void addUser({required User user, required String id}) {
    _getGroup(id).addUser(user);
    db.updateGroup(_getGroup(id));
    notifyListeners();
  }

  void addReaction(
      {required String id, required String userId, required String emoji}) {
    bool didBreak = false;
    for (Group g in _groups) {
      for (GroupMessage m in g.messages) {
        if (m.id == id) {
          final toUpdate = _groups
              .elementAt(_groups.indexOf(g))
              .messages
              .firstWhere((e) => e.id == id);
          // db actions are inside the below function
          toUpdate.addReaction(user: userId, emoji: emoji);
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
              // db actions are inside the below function
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
