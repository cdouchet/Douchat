import 'dart:convert';
import 'dart:io';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/models/conversation.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanPage extends StatefulWidget {
  final UserService userService;
  const QrScanPage({Key? key, required this.userService}) : super(key: key);

  String get routeName => 'qr_scan';

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasScan = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<RouteProvider>(context, listen: false).changeRoute('qr_scan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: hasScan
                ? LoadingAnimationWidget.threeArchedCircle(
                    color: Colors.white, size: 70)
                : QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Scannez un code QR'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() => hasScan = true);
      if (scanData.code != null && mounted) {
        Api.addContact(
                id: scanData.code!,
                clientId: Provider.of<ClientProvider>(context, listen: false)
                    .client
                    .id)
            .then((response) {
          final decoded = jsonDecode(response.body);
          if (decoded['status'] != 'success') {
            if (decoded['error'] == 'already_contact_error') {
              Fluttertoast.showToast(
                  msg: 'Ce contact est déjà ajouté',
                  gravity: ToastGravity.BOTTOM);
            }
            Navigator.pop(context,
                {'success': false, 'reason': 'Ce contact est déjà ajouté'});
          } else {
            Provider.of<UserProvider>(context, listen: false)
                .addUser(User.fromJson(decoded['payload']['user']));
            Provider.of<ConversationProvider>(context, listen: false)
                .addConversation(Conversation(
                    user: User.fromJson(decoded['payload']['user']),
                    messages: []));
            widget.userService.sendAddedUser(
                user:
                    Provider.of<ClientProvider>(context, listen: false).client,
                userId: decoded['payload']['user']['id']);
            Navigator.pop(context, {'success': true, 'data': scanData.code});
          }
        });
      } else {
        setState(() => hasScan = false);
        Fluttertoast.showToast(
            msg: 'Erreur durant le scan. Veuillez réessayer',
            gravity: ToastGravity.BOTTOM);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
