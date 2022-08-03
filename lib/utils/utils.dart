import 'dart:convert';

import 'package:douchat3/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

class Utils {
  static Logger logger = Logger();

  static Future<List<User>> listOfUsersFromApi(Future<Response> data) async {
    return (jsonDecode((await data).body)['payload']['users'] as List)
        .map((e) => User.fromJson(e))
        .toList();
  }
}

extension PaddingExtension on Widget {
  Padding applyPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);
}
