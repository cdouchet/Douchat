import 'dart:convert';

import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/conversations/message_reaction.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

import '../../models/groups/group_message.dart';

class DouchatDBSQLite {
  late Database db;

  DouchatDBSQLite() {}

  void deleteGroupReaction(String messageId, String emoji) {
    db.rawDelete(
        "DELETE FROM conversationReactions WHERE message = ? AND emoji = ?",
        [messageId, emoji]);
  }

  void updateGroupReaction(List<String> ids, String messageId) {
    db.rawUpdate("UPDATE groupReactions SET ids = ? WHERE message = ?",
        [jsonEncode(ids), messageId]);
  }

  void insertGroupReaction(MessageReaction reaction, String messageId) {
    Map<String, dynamic> toJson = reaction.toJson();
    toJson["message"] = messageId;
    toJson["ids"] = jsonEncode(toJson["ids"]);
    db.insert("groupReactions", toJson);
  }

  void deleteGroupMessage(String id) {
    db.delete("groupMessages", where: "id = ?", whereArgs: [id]);
  }

  void updateGroupMessage(GroupMessage message) {
    Map<String, dynamic> toJson = message.toJson();
    toJson["from_id"] = toJson["from"];
    toJson.remove("from");
    toJson["group_id"] = toJson["group"];
    toJson.remove("group");
    toJson["readBy"] = jsonEncode(toJson["readBy"]);
    toJson.remove("reactions");
    toJson.remove("deleted");
    db.update("groupMessages", toJson,
        where: "id = ?", whereArgs: [message.id]);
  }

  void insertGroupMessage(GroupMessage message) {
    Map<String, dynamic> toJson = message.toJson();
    toJson["from_id"] = toJson["from"];
    toJson.remove("from");
    toJson["group_id"] = toJson["group"];
    toJson.remove("group");
    toJson["readBy"] = jsonEncode(toJson["readBy"]);
    toJson.remove("reactions");
    toJson.remove("deleted");
    db.insert("groupMessages", toJson);
  }

  void deleteConversationReaction(String messageId, String emoji) {
    db.rawDelete(
        "DELETE FROM conversationReactions WHERE message = ? AND emoji = ?",
        [messageId, emoji]);
  }

  void updateConversationReaction(List<String> ids, String messageId) {
    db.rawUpdate("UPDATE conversationReactions SET ids = ? WHERE message = ?",
        [jsonEncode(ids), messageId]);
  }

  void insertConversationReaction(MessageReaction reaction, String messageId) {
    Map<String, dynamic> toJson = reaction.toJson();
    toJson["message"] = messageId;
    toJson["ids"] = jsonEncode(toJson["ids"]);
    db.insert("conversationReactions", toJson);
  }

  void deleteConversationMessage(String id) {
    db.delete("conversations", where: "id = ?", whereArgs: [id]);
  }

  void updateConversationMessage(Message message) {
    Map<String, dynamic> toJson = message.toJson();
    toJson["from_id"] = toJson["from"];
    toJson.remove("from");
    toJson["to_id"] = toJson["to"];
    toJson.remove("to");
    toJson.remove("reactions");
    toJson["read"] = toJson["read"].toString();
    toJson.remove("deleted");
    db.update("conversations", toJson,
        where: "id = ?", whereArgs: [message.id]);
  }

  void insertConversationMessage(Message message) {
    Map<String, dynamic> toJson = message.toJson();
    toJson["from_id"] = toJson["from"];
    toJson.remove("from");
    toJson["to_id"] = toJson["to"];
    toJson.remove("to");
    toJson.remove("reactions");
    toJson["read"] = toJson["read"].toString();
    toJson.remove("deleted");
    db.insert("conversations", toJson);
  }

  void deleteGroup(String id) {
    db.delete("groups", where: "id = ?", whereArgs: [id]);
  }

  void updateGroup(Group group) {
    Map<String, dynamic> toJson = group.toJson();
    // for (int i = 0; i < (toJson["users"] as List).length; i++) {
    //   final u = toJson["users"][i];
    //   u["photo_url"] = u["photoUrl"];
    //   u["online"] = u["online"].toString();
    //   u.remove("photoUrl");
    // }
    toJson.remove("messages");
    toJson["users"] = jsonEncode(toJson["users"]);
    db.update("groups", toJson, where: "id = ?", whereArgs: [group.id]);
  }

  void insertGroup(Group group) {
    Map<String, dynamic> toJson = group.toJson();
    // for (int i = 0; i < (toJson["users"] as List).length; i++) {
    //   final u = toJson["users"][i];
    //   u["photo_url"] = u["photoUrl"];
    //   u["online"] = u["online"].toString();
    //   u.remove("photoUrl");
    // }
    toJson.remove("messages");
    toJson["users"] = jsonEncode(toJson["users"]);
    db.insert("groups", toJson);
  }

  void deleteUser(String id) {
    db.delete("users", where: "id = ?", whereArgs: [id]);
  }

  void updateUser(User user) {
    final toJson = user.toJson();
    toJson["photo_url"] = toJson["photoUrl"];
    toJson["online"] = toJson["online"].toString();
    toJson.remove("photoUrl");
    db.update("users", toJson, where: "id = ?", whereArgs: [user.id]);
  }

  void insertUser(User user) {
    final toJson = user.toJson();
    toJson["photo_url"] = toJson["photoUrl"];
    toJson["online"] = toJson["online"].toString();
    toJson.remove("photoUrl");
    db.insert("users", toJson);
  }

  Future<Tuple3<List<Message>, List<Group>, List<User>>>
      retrieveMessagesAndGroups() async {
    final cq = await db.query("conversations");
    List conversationsQuery =
        cq.map((row) => row.map((key, value) => MapEntry(key, value))).toList();
    final crq = await db.query("conversationReactions");
    List conversationReactionsQuery = crq
        .map((row) => row.map((key, value) => MapEntry(key, value)))
        .toList();
    final gq = await db.query("groups");
    List groupQuery =
        gq.map((row) => row.map((key, value) => MapEntry(key, value))).toList();
    final gmq = await db.query("groupMessages");
    List groupMessagesQuery = gmq
        .map((row) => row.map((key, value) => MapEntry(key, value)))
        .toList();
    final gmrq = await db.query("groupReactions");
    List groupMessagesReactionsQuery = gmrq
        .map((row) => row.map((key, value) => MapEntry(key, value)))
        .toList();
    final uq = await db.query("users");
    List usersQuery =
        uq.map((row) => row.map((key, value) => MapEntry(key, value))).toList();
    final conversations = conversationsQuery.map<Message>((e) {
      e["reactions"] = conversationReactionsQuery
          .where((r) => r["message"] == e["id"])
          .map((r) {
        r["ids"] = jsonDecode(r["ids"] as String);
        return r;
      }).toList();
      e["from"] = e["from_id"];
      e["to"] = e["to_id"];
      return Message.fromJson(e);
    }).toList();
    Utils.logger.i("ALL GROUP MESSAGES : ${groupMessagesQuery}");
    final groups = groupQuery.map<Group>((e) {
      print(e);
      e["users"] = jsonDecode(e["users"] as String);
      Utils.logger.i(
          "Messages for group Test : ${groupMessagesQuery.where((gm) => gm["group_id"] == e["id"])}");
      e["messages"] = groupMessagesQuery
          .where((gm) => gm["group_id"] == e["id"])
          .map<Map<String, dynamic>>((gm) {
        gm["reactions"] = groupMessagesReactionsQuery
            .where((gmr) => gmr["message"] == gm["id"])
            .map((gmr) {
          gmr["ids"] = jsonDecode(gmr["ids"] as String);
          return gmr;
        }).toList();
        gm["from"] = gm["from_id"];
        gm["group"] = gm["group_id"];
        gm["readBy"] = jsonDecode(gm["readBy"]);
        return gm;
      }).toList();
      return Group.fromJson(e);
    }).toList();
    final users = usersQuery.map<User>((u) {
      return User.fromJson(u);
    }).toList();
    return Tuple3(conversations, groups, users);
  }

  _createTables(Database db, int version) async {
    await db.execute("""
      CREATE TABLE conversationReactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        emoji TEXT NOT NULL,
        ids TEXT NOT NULL
        )
      """);
    await db.execute("""
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        from_id TEXT NOT NULL,
        to_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        read TEXT NOT NULL,
        updated_at TEXT NOT NULL
        )
      """);
    await db.execute("""
      CREATE TABLE groupMessages (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        group_id TEXT NOT NULL,
        from_id TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        readBy TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      """);
    await db.execute("""
      CREATE TABLE groupReactions (
        id TEXT PRIMARY KEY,
        message TEXT NOT NULL,
        emoji TEXT NOT NULL,
        ids TEXT NOT NULL
      )
      """);
    await db.execute("""
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        users TEXT NOT NULL,
        admin TEXT NOT NULL,
        name TEXT NOT NULL,
        photo_url TEXT
      )
      """);
    await db.execute("""
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        photo_url TEXT,
        online TEXT NOT NULL
      )
      """);
  }

  initDb(String id) async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + "/$id.db";
    db = await openDatabase(path, version: 1, onCreate: _createTables);
  }
}
