import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/shared/delete_user_confirmation.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class UserDetails extends StatefulWidget {
  final User user;
  final bool conversation;
  UserDetails({super.key, required this.user, required this.conversation});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  Future<String> getToken() async {
    return await const FlutterSecureStorage().read(key: "access_token") ?? "";
  }

  bool alreadyInContacts = false;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      alreadyInContacts = Provider.of<UserProvider>(context, listen: false)
          .users
          .any((e) => e.id == widget.user.id);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(color: background),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Transform.translate(
                offset: Offset(0, -100),
                child: FutureBuilder<String>(
                    future: getToken(),
                    builder: (context, snap) {
                      return snap.hasData
                          ? CircleAvatar(
                              maxRadius: 80,
                              minRadius: 80,
                              backgroundImage: CachedNetworkImageProvider(
                                  widget.user.photoUrl,
                                  headers: {"cookie": snap.data!}))
                          : Container();
                    }),
              )
            ]),
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Transform.translate(
                  offset: Offset(0, -80),
                  child: Text(
                    widget.user.username,
                    style: TextStyle(color: Colors.white, fontSize: 36),
                    overflow: TextOverflow.ellipsis,
                  )),
              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Utils.logger.i("loading value: $loading");
                    if (loading || alreadyInContacts) {
                      return;
                    }
                    setState(() => loading = true);
                    Api.addContact(
                            id: widget.user.id,
                            clientId: Provider.of<ClientProvider>(context,
                                    listen: false)
                                .client
                                .id)
                        .then((response) {
                      final decoded = jsonDecode(response.body);
                      if (decoded['status'] != 'success') {
                        Utils.logger.i(decoded);
                        if (decoded["payload"]['error'] ==
                            'already_contact_error') {
                          Fluttertoast.showToast(
                              msg: 'Ce contact est déjà ajouté',
                              gravity: ToastGravity.BOTTOM);
                        } else if (decoded["payload"]['error'] ==
                            'already_pending_error') {
                          Fluttertoast.showToast(
                              msg: "Une requête a déjà été envoyée",
                              gravity: ToastGravity.BOTTOM);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Erreur durant l'ajout du contact",
                              gravity: ToastGravity.BOTTOM);
                        }
                      } else {
                        Fluttertoast.showToast(msg: "Requête envoyée!", gravity: ToastGravity.BOTTOM);
                        CompositionRoot.userService.sendFriendRequest(
                            data: decoded['payload']['friend_request']);
                      }
                    });
                    setState(() => loading = false);
                  },
                  child: ListTile(
                      tileColor: Color.fromRGBO(40, 40, 40, 1),
                      leading: loading
                          ? CircularProgressIndicator.adaptive()
                          : Icon(
                              alreadyInContacts
                                  ? Icons.check
                                  : Icons.person_add,
                              color: primary),
                      title: Text(alreadyInContacts
                          ? "Déjà dans vos contacts"
                          : "Ajouter en contact"))),
              if (alreadyInContacts)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                    onTap: () {
                      showDialog(context: context, builder: (context) => DeleteUserConfirmation(user: widget.user));
                      
                      //TODO: Implements user deletion
                      // Demander une confirmation en expliquant que ça va delete tous les messages.
                    },
                    child: ListTile(
                        leading: Icon(Icons.remove, color: primary),
                        title: Text("Supprimer ce contact")))
            ]),
          ],
        ));
  }
}
