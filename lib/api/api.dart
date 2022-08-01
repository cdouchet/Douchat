import 'dart:io';

import 'package:http/http.dart';

class Api {
  // static const String baseUrl = "https://cloud.doggo-saloon.net:2585";
  static const String baseUrl = "https://localhost:2585";
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
}
