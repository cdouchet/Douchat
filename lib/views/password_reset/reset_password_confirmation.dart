import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/shared/custom_text_field.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';

class ResetPasswordConfirmation extends StatefulWidget {
  final String token;
  const ResetPasswordConfirmation({super.key, required this.token});

  @override
  State<ResetPasswordConfirmation> createState() =>
      _ResetPasswordConfirmationState();
}

class _ResetPasswordConfirmationState extends State<ResetPasswordConfirmation> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
        ),
        body: SafeArea(
            child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Réinitialisation de mot de passe",
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Colors.white, fontSize: 22)),
                        Spacer(),
                        Column(
                          children: [
                            CustomTextField(
                              hint: "Mot de passe",
                              onChanged: (text) {},
                              inputAction: TextInputAction.next,
                              inputType: TextInputType.emailAddress,
                              controller: passwordController,
                              hideCharacters: true,
                            ),
                            SizedBox(height: 30),
                            CustomTextField(
                              hint: "Confirmation du mot de passe",
                              onChanged: (text) {},
                              inputAction: TextInputAction.done,
                              inputType: TextInputType.emailAddress,
                              controller: confirmPasswordController,
                              hideCharacters: true,
                            )
                          ],
                        ),
                        Spacer(),
                        ElevatedButton(
                            onPressed: () {
                              if (passwordController.text.isEmpty ||
                                  confirmPasswordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Des champs sont manquants")));
                                return;
                              }
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Les mots de passe ne sont pas identiques")));
                                return;
                              }
                              Api.confirmResetPassword(
                                      token: widget.token,
                                      password: passwordController.text)
                                  .then((res) {
                                final decoded = jsonDecode(res.body);
                                if (decoded["status"] == "failure") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              decoded["payload"]["error"])));
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Votre mot de passe a été modifié")));
                                Navigator.pop(context);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45))),
                            child: Container(
                                alignment: Alignment.center,
                                height: 45,
                                child: Text('Modifier le mot de passe',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button!
                                        .copyWith(
                                            fontSize: 18.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)))),
                        Spacer()
                      ]),
                ))));
  }
}
