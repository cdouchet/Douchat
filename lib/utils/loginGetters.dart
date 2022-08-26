import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/profile_photo.dart';
import 'package:douchat3/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginGetters {
  static Future<bool> getEverythingAndLogin(
      {required BuildContext context,
      required String u,
      required String p}) async {
    final log = await Api.login(username: u, password: p);
    if (log.statusCode == 200) {
      final clientProvider =
          Provider.of<ClientProvider>(context, listen: false);
      final dynamic decodedResponse = jsonDecode(log.body);
      clientProvider.setAccessToken(decodedResponse['payload']['access_token']);
      final clientId = decodedResponse['payload']['client']['id'];
      final apiUsers = await Api.getUsers(clientId: clientId);
      final List<User> users =
          (jsonDecode(apiUsers.body)['payload']['users'] as List)
              .map((e) => User.fromJson(e))
              .toList();
      users.removeWhere((u) => u.id == clientId);
      final mes = await Api.getConversationMessages(clientId: clientId);
      final messages = (jsonDecode(mes.body)['payload']['messages'] as List)
          .map((e) => Message.fromJson(e))
          .toList();
      messages.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
      List<Conversation> conversations = users
          .map((u) => Conversation(
              messages: messages
                  .where((m) =>
                      (m.from == u.id && m.to == clientId) ||
                      (m.from == clientId && m.to == u.id))
                  .toList(),
              user: u))
          .toList();
      final client = decodedResponse['payload']['client'];
      final grps = await Api.getGroups(clientId: clientId);
      final List<Group> groups =
          (jsonDecode(grps.body)['payload']['groups'] as List)
              .map((g) => Group.fromJson(g))
              .toList();

      CompositionRoot.configure(decodedResponse['payload']['client']['id'],
          freshRegister: false);

      Navigator.pushReplacementNamed(context, home, arguments: {
        'client': User.fromJson(decodedResponse['payload']['client']),
        'users': users,
        'messages': messages,
        'conversations': conversations,
        'groups': groups
      });
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(log.body)['payload']['error'])));
      return false;
    }
  }

  static Future<bool> getEverythingAndRegister(
      {required BuildContext context,
      required String u,
      required String p}) async {
    final photoUrl = await Api.uploadProfilePicture(
        Provider.of<ProfilePhotoProvider>(context, listen: false).photoFile);
    print("photoUrl$photoUrl");
    final res =
        await Api.register(username: u, password: p, photoUrl: photoUrl);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body)['payload'];
      final clientProvider =
          Provider.of<ClientProvider>(context, listen: false);
      clientProvider.setAccessToken(decoded['token']);
      clientProvider.getAccessToken().then((value) => print(value));
      final String clientId = decoded['new_user']['id'];
      CompositionRoot.configure(clientId, freshRegister: true);
      CompositionRoot.userService
          .sendCreatedUser(User.fromJson(decoded['new_user']));
      List<User> users = [];
      List<Message> messages = [];
      List<Conversation> conversations = [];
      List<Group> groups = [];
      Navigator.pushReplacementNamed(context, home, arguments: {
        'client': User.fromJson(decoded['new_user']),
        'users': users,
        'messages': messages,
        'conversations': conversations,
        'groups': groups
      });
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(res.body)['payload']['error'])));
      return false;
    }
  }
}
