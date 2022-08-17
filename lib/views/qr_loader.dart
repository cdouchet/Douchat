import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/route_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class QrLoader extends StatefulWidget {
  final String id;
  final UserService userService;
  const QrLoader({Key? key, required this.id, required this.userService})
      : super(key: key);

  String get routeName => 'qr_loader';

  @override
  State<QrLoader> createState() => _QrLoaderState();
}

class _QrLoaderState extends State<QrLoader> {
  @override
  void initState() {
    super.initState();
    Provider.of<RouteProvider>(context, listen: false).changeRoute('qr_loader');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LoadingAnimationWidget.threeArchedCircle(
                color: Colors.white, size: 70),
            const Text('Veuillez patienter...'),
            FutureBuilder(
                future: _addContact(context),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Container();
                })
          ]),
    )));
  }

  _addContact(BuildContext context) {
    Api.addContact(
            id: widget.id,
            clientId:
                Provider.of<ClientProvider>(context, listen: false).client.id)
        .then((response) {
      final decoded = jsonDecode(response.body);
      if (decoded['status'] != 'success') {
        Navigator.pop(context, {'status': 'failure'});
      } else {
        Provider.of<UserProvider>(context, listen: false)
            .addUser(User.fromJson(decoded['payload']['user']));
        widget.userService.sendAddedUser(
            user: Provider.of<ClientProvider>(context, listen: false).client,
            userId: decoded['payload']['user']['id']);
        Navigator.pop(context, {'status': 'success'});
      }
    });
  }
}
