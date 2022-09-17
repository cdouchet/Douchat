import 'dart:convert';
import 'dart:io';

import 'package:douchat3/api/interceptors/global_interceptor.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/http.dart';

class Api {
  // static const String baseUrl = "https://cloud.doggo-saloon.net:2585";
  static String baseUrl = "http://${dotenv.env["DOUCHAT_URI"]}:2585";
  static Client client =
      InterceptedClient.build(interceptors: [GlobalInterceptor()]);
  static Future<Response> register(
      {required String username,
      required String password,
      String? photoUrl}) async {
    return await post(Uri.parse("$baseUrl/register"), body: {
      'username': username,
      'password': password,
      'photoUrl': photoUrl ?? "null"
    });
  }

  static Future<Response> login(
      {required String username, required String password}) async {
    return await post(Uri.parse("$baseUrl/login"),
        body: {'username': username, 'password': password});
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
    if (result.statusCode != 200) return null;
    final response = await Response.fromStream(result);
    return '${Uri.parse("$baseUrl/uploadFile/profilePicture").origin}/${response.body}';
  }

  static Future<String?> uploadFile(
      {required File? file, required String type}) async {
    try {
      if (file == null) {
        return null;
      }
      final request = MultipartRequest(
          'POST', Uri.parse('$baseUrl/uploadFile/media?type=$type'))
        ..files.add(await MultipartFile.fromPath('picture', file.path));

      final result = await request.send();
      final response = await Response.fromStream(result);
      if (response.statusCode == 200) {
        Utils.logger.i(
            'success! Url : ${Uri.parse("$baseUrl/uploadFile/media").origin}/${response.body}');
        return '${Uri.parse("$baseUrl/uploadFile/media").origin}/${response.body}';
      }
      return null;
    } catch (e, s) {
      Utils.logger.i(e);
      Utils.logger.i(s);
      return null;
    }
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
}
