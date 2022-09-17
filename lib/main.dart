import 'dart:io';

import 'package:douchat3/composition_root.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/friend_request_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/media_provider.dart';
import 'package:douchat3/providers/message_provider.dart';
import 'package:douchat3/providers/profile_photo.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/routes/router.dart';
import 'package:douchat3/services/notifications/notification_callback_handler.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldState> globalKey = GlobalKey();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final notificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  await dotenv.load(fileName: '.env');
  initializeDateFormatting('fr_FR', null);
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  notificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon')),
      onSelectNotification: notificationCallbackHandler);
  runApp(
    // LoadingProvider(
    // themeData: LoadingThemeData(),
    //   loadingWidgetBuilder: (BuildContext context, LoadingThemeData data) {
    //     return Center(
    //         child: LoadingAnimationWidget.threeArchedCircle(
    //             color: Colors.white, size: 80));
    //   },
    // child: 
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ClientProvider>(create: (_) => ClientProvider()),
        ChangeNotifierProvider<ProfilePhotoProvider>(
          create: (_) => ProfilePhotoProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<MessageProvider>(create: (_) => MessageProvider()),
        ChangeNotifierProvider<ConversationProvider>(
            create: (_) => ConversationProvider()),
        ChangeNotifierProvider<RouteProvider>(create: (_) => RouteProvider()),
        ChangeNotifierProvider<AppLifeCycleProvider>(
            create: (_) => AppLifeCycleProvider()),
        ChangeNotifierProvider<MediaProvider>(create: (_) => MediaProvider()),
        ChangeNotifierProvider<GroupProvider>(create: (_) => GroupProvider()),
        ChangeNotifierProvider<FriendRequestProvider>(
            create: (_) => FriendRequestProvider())
      ],
      builder: (c, w) => MaterialApp(
          key: globalKey,
          locale: Locale('fr', 'FR'),
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: darkTheme(),
          darkTheme: darkTheme(),
          themeMode: ThemeMode.dark,
          onGenerateRoute: controller,
          home: Douchat()),
    ),
  );
}

final androidBackgroundConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'Douchat',
    notificationText:
        'Cette notif est là pour garder Douchat activé. C\'est parce Google veut que j\'utilise leur plugin qui traque tout mais je l\'ai esquivé.',
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon:
        AndroidResource(name: 'launcher_icon', defType: 'drawable'));

class Douchat extends StatelessWidget {
  const Douchat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: FlutterBackground.initialize(
            androidConfig: androidBackgroundConfig),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              FlutterBackground.enableBackgroundExecution();
            }
            return FutureBuilder<Widget>(
                future: CompositionRoot.start(context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print("snap has data");
                    return snapshot.data!;
                  } else {
                    print("snap has no data");
                    return Scaffold(
                        body: SafeArea(
                            child: Center(
                                child:
                                    LoadingAnimationWidget.threeArchedCircle(
                                        color: Colors.white, size: 70))));
                  }
                });
          } else {
            return Container();
          }
        });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
