import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> configureFirebase() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.onTokenRefresh.listen((fcmToken) async {
    Utils.logger.i("Refreshing firebase token");
    (await SharedPreferences.getInstance())
        .setString("firebase_token", fcmToken);
    Api.updateFirebaseToken(fcmToken).then((value) {
      final decoded = jsonDecode(value.body);
      if (decoded["status"] == "success") {
        Utils.logger.i("Firebase token refreshed successfully");
      } else {
        Utils.logger.i("Failed to refresh firebase token");
      }
    });
  }).onError((err) {
    Utils.logger.e("Error getting token", err);
  });
  await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false);
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // final notificationsPlugin = flnp.FlutterLocalNotificationsPlugin();
  // await notificationsPlugin.initialize(initializationSettings);
  // List<int> notificationIds = [];
  // final data = message.data["message"];
  // final isConv = data["conv"] == "true";
  // if (isConv) {
  //   int id = 0;
  //   while (notificationIds.contains(id)) {
  //     id++;
  //   }
  //   notificationIds.add(id);
  //   final String from = data['fromId'];
  //   final String messageText = data['type'] == 'text'
  //       ? data['content']
  //       : data['type'] == 'image'
  //           ? '${data["username"]} a envoyé une image.'
  //           : data['type'] == 'video'
  //               ? '${data["username"]} a envoyé une vidéo'
  //               : '${data["username"]} a envoyé un gif';
  //   if (Platform.isAndroid) {
  //     final List<flnp.ActiveNotification> activeNotifications =
  //         (await notificationsPlugin
  //             .resolvePlatformSpecificImplementation<
  //                 flnp.AndroidFlutterLocalNotificationsPlugin>()
  //             ?.getActiveNotifications())!;
  //     activeNotifications.forEach((element) {
  //       Utils.logger.i(element.title);
  //       Utils.logger.i(element.channelId);
  //     });
  //     // if (activeNotifications.any((element) => element.channelId == data["fromId"])) {
  //     //   final flnp.ActiveNotification notif = activeNotifications.firstWhere((n) => n.channelId == data["fromId"]);
  //     //   finalText = '${notif.body}\n$messageText';
  //     //   notifId = notif.id;
  //     // } else {
  //     //   finalText = messageText;
  //     //   notifId = id;
  //     // }
  //     List<flnp.Message> notifMessages = activeNotifications
  //         .where((n) => n.channelId == from)
  //         .map((e) => flnp.Message(
  //             e.body!, DateFormat().parse(data['timestamp']), null))
  //         .toList();
  //     if (notifMessages.isNotEmpty) {
  //       id = activeNotifications
  //           .firstWhere((n) => n.channelId == data["fromId"])
  //           .id;
  //     }
  //     print("NOTIFICATION ID : " + id.toString());
  //     notifMessages.add(flnp.Message(
  //         messageText, DateFormat().parse(data['timestamp']), null));
  //     notificationsPlugin.show(
  //         id,
  //         data["username"],
  //         messageText,
  //         flnp.NotificationDetails(
  //             android: flnp.AndroidNotificationDetails(
  //                 data["fromId"], data["username"],
  //                 enableVibration: true,
  //                 groupKey: data["fromId"],
  //                 setAsGroupSummary: !activeNotifications
  //                     .any((n) => n.channelId == data["fromId"]),
  //                 category: "CATEGORY_MESSAGE",
  //                 priority: flnp.Priority.max,
  //                 styleInformation: flnp.MessagingStyleInformation(
  //                     flnp.Person(
  //                       bot: false,
  //                       name: data["username"],
  //                     ),
  //                     conversationTitle: data["username"],
  //                     messages: notifMessages),
  //                 importance: flnp.Importance.max)),
  //         payload: '{"type": "conversation", "id": "$from"}');
  //   } else {
  //     notificationsPlugin.show(id, data["username"], messageText,
  //         flnp.NotificationDetails(iOS: flnp.IOSNotificationDetails()));
  //   }
  // } else {
  //   int id = 0;
  //   while (notificationIds.contains(id)) {
  //     id++;
  //   }
  //   notificationIds.add(id);
  //   final String messageText = '${data["username"]}' +
  //       (data['type'] == 'text'
  //           ? ": ${data['content']}"
  //           : data['type'] == 'image'
  //               ? ' a envoyé une image'
  //               : data['type'] == 'video'
  //                   ? ' a envoyé une vidéo'
  //                   : ' a envoyé un gif');
  //   if (Platform.isAndroid) {
  //     List<flnp.ActiveNotification> activeNotifications =
  //         (await notificationsPlugin
  //             .resolvePlatformSpecificImplementation<
  //                 flnp.AndroidFlutterLocalNotificationsPlugin>()
  //             ?.getActiveNotifications())!;
  //     activeNotifications.forEach((element) {
  //       Utils.logger.i(element.title);
  //       Utils.logger.i(element.channelId);
  //     });
  //     List<flnp.Message> notifMessages = activeNotifications
  //         .where((n) => n.channelId == data["group"])
  //         .map((e) => flnp.Message(
  //             e.body!, DateFormat().parse(data['timestamp']), null))
  //         .toList();
  //     if (notifMessages.isNotEmpty) {
  //       id = activeNotifications
  //           .firstWhere((n) => n.channelId == data["group"])
  //           .id;
  //     }
  //     print('Notification id : ' + id.toString());
  //     notifMessages.add(flnp.Message(
  //         messageText, DateFormat().parse(data['timestamp']), null));
  //     notificationsPlugin.show(
  //         id,
  //         data["group_name"],
  //         messageText,
  //         flnp.NotificationDetails(
  //             android: flnp.AndroidNotificationDetails(
  //                 data["group"], data["username"],
  //                 enableVibration: true,
  //                 groupKey: data["group"],
  //                 setAsGroupSummary: !activeNotifications
  //                     .any((n) => n.channelId == data["group"]),
  //                 category: "CATEGORY_MESSAGE",
  //                 priority: flnp.Priority.max,
  //                 importance: flnp.Importance.max,
  //                 styleInformation: flnp.MessagingStyleInformation(
  //                     flnp.Person(
  //                       bot: false,
  //                       name: data["group_name"],
  //                     ),
  //                     conversationTitle: data["group_name"],
  //                     messages: notifMessages))),
  //         payload: '{"type": "group", "id": "${data["group"]}"}');
  //   } else {
  //     notificationsPlugin.show(id, data["group_name"], messageText,
  //         flnp.NotificationDetails(iOS: flnp.IOSNotificationDetails()));
  //   }
  // }
}
