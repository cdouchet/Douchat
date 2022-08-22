import 'dart:async';
import 'dart:convert';

import 'package:douchat3/componants/message_thread/media/files_page.dart';
import 'package:douchat3/componants/message_thread/media/gif_page.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

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
                                  Navigator.pop(context, {
                                    'type': 'medias',
                                    'medias': [file]
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: primary,
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
