import 'dart:async';
import 'dart:convert';

import 'package:douchat3/componants/message_thread/media/files_page.dart';
import 'package:douchat3/componants/message_thread/media/gif_page.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class Utils {
  static Logger logger = Logger();

  static Future<List<User>> listOfUsersFromApi(Future<Response> data) async {
    return (jsonDecode((await data).body)['payload']['users'] as List)
        .map((e) => User.fromJson(e))
        .toList();
  }

  static Future<dynamic> showMediaPickFile(BuildContext context) async {
    return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (context) {
          return DefaultTabController(
              length: 3,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Flexible(
                  child: TabBar(
                      indicatorPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                      tabs: [
                        Tab(
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Align(
                                    alignment: Alignment.center,
                                    child: Icon(Icons.image, size: 18)))),
                        Tab(
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Align(
                                    alignment: Alignment.center,
                                    child: Icon(Icons.gif, size: 30)))),
                        Tab(
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Align(
                                    alignment: Alignment.center,
                                    child: Icon(Icons.camera_alt, size: 21))))
                      ]),
                ),
                Flexible(
                  flex: 2,
                  child: TabBarView(children: [
                    FilesPage(),
                    GifPage(),
                    Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                                onPressed: () async {
                                  final file = await ImagePicker()
                                      .pickImage(source: ImageSource.camera);
                                  Navigator.pop(context,
                                      {'type': 'photo_taken', 'file': file});
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    elevation: 5.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(45))),
                                child: Container(
                                    alignment: Alignment.center,
                                    height: 45,
                                    child: Text('Prendre une photo',
                                        style: Theme.of(context)
                                            .textTheme
                                            .button!
                                            .copyWith(
                                                fontSize: 18.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))))
                            .applyPadding(
                                const EdgeInsets.only(right: 60, left: 60)),
                      ],
                    ))
                  ]),
                )
              ]));
        });
  }

  static Future<dynamic> showModalMessageOptions(
      {required BuildContext context,
      required Message message,
      required bool sender}) async {
    return await showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (BuildContext context) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (message.type == "text")
                    GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                                  ClipboardData(text: message.content))
                              .then((value) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: "Copié dans le presse-papier",
                                gravity: ToastGravity.BOTTOM);
                          });
                        },
                        child: ListTile(
                            leading: Icon(Icons.copy, color: Colors.white),
                            title: Text("Copier le texte"))),
                  if (sender) ...[
                    GestureDetector(
                      onTap: () {
                        CompositionRoot.messageService.removeMessage({
                          "clientId": Provider.of<ClientProvider>(context,
                                  listen: false)
                              .client
                              .id,
                          "from": message.from,
                          "to": message.to,
                          "id": message.id
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: "Message supprimé",
                            gravity: ToastGravity.BOTTOM);
                      },
                      child: ListTile(
                        leading:
                            Icon(FontAwesomeIcons.trash, color: Colors.red),
                        title: Text("Supprimer"),
                      ),
                    )
                  ]
                ],
              ),
            )
          ]);
        });
  }

  static Future<dynamic> showModalGroupMessageOptions(
      {required BuildContext context,
      required GroupMessage message,
      required bool sender}) async {
    return await showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (BuildContext context) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (message.type == "text")
                    GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                                  ClipboardData(text: message.content))
                              .then((value) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: "Copié dans le presse-papier",
                                gravity: ToastGravity.BOTTOM);
                          });
                        },
                        child: ListTile(
                            leading: Icon(Icons.copy, color: Colors.white),
                            title: Text("Copier le texte"))),
                  if (sender) ...[
                    GestureDetector(
                      onTap: () {
                        CompositionRoot.messageService.removeMessage({
                          "clientId": Provider.of<ClientProvider>(context,
                                  listen: false)
                              .client
                              .id,
                          "group": message.group,
                          "id": message.id
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: "Message supprimé",
                            gravity: ToastGravity.BOTTOM);
                      },
                      child: ListTile(
                        leading:
                            Icon(FontAwesomeIcons.trash, color: Colors.red),
                        title: Text("Supprimer"),
                      ),
                    )
                  ]
                ],
              ),
            )
          ]);
        });
  }

  static bool isImage(String path) {
    final lu = lookupMimeType(path);
    if (lu == null) {
      return false;
    } else {
      return lu.startsWith('image/');
    }
  }

  static bool isFileHidden(String path) => basename(path).startsWith('.');
}

extension PaddingExtension on Widget {
  Padding applyPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);
}
