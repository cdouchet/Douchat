import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/register/logo.dart';
import 'package:douchat3/componants/shared/custom_text_field.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/views/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _username = '';
  String _password = '';
  bool loading = false;

  Widget _logo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Douchat',
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(
          width: 8.0,
        ),
        const Logo(),
        const SizedBox(
          width: 8.0,
        ),
        Text('Douchat',
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(
          width: 8.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _logo(context),
                    Text('Connexion',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.white)),
                    const Spacer(flex: 1),
                    Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20),
                        child: CustomTextField(
                          hint: 'Nom',
                          height: 45,
                          onChanged: (val) {
                            _username = val;
                          },
                          inputAction: TextInputAction.next,
                        )),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 20),
                        child: CustomTextField(
                          hint: 'Mot de passe',
                          height: 45,
                          onChanged: (val) {
                            _password = val;
                          },
                          inputAction: TextInputAction.done,
                          hideCharacters: true,
                        )),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: ElevatedButton(
                          onPressed: () async {
                            final error = _checkInputs();
                            if (error.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(error,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold))));
                            } else {
                              setState(() => loading = true);
                              Api.login(
                                      username: _username, password: _password)
                                  .then((log) {
                                setState(() => loading = false);
                                if (log.statusCode == 200) {
                                  final clientProvider =
                                      Provider.of<ClientProvider>(context,
                                          listen: false);
                                  final dynamic decodedResponse =
                                      jsonDecode(log.body);
                                  clientProvider.setAccessToken(
                                      decodedResponse['payload']
                                          ['access_token']);
                                  // clientProvider.setClient(User.fromJson(
                                  //     decodedResponse['payload']['client']));
                                  Api.getUsers().then((apiUsers) {
                                    final List<User> users =
                                        (jsonDecode(apiUsers.body)['payload']
                                                ['users'] as List)
                                            .map((e) => User.fromJson(e))
                                            .toList();
                                    CompositionRoot.configure(
                                        decodedResponse['payload']['client']
                                            ['id']);

                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                CompositionRoot.composeHome(
                                                    User.fromJson(
                                                        decodedResponse[
                                                                'payload']
                                                            ['client']),
                                                    users)));
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              jsonDecode(log.body)['payload']
                                                  ['error'])));
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: primary,
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(45))),
                          child: Container(
                              alignment: Alignment.center,
                              height: 45,
                              child: Text('Passer à la douche',
                                  style: Theme.of(context)
                                      .textTheme
                                      .button!
                                      .copyWith(
                                          fontSize: 18.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)))),
                    ),
                    InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const Register())),
                        child: Text('S\'inscrire',
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(
                                    fontSize: 18,
                                    decoration: TextDecoration.underline))),
                    const Spacer(),
                    loading
                        ? const CircularProgressIndicator.adaptive()
                        : Container(),
                    const Spacer(flex: 1)
                  ],
                )),
          ),
        ),
      ),
    );
  }

  String _checkInputs() {
    var error = '';
    if (_username.isEmpty) error = 'Entrer un nom d\'utilisateur';
    if (_password.isEmpty) error = '$error\n Entrer un mot de passe';
    return error;
  }
}
