import 'dart:convert';
import 'dart:io';

import 'package:douchat3/api/interceptors/global_interceptor.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/http.dart';

class Api {
  // static const String baseUrl = "https://cloud.doggo-saloon.net:2585";
  static String baseUrl = "https://${dotenv.env["DOUCHAT_URI"]}";
  static Client client =
      InterceptedClient.build(interceptors: [GlobalInterceptor()]);
  static Future<Response> register(
      {required String username,
      required String password,
      required String email,
      String? photoUrl}) async {
    return await post(Uri.parse("$baseUrl/register"), body: {
      'username': username,
      'password': password,
      'email': email,
      'photoUrl': photoUrl ?? "null",
      'firebase_token': await FirebaseMessaging.instance.getToken()
    });
  }

  static Future<Response> login(
      {required String username, required String password}) async {
    return await post(Uri.parse("$baseUrl/login"), body: {
      'username': username,
      'password': password,
      'firebase_token': await FirebaseMessaging.instance.getToken()
    });
  }

  static Future<Response> resetPassword({required String email}) async {
    return await post(Uri.parse("$baseUrl/resetPassword"),
        body: {"email": email});
  }

  static Future<Response> confirmResetPassword(
      {required String token, required String password}) async {
    return await post(Uri.parse("$baseUrl/confirmResetPassword"),
        body: {"token": token, "password": password});
  }

  static Future<Response> isConnected(String token) async {
    return await post(Uri.parse("$baseUrl/isConnected"),
        body: {'token': token});
  }

  static Future<Response> addContact(
      {required String id, required String clientId}) async {
    return await client.post(Uri.parse('$baseUrl/addContact'),
        body: {'id': id, 'clientId': clientId});
  }

  static Future<Response> getContactPhoto({required String url}) async {
    return await client.get(Uri.parse(url));
  }

  static Future<Response> getFriendRequests({required String clientId}) async {
    return await client
        .get(Uri.parse("$baseUrl/getFriendRequests?clientId=$clientId"));
  }

  static Future<Response> respondToFriendRequest(
      {required String clientId,
      required String id,
      required String userId,
      required bool accept}) async {
    return await client.post(Uri.parse("$baseUrl/respondToFriendRequest"),
        body: {
          'clientId': clientId,
          'id': id,
          'accept': accept,
          'userId': userId
        });
  }

  static Future<Response> getUsers({required String clientId}) async {
    return await client.get(Uri.parse('$baseUrl/getUsers?clientId=$clientId'));
  }

  static Future<Response> getUserFromId({required String id}) async {
    return await client.get(Uri.parse('$baseUrl/getUserFromId?id=$id'));
  }

  static Future<Response> doUsernameExists(String username) async {
    return await client
        .get(Uri.parse('$baseUrl/doUsernameExists?username=$username'));
  }

  static Future<String?> uploadProfilePicture(File? file) async {
    if (file == null) {
      return null;
    }
    final request = MultipartRequest(
        'POST', Uri.parse("$baseUrl/uploadFile/profilePicture"));
    request.files.add(await MultipartFile.fromPath('picture', file.path));
    final result = await request.send();
    // print((await Response.fromStream(result)).body);
    if (result.statusCode != 200) return null;
    final response = await Response.fromStream(result);

    return '${Uri.parse("$baseUrl/uploadFile/profilePicture").origin}${response.body}';
  }

  static Future<String?> uploadFile(
      {required File? file,
      required String type,
      required String thread}) async {
    try {
      if (file == null) {
        return null;
      }
      final request = MultipartRequest('POST',
          Uri.parse('$baseUrl/uploadFile/media?type=$type&thread=$thread'))
        ..files.add(await MultipartFile.fromPath('picture', file.path));

      final result = await request.send();
      final response = await Response.fromStream(result);
      if (response.statusCode == 200) {
        Utils.logger.i(
            'success! Url : ${Uri.parse("$baseUrl/uploadFile/media").origin}${response.body}');
        return 'https://${dotenv.env["DOUCHAT_URI"]}${response.body}';
      }
      return null;
    } catch (e, s) {
      Utils.logger.i(e);
      Utils.logger.i(s);
      return null;
    }
  }

  static Future<String?> uploadGroupPicture(
      {required File? file, required String id}) async {
    try {
      if (file == null) {
        return null;
      }
      final request = MultipartRequest(
          'POST', Uri.parse('$baseUrl/uploadGroupPhoto?group=$id'))
        ..files.add(await MultipartFile.fromPath('picture', file.path))
        ..fields.addAll({'group': id});
      final result = await request.send();
      final response = await Response.fromStream(result);
      if (response.statusCode == 200) {
        Utils.logger.i(
            'success! Url : ${Uri.parse("$baseUrl/uploadGroupPhoto/media").origin}/api/${response.body}');
        return '${Uri.parse("$baseUrl/uploadGroupPhoto/media").origin}/api/${response.body}';
      }
      return null;
    } catch (e, s) {
      Utils.logger.i('Error while processing group image upload', e, s);
      return null;
    }
  }

  static Future<Response> getGroupsAndConversationMessages() async {
    return await client
        .get(Uri.parse("$baseUrl/getGroupsAndConversationMessages"));
  }

  static Future<Response> getConversationMessages(
      {required String clientId}) async {
    return await client
        .get(Uri.parse('$baseUrl/getConversationMessages?clientId=$clientId'));
  }

  static Future<Response> createGroup(
      {required String groupName,
      required List<String> users,
      required String creator}) async {
    Utils.logger.i('JSON ENCODE : ' +
        jsonEncode({'name': groupName, 'users': users, 'admin': creator}));
    return await client.post(
      Uri.parse('$baseUrl/createGroup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': groupName, 'users': users, 'admin': creator}),
    );
  }

  static Future<Response> getGroups({required String clientId}) async {
    return await client.get(Uri.parse('$baseUrl/getGroups?clientId=$clientId'));
  }

  static Future<Response> getGroupsMessages(
      {required List<String> groups}) async {
    return await client.post(Uri.parse('$baseUrl/getGroupMessages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'groups': groups}));
  }

  static Future<Response> removeContact(String userToRemove) async {
    return await client
        .delete(Uri.parse("$baseUrl/removeContact?u=$userToRemove"));
  }

  static Future<Response> updateFirebaseToken(String token) async {
    return await client.post(Uri.parse("$baseUrl/updateFirebaseToken"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'firebase_token': token}));
  }

  static Future<Response> updateEmail(String email) async {
    return await client.post(Uri.parse("$baseUrl/updateEmail"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email}));
  }

  static Future<Response> deleteAccount(String password) async {
    return await client.post(
      Uri.parse("$baseUrl/deleteAccount"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {"password": password},
      ),
    );
  }
}
