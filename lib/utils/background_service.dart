// import 'package:douchat3/main.dart';
// import 'package:douchat3/utils/utils.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class DouchatBackgroundService {
//   static final FlutterBackgroundService service = FlutterBackgroundService();
//   static Future<void> initializeService() async {
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     '9999481', // id
//     'MY FOREGROUND SERVICE', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.low, // importance must be at low or higher level
//   );

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will be executed when app is in foreground or background in separated isolate
//       onStart: Utils.onStart,

//       // auto start service
//       autoStart: true,
//       isForegroundMode: true,

//       notificationChannelId: '9999481', // this must match with notification channel you created above.
//       initialNotificationTitle: 'AWESOME SERVICE',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: 112233857,

//     ), iosConfiguration: IosConfiguration(onForeground: (d) {}, onBackground: (d) {return true;}));
//     service.on('didi').listen((event) {
//       notificationsPlugin.show(10, 'DIDI INVOKED', 'HE DO BE HERE', NotificationDetails());
//     });
//     service.startService();
// }
// }