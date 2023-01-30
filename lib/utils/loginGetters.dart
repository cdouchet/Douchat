import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/models/conversations/conversation.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/friend_request.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/profile_photo.dart';
import 'package:douchat3/routes/router.dart';
import 'package:douchat3/utils/notification_photo_registar.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';

class LoginGetters {
  static Future<bool> getEverythingAndLogin(
      {required BuildContext context,
      required String u,
      required String p}) async {
    final log = await Api.login(username: u, password: p);
    Utils.logger.i("Response login : ${log.body}");
    if (log.statusCode == 200) {
      final clientProvider =
          Provider.of<ClientProvider>(context, listen: false);
      final dynamic decodedResponse = jsonDecode(log.body);
      clientProvider.setAccessToken(decodedResponse['payload']['access_token']);
      final clientId = decodedResponse['payload']['client']['id'];
      final dbData = await db.retrieveMessagesAndGroups();
      final List<Group> groups = dbData.item2;
      final List<Message> dbMessages = dbData.item1;
      final List<User> dbUsers = dbData.item3;
      final groupsAndConversations =
          await Api.getGroupsAndConversationMessages();
      final decodedGroupsAndConversations =
          jsonDecode(groupsAndConversations.body);
      final grps = decodedGroupsAndConversations["groups"];
      final List<Group> parsedApiGroups =
          (grps as List).map((g) => Group.fromJson(g)).toList();
      final convs = decodedGroupsAndConversations["conversations"];
      final List<Message> parsedApiConversations =
          (convs as List).map((c) => Message.fromJson(c)).toList();
      final apiUsers = await Api.getUsers(clientId: clientId);
      final List<User> users = (jsonDecode(apiUsers.body)['payload']['users']
              as List)
          .map((e) => User.fromJson(e))
          .toList(); // final mes = await Api.getConversationMessages(clientId: clientId);
      // final messages = (jsonDecode(mes.body)['payload']['messages'] as List)
      //     .map((e) => Message.fromJson(e))
      //     .toList();
      dbMessages.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
      List<Conversation> conversations = users
          .map((u) => Conversation(
              messages: dbMessages
                  .where((m) =>
                      (m.from == u.id && m.to == clientId) ||
                      (m.from == clientId && m.to == u.id))
                  .toList(),
              user: u))
          .toList();
      // final client = decodedResponse['payload']['client'];
      // final grps = await Api.getGroups(clientId: clientId);
      // final List<Group> groups =
      //     (grps as List).map((g) => Group.fromJson(g)).toList();

      users.removeWhere((u) => u.id == clientId);
      List<DouchatNotificationIcon> icons = [];
      for (int i = 0; i < users.length; i++) {
        Uint8List? bytes;
        if (users[i].photoUrl == '') {
          bytes = (await Api.getContactPhoto(url: users[i].photoUrl)).bodyBytes;
        }
        if (bytes != null) {
          bytes =
              await FlutterImageCompress.compressWithList(bytes, quality: 20);
        }
        icons.add(DouchatNotificationIcon(id: users[i].id, bytes: bytes));
      }
      NotificationPhotoRegistar.populate(icons);
      NotificationPhotoRegistar.setup();
      final apiFriendRequests = await Api.getFriendRequests(clientId: clientId);
      final List<FriendRequest> friendRequests =
          (jsonDecode(apiFriendRequests.body)['payload']['friend_requests']
                  as List)
              .map((e) => FriendRequest.fromJson(e))
              .toList();

      List<DouchatNotificationIcon> groupIcons = [];
      for (int i = 0; i < groups.length; i++) {
        Uint8List? bytes;
        if (groups[i].photoUrl != null) {
          bytes =
              (await Api.getContactPhoto(url: groups[i].photoUrl!)).bodyBytes;
        }
        if (bytes != null) {
          bytes =
              await FlutterImageCompress.compressWithList(bytes, quality: 20);
        }
        groupIcons.add(DouchatNotificationIcon(id: groups[i].id, bytes: bytes));
      }
      NotificationPhotoRegistar.populateGroup(groupIcons);
      // final gmes =
      //     await Api.getGroupsMessages(groups: groups.map((e) => e.id).toList());
      // final List<GroupMessage> groupMessages = (jsonDecode(gmes.body)['payload']['messages'] as List).map((e) => GroupMessage.fromJson(e)).toList();
      // for (final Group group in groups) {
      //   final List<GroupMessage> gm = groupMessages.where((m) => m.group == group.id).toList();
      //   Utils.logger.i('Hello les messages', gm);
      //   group.populate(gm);
      // }

      await CompositionRoot.configure(
          decodedResponse['payload']['client']['id'],
          freshRegister: false);

      Navigator.pushReplacementNamed(context, home, arguments: {
        'client': User.fromJson(decodedResponse['payload']['client']),
        'users': users,
        'messages': dbMessages,
        'conversations': conversations,
        'groups': groups,
        'friendRequests': friendRequests,
        'newGroups': parsedApiGroups,
        'newConversations': parsedApiConversations,
      });
      return true;
    } else {
      final decoded = jsonDecode(log.body)["payload"]["error"];
      print(log.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(decoded)));
      return false;
    }
  }

  static Future<bool> getEverythingAndRegister(
      {required BuildContext context,
      required String u,
      required String e,
      required String p}) async {
    final photoUrl = await Api.uploadProfilePicture(
        Provider.of<ProfilePhotoProvider>(context, listen: false).photoFile);
    print("photoUrl$photoUrl");
    final res = await Api.register(
        username: u, password: p, photoUrl: photoUrl, email: e);
    Utils.logger.e("Could not register : ${res.body}");
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body)['payload'];
      final clientProvider =
          Provider.of<ClientProvider>(context, listen: false);
      clientProvider.setAccessToken(decoded['token']);
      clientProvider.getAccessToken().then((value) => print(value));
      final String clientId = decoded['new_user']['id'];
      await CompositionRoot.configure(clientId, freshRegister: true);
      CompositionRoot.userService
          .sendCreatedUser(User.fromJson(decoded['new_user']));
      List<User> users = [];
      List<Message> messages = [];
      List<Conversation> conversations = [];
      List<Group> groups = [];
      List<FriendRequest> friendRequests = [];
      NotificationPhotoRegistar.setup();
      Navigator.pushReplacementNamed(context, home, arguments: {
        'client': User.fromJson(decoded['new_user']),
        'users': users,
        'messages': messages,
        'conversations': conversations,
        'groups': groups,
        'friendRequests': friendRequests
      });
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(res.body)['payload']['error'])));
      return false;
    }
  }
}
