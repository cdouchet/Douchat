import 'dart:convert';

import 'package:douchat3/main.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/routes/router.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void notificationCallbackHandler(String? payload) {
  try {
    Utils.logger.i(payload);
    if (payload != null) {
      print('Notification callback');
      final decoded = jsonDecode(payload);
      if (decoded['type'] == 'conversation') {
        Utils.logger.i('true or false better be true : ' +
            (decoded['type'] == 'conversation').toString());
        if (!Provider.of<RouteProvider>(globalKey.currentContext!,
                    listen: false)
                .isOnPrivateThread &&
            Provider.of<RouteProvider>(globalKey.currentContext!, listen: false)
                    .privateThreadId !=
                decoded['id']) {
          // Utils.logger.i(ModalRoute.of(navigatorKey.currentContext!)!.settings.name);
          Utils.logger.i(Provider.of<RouteProvider>(globalKey.currentContext!,
                  listen: false)
              .privateThreadId);
          // Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, MaterialPageRoute(builder: (_) => Container()), (route) => false).then((value) {
          // Navigator.pushReplacementNamed(navigatorKey.currentContext!, privateThread,
          //     arguments: {
          //       'user': Provider.of<UserProvider>(globalKey.currentContext!)
          //           .users
          //           .firstWhere((u) => u.id == decoded['id'])
          //     });
          // });
          Navigator.pushNamed(navigatorKey.currentContext!, privateThread,
              arguments: {
                'user': Provider.of<UserProvider>(globalKey.currentContext!)
                    .users
                    .firstWhere((u) => u.id == decoded['id'])
              });
        }
      } 
      // else if (decoded['type'] == "friend_request") {
      //   if (!Provider.of<RouteProvider>(globalKey.currentContext!, listen: false).isOnFriendRequestView) {
      //     Navigator.pushNamed(navigatorKey.currentContext!, friendRequests);
      //   }
      // }
    }
  } catch (e, s) {
    Utils.logger.i(e);
    Utils.logger.i(s);
  }
}
