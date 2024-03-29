import 'package:douchat3/main.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/routes/router.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class IdShare extends StatefulWidget {
  final UserService userService;
  const IdShare({Key? key, required this.userService}) : super(key: key);

  String get routeName => 'id_share';

  @override
  State<IdShare> createState() => _IdShareState();
}

class _IdShareState extends State<IdShare> with WidgetsBindingObserver {
    @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("CHANGING APP LIFE CYCLE");
    print(state.toString());
    if (state == AppLifecycleState.resumed) {
      notificationsPlugin.cancelAll();
    }
    Provider.of<AppLifeCycleProvider>(context, listen: false).setAppState(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
           ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Row(
              children: [
                Expanded(
                  child: QrImage(
                    data: Provider.of<ClientProvider>(context, listen: true)
                        .client
                        .id,
                    version: QrVersions.auto,
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ).applyPadding(const EdgeInsets.only(bottom: 16)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Center(
                    child: Text(
                        'Demandez à un autre utilisateur de Douchat de scanner ce code afin qu\'il puisse vous ajouter en contact',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(fontSize: 22)),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: RawMaterialButton(
                      fillColor: primary,
                      padding: const EdgeInsets.all(12),
                      
                        onPressed: () => Navigator.pushNamed(context, qrScan,
                                    arguments: {'userService': widget.userService})
                                .then((code) {
                              if ((code as Map)['success'] == true) {
                                Fluttertoast.showToast(
                                    msg: 'Le contact a bien reçu une requête',
                                    gravity: ToastGravity.BOTTOM);
                              } else {
                                Fluttertoast.showToast(
                                    msg: code['reason'],
                                    gravity: ToastGravity.BOTTOM);
                              }
                            }),
                        child: const Text('Scanner un code QR')),
                  ),
                ],
              ),
            )
          ]),
        )));
  }
}
