import 'dart:io';

import 'package:douchat3/componants/register/logo.dart';
import 'package:douchat3/componants/shared/custom_text_field.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/loginGetters.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/views/password_reset/reset_password.dart';
import 'package:douchat3/views/password_reset/reset_password_confirmation.dart';
import 'package:douchat3/views/register.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  String get routeName => 'login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _username = '';
  String _password = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    handleInitialLink();
  }

  Future<void> handleInitialLink() async {
    final link = await getInitialLink();
    if (link == null) {
      Utils.logger.i("No initial link");
      return;
    }
    Utils.logger.i("Started from app link");
    if (link.split("/#/")[1].startsWith("password-reset")) {
      Utils.logger.i("Asking password reset");
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        late String token;
        try {
          token = link.split("/#/")[1].split("reset?token=")[1];
        } catch (e) {
          Utils.logger.i("Wrong url format");
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResetPasswordConfirmation(token: token)));
      });
    }
  }

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                      if (kIsWeb) ...[
                        ElevatedButton(
                            onPressed: () async {
                              if (Platform.isAndroid || Platform.isIOS) {
                                // TODO: Find ios app id + check if app is installed
                                final appId = Platform.isAndroid
                                    ? "com.example.douchat3"
                                    : "IOSAPPID";
                                final url = Uri.parse(Platform.isAndroid
                                    ? "market://details?id=$appId"
                                    : "https://apps.apple.com/app/id$appId");
                                launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45))),
                            child: Container(
                                alignment: Alignment.center,
                                height: 45,
                                child: Text('Télécharger l\'application',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button!
                                        .copyWith(
                                            fontSize: 18.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)))),
                        const Spacer(flex: 1),
                      ],
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
                              FocusScope.of(context).unfocus();
                              final error = _checkInputs();
                              if (error.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            error,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold))));
                              } else {
                                setState(() => loading = true);
                                final success =
                                    await LoginGetters.getEverythingAndLogin(
                                        context: context,
                                        u: _username,
                                        p: _password);
                                if (!success) {
                                  setState(() => loading = false);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
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
                      InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResetPassword())),
                          child: Text("Mot de passe oublié ?",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      fontSize: 18,
                                      decoration: TextDecoration.underline))),
                      loading
                          ? LoadingAnimationWidget.threeArchedCircle(
                              color: Colors.white, size: 30)
                          : Container(),
                      const Spacer(flex: 1)
                    ],
                  )),
            ),
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
