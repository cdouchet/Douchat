import 'package:douchat3/componants/register/logo.dart';
import 'package:douchat3/componants/register/profile_upload.dart';
import 'package:douchat3/componants/shared/custom_text_field.dart';
import 'package:douchat3/providers/profile_photo.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/loginGetters.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  String get routeName => 'register';

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _username = '';
  String _password = '';
  String _email = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
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
                      Text('Nouveau compte',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(color: Colors.white)),
                      const Spacer(),
                      const ProfileUpload(),
                      const Spacer(flex: 1),
                      Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: CustomTextField(
                            hint: 'Quel est ton nom ?',
                            height: 45,
                            onChanged: (val) {
                              _username = val;
                            },
                            inputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, top: 20),
                          child: CustomTextField(
                            hint: 'Quel est ton email ?',
                            height: 45,
                            onChanged: (val) {
                              _email = val;
                            },
                            inputAction: TextInputAction.next,
                            hideCharacters: false,
                            inputType: TextInputType.emailAddress,
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, top: 20),
                          child: CustomTextField(
                            hint: 'Entrer un mot de passe',
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
                                print(
                                    "PHOTO FILE + ${Provider.of<ProfilePhotoProvider>(context, listen: false).photoFile}");
                                setState(() => loading = true);
                                if (!(await LoginGetters
                                    .getEverythingAndRegister(
                                        context: context,
                                        e: _email,
                                        u: _username,
                                        p: _password))) {
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
                      const Spacer(),
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
    if (_email.isEmpty) error = '$error\n Entrer une email';
    if (_username.length > 20) {
      error =
          '$error\n Le nom d\'utilisateur ne doit pas comporter plus de 20 caractères';
    }
    return error;
  }
}
