import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/shared/custom_text_field.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: SafeArea(
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: double.maxFinite,
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          "Entrez le mail associé à votre compte pour reçevoir un lien de réinitialisation de mot de passe."),
                      CustomTextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp('[ ]'))
                        ],
                        inputType: TextInputType.emailAddress,
                          hint: "Email",
                          onChanged: (text) {
                            emailController.text.trim();
                            setState(() {});
                          },
                          inputAction: TextInputAction.done,
                          controller: emailController),
                      ElevatedButton(
                          onPressed: () {
                            if (emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Email is required")));
                              return;
                            }
                            Api.resetPassword(email: emailController.text)
                                .then((res) {
                              final decoded = jsonDecode(res.body);
                              if (decoded["status"] == "failure") {
                                String error = decoded["payload"]["error"];
                                if (error == "no user") {
                                  error = "Aucun utilisateur avec cet email";
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Email envoyé")));
                              }
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
                              child: Text('Recevoir un lien',
                                  style: Theme.of(context)
                                      .textTheme
                                      .button!
                                      .copyWith(
                                          fontSize: 18.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold))))
                    ],
                  ))),
        ));
  }
}
