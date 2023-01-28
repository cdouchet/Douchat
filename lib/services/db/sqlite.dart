import 'dart:convert';

import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

class DouchatDBSQLite {
  late Database db;

  DouchatDBSQLite() {
    _initDb();
  }

  void insertConversationReaction(Reaction) {}

  void deleteConversationMessage(String id) {
    db.delete("conversations", where: "id = ?", whereArgs: [id]);
  }

  void updateConversationMessage(Message message) {
    db.update("conversations", message.toJson(),
        where: "id = ?", whereArgs: [message.id]);
  }

  void insertConversationMessage(Message message) {
    db.insert("conversations", message.toJson());
  }

  Future<Tuple3<List<Message>, List<Group>, List<User>>>
      retrieveMessagesAndGroups() async {
    final conversationsQuery = await db.query("conversations");
    final conversationReactionsQuery = await db.query("conversationReactions");
    final groupQuery = await db.query("groups");
    final groupMessagesQuery = await db.query("groupMessages");
    final groupMessagesReactionsQuery = await db.query("groupReactions");
    final usersQuery = await db.query("users");
    final conversations = conversationsQuery.map<Message>((e) {
      e["reactions"] = conversationReactionsQuery
          .where((r) => r["message"] == e["id"])
          .map((r) {
        r["ids"] = jsonDecode(r["ids"] as String);
        return r;
      });
      return Message.fromJson(e);
    }).toList();
    final groups = groupQuery.map<Group>((e) {
      e["users"] = jsonDecode(e["users"] as String);
      e["messages"] =
          groupMessagesQuery.where((gm) => gm["group"] == e["id"]).map((gm) {
        gm["reactions"] = groupMessagesReactionsQuery
            .where((gmr) => gmr["message"] == gm["id"])
            .map((gmr) {
          gmr["ids"] = jsonDecode(gmr["ids"] as String);
          return gmr;
        });
        return gm;
      });
      return Group.fromJson(e);
    }).toList();
    final users = usersQuery.map<User>((u) {
      u["contacts"] = jsonDecode(u["contacts"] as String);
      return User.fromJson(u);
    }).toList();
    return Tuple3(conversations, groups, users);
  }

  _createTables(Database db, int version) async {
    await db.execute("""
      CREATE TABLE conversationReactions (
        id TEXT PRIMARY KEY,
        message TEXT NOT NULL,
        emoji TEXT NOT NULL,
        ids TEXT NOT NULL,
        updated_at TEXT NOT NULL
        )
      """);
    await db.execute("""
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        from TEXT NOT NULL,
        to TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        read TEXT NOT NULL,
        reactions TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted TEXT NOT NULL
        )
      """);
    await db.execute("""
      CREATE TABLE groupMessages (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        group TEXT NOT NULL,
        from TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        read_by TEXT NOT NULL,
        reactions TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted TEXT NOT NULL
      )
      """);
    await db.execute("""
      CREATE TABLE groupReactions (
        id TEXT PRIMARY KEY,
        message TEXT NOT NULL,
        emoji TEXT NOT NULL,
        ids TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      """);
    await db.execute("""
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        users TEXT NOT NULL,
        name TEXT NOT NULL,
        photo_url TEXT,
        messages TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      """);
    await db.execute("""
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        username TEXT NOT NULL,
        photo_url TEXT,
        online TEXT NOT NULL,
        contacts TEXT NOT NULL
      )
      """);
  }

  _initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + "/douchat.db";
    db = await openDatabase(path, version: 1, onCreate: _createTables);
  }
}
