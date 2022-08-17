import 'dart:convert';

import 'package:douchat3/main.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void notificationCallbackHandler(String? payload) {
  if (payload != null) {
    print('Notification callback');
    final decoded = jsonDecode(payload);
    if (decoded['type'] == 'conversation') {
      if (Provider.of<RouteProvider>(globalKey.currentContext!, listen: false)
              .route ==
          'private_thread') {
        Navigator.pushReplacementNamed(globalKey.currentContext!, privateThread,
            arguments: {
              'user': Provider.of<UserProvider>(globalKey.currentContext!)
                  .users
                  .firstWhere((u) => u.id == decoded['id'])
            });
      }
    }
  }
}
