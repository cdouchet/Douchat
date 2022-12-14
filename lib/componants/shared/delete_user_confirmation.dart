import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeleteUserConfirmation extends StatefulWidget {
  final User user;
  const DeleteUserConfirmation({super.key, required this.user});

  @override
  State<DeleteUserConfirmation> createState() => _DeleteUserConfirmationState();
}

class _DeleteUserConfirmationState extends State<DeleteUserConfirmation> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: background,
        content: Container(
            color: background,
            height: 200,
            width: 200,
            child: Column(
              children: [
                Text(
                    "Voulez-vous vraiment supprimer ${widget.user.username} de vos contacts ?",
                    style: TextStyle(color: bubbleLight)),
                    Text("Tous vos messages seront supprimés !", style: TextStyle(color: bubbleLight)),
                Spacer(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            loading = true;
                            setState(() {});
                            Api.removeContact(widget.user.id).then((res) {
                              Utils.logger.i("Response remove: ${res.body}");
                              final decoded = jsonDecode(res.body);
                              if (decoded["status"] == "failure") {
                                Fluttertoast.showToast(
                                    msg: decoded["payload"]["error"],
                                    gravity: ToastGravity.BOTTOM);
                              } else {
                                CompositionRoot.userService.removeContact(
                                    data: {"id": widget.user.id});
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Fluttertoast.showToast(
                                    msg: "Utilisateur supprimé",
                                    gravity: ToastGravity.BOTTOM);
                              }
                            }).catchError((err, st) {
                              Utils.logger
                                  .i("Error while removing user", err, st);
                              Fluttertoast.showToast(
                                  msg:
                                      "Une erreur est survenue. Vérifiez votre connexion",
                                  gravity: ToastGravity.BOTTOM);
                            });
                            //   loading = false;
                            // setState(() {
                            // });
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.red),
                              elevation: MaterialStatePropertyAll(0),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25)))),
                          child: loading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator.adaptive(
                                    valueColor:
                                        AlwaysStoppedAnimation(bubbleLight),
                                  ))
                              : Text("Supprimer")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.blue),
                              elevation: MaterialStatePropertyAll(0),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25)))),
                          child: Text("Annuler"))
                    ])
              ],
            )));
  }
}
