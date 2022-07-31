import 'dart:io';

import 'package:douchat3/composition_root.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/profile_photo.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const Douchat());
}

class Douchat extends StatelessWidget {
  const Douchat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => ClientProvider()),
        ListenableProvider(
          create: (_) => ProfilePhotoProvider(),
        )
      ],
      child: MaterialApp(
          theme: darkTheme(context),
          darkTheme: darkTheme(context),
          themeMode: ThemeMode.dark,
          home: FutureBuilder<Widget>(
              future: CompositionRoot.start(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print("snap has data");
                  return snapshot.data!;
                } else {
                  print("snap has no data");
                  return Container();
                }
              })),
    );
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
