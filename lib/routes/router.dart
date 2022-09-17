import 'package:douchat3/composition_root.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/views/about.dart';
import 'package:douchat3/views/id_share.dart';
import 'package:douchat3/views/qr_loader.dart';
import 'package:douchat3/views/qr_scan.dart';
import 'package:douchat3/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String home = 'home';
const String settingsStr = 'settings';
const String idShare = 'id_share';
const String login = 'login';
const String register = 'register';
const String privateThread = 'private_thread';
const String qrLoader = 'qr_loader';
const String qrScan = 'qr_scan';
const String infos = 'infos';
const String friendRequests = 'friend_requests';
const String groupThread = 'group_thread';

Route<dynamic> controller(RouteSettings settings) {
  print('Name controller : ' + settings.name!);
  Provider.of<RouteProvider>(globalKey.currentContext!, listen: false)
      .changeRoute(settings.name!);
  final args = (settings.arguments ?? {}) as Map;
  switch (settings.name) {
    case home:
      return MaterialPageRoute(
          builder: (_) => CompositionRoot.composeHome(
              client: args['client'],
              users: args['users'],
              messages: args['messages'],
              conversations: args['conversations'],
              groups: args['groups'], friendRequests: args['friendRequests']));
    case settingsStr:
      return MaterialPageRoute(
          builder: (_) => Settings(userService: args['userService']));
    case idShare:
      return MaterialPageRoute(
          builder: (_) => IdShare(userService: args['userService']));
    case login:
      return MaterialPageRoute(builder: (_) => CompositionRoot.composeLogin());
    case register:
      return MaterialPageRoute(
          builder: (_) => CompositionRoot.composeRegister());
    case privateThread:
      return MaterialPageRoute(
          builder: (_) =>
              CompositionRoot.composePrivateMessageThread(user: args['user']));
    case qrLoader:
      return MaterialPageRoute(
          builder: (_) =>
              QrLoader(id: args['id'], userService: args['userService']));
    case qrScan:
      return MaterialPageRoute(
          builder: (_) => QrScanPage(userService: args['userService']));
    case infos:
      return MaterialPageRoute(builder: (_) => About());
    case friendRequests:
      return MaterialPageRoute(builder: (_) => CompositionRoot.composeFriendRequestView());
    case groupThread:
      return MaterialPageRoute(builder: (_) => CompositionRoot.composeGroupMessageThread(id: args['id']));
    default:
      return MaterialPageRoute(builder: (_) => CompositionRoot.composeLogin());
  }
}
