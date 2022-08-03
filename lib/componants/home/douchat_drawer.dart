import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/views/login.dart';
import 'package:douchat3/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DouchatDrawer extends StatelessWidget {
  final UserService userService;
  DouchatDrawer({Key? key, required this.userService}) : super(key: key);

  final tileColor = Colors.white.withOpacity(0.1);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
          child: Column(children: [
        GestureDetector(
          onTap: () {
            const FlutterSecureStorage().delete(key: 'access_token').then((_) =>
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                    (route) => false));
          },
          child: ListTile(
              tileColor: tileColor,
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text('Se déconnecter',
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white))),
        ).applyPadding(const EdgeInsets.only(bottom: 12)),
        GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Settings(
                            userService: userService,
                          )));
            },
            child: ListTile(
                tileColor: tileColor,
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Paramètres')))
      ])),
    );
  }
}
