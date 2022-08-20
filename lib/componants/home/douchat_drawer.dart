import 'package:douchat3/composition_root.dart';
import 'package:douchat3/routes/router.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        const Spacer(),
        GestureDetector(
                onTap: () => Navigator.pushNamed(context, idShare,
                    arguments: {'userService': userService}),
                child: ListTile(
                    tileColor: tileColor,
                    leading: const Icon(Icons.ios_share, color: Colors.white),
                    title: Text('Partage d\'identifiants',
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: Colors.white))))
            .applyPadding(const EdgeInsets.only(bottom: 12)),
        GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, settingsStr,
                      arguments: {'userService': userService});
                },
                child: ListTile(
                    tileColor: tileColor,
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text('Paramètres')))
            .applyPadding(const EdgeInsets.only(bottom: 12)),
        GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, infos);
                },
                child: ListTile(
                    tileColor: tileColor,
                    leading: const Icon(Icons.info, color: Colors.white),
                    title: const Text('A propos de l\'application')))
            .applyPadding(const EdgeInsets.only(bottom: 12)),
        GestureDetector(
          onTap: () {
            CompositionRoot.socket.clearListeners();
            CompositionRoot.socket.disconnect();
            const FlutterSecureStorage().delete(key: 'access_token').then((_) {
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (_) => Login()));
              // Phoenix.rebirth(context);
              SystemNavigator.pop();
            });
          },
          child: ListTile(
              tileColor: tileColor,
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text('Se déconnecter',
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white))),
        ),
      ])),
    );
  }
}
