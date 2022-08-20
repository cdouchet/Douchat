import 'dart:convert';
import 'dart:io';

import 'package:douchat3/models/user.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class Utils {
  static Logger logger = Logger();

  static Future<List<User>> listOfUsersFromApi(Future<Response> data) async {
    return (jsonDecode((await data).body)['payload']['users'] as List)
        .map((e) => User.fromJson(e))
        .toList();
  }

  static Future<void> showMediaPickFile(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(shrinkWrap: true, children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: DefaultTabController(
                    length: 2,
                    child: Column(children: [
                      TabBar(
                          indicatorPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          tabs: [
                            Tab(
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: const Align(
                                        alignment: Alignment.center,
                                        child: Icon(FontAwesomeIcons.file)))),
                            Tab(
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: const Align(
                                        alignment: Alignment.center,
                                        child: Icon(Icons.gif)))),
                          ]),
                      Expanded(
                          child: TabBarView(children: [
                        FutureBuilder<bool>(
                            future: _checkMediaPermission(),
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              return StatefulBuilder(builder:
                                  (BuildContext context,
                                      void Function(void Function()) setState) {
                                if (!snapshot.hasData) {
                                  return Container();
                                } else {
                                  bool storagePermissionGranted =
                                      snapshot.data!;
                                  logger.d('storage permission : ' +
                                      storagePermissionGranted.toString());
                                  if (!storagePermissionGranted) {
                                    return Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                            icon: Icon(Icons.storage),
                                            onPressed: () {
                                              Permission.storage
                                                  .request()
                                                  .then((status) {
                                                if (status.isGranted) {
                                                  setState(() =>
                                                      storagePermissionGranted =
                                                          true);
                                                }
                                              });
                                            }),
                                        Text('Autoriser l\'accès aux fichiers')
                                      ],
                                    ));
                                  } else {
                                    return StreamBuilder<List<String>>(
                                      stream: _getAllStorageFiles(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<String>> snap) {
                                        if (snap.hasData) {
                                          final files = snap.data!;
                                          logger
                                              .i('Files : ' + files.toString());
                                          return Stack(children: [
                                            Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                    icon: Icon(Icons.filter),
                                                    onPressed: () {})),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6),
                                              child: GridView.builder(
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 12,
                                                          mainAxisSpacing: 12),
                                                  itemCount: files.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final file = files[index];
                                                    return FutureBuilder(
                                                      future: compressImage(
                                                          File(file)),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<File>
                                                              s) {
                                                        if (s.hasData) {
                                                          return ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              child: Image(
                                                                  image: FileImage(
                                                                      s.data!),
                                                                  height: 50,
                                                                  width: 50,
                                                                  loadingBuilder: (BuildContext context,
                                                                          Widget
                                                                              child,
                                                                          ImageChunkEvent?
                                                                              loadingProgress) =>
                                                                      loadingProgress ==
                                                                              null
                                                                          ? child
                                                                          : LoadingAnimationWidget.threeArchedCircle(
                                                                              color: Colors.white,
                                                                              size: 20)));
                                                        } else {
                                                          return Container();
                                                        }
                                                      },
                                                    );
                                                  }),
                                            )
                                          ]);
                                        } else {
                                          print('SNAP HAS NO DATA');
                                          return Center(
                                              child: LoadingAnimationWidget
                                                  .threeArchedCircle(
                                                      color: Colors.white,
                                                      size: 50));
                                        }
                                      },
                                    );
                                  }
                                }
                              });
                            }),
                        Container()
                      ]))
                    ])))
          ]);
        });
  }

  static Future<bool> _checkMediaPermission() async =>
      await Permission.storage.isGranted;

  static Stream<List<String>> _getAllStorageFiles() async* {
    // await FileManager(root: (await getExternalStorageDirectory()).listSync(recursive: true)).filesTree(
    //     excludedPaths: ['/storage/emulated/0/Android'],
    //     extensions: ['png', 'jpg', 'jpeg', 'apng', 'gif']);
    // List<File> files = [];
    List<Directory> directories = [];
    List<FileSystemEntity> files = [];
    final roots = (await ExternalPath.getExternalStorageDirectories())
        .map((s) => Directory(s))
        .toList();
    // Root of emulated and sd cards
    for (Directory dir in roots) {
      for (Directory d in dir
          .listSync(recursive: false, followLinks: true)
          .where((e) => e is Directory)
          .cast<Directory>()) {
        if (d.path != dir.path + '/Android') {
          directories.add(d);
        }
      }
      ;
    }

    // ds.addAll((await getExternalCacheDirectories())!);
    // Future<Directory> cD(String ext) async =>
    //     Directory(await ExternalPath.getExternalStoragePublicDirectory(ext));
    // directories.add(await cD(ExternalPath.DIRECTORY_DOWNLOADS));
    // directories.add(await cD(ExternalPath.DIRECTORY_PICTURES));
    // directories.add(await cD(ExternalPath.DIRECTORY_DOCUMENTS));
    // ds.add(await cD(ExternalPath.DIRECTORY_DOCUMENTS));
    // ds.add(await getExternalCacheDirectories())
    logger.i('ALL DIRECTORIES : ' + directories.toString());

    // logger.i('TEST SD CARD PATH : ' +
    //     (await getExternalCacheDirectories())!.map((d) => d.path).toString());
    try {
      for (final Directory directory in directories) {
        // files.addAll(directory
        //     .listSync(recursive: true
        //         //  (directory.path ==
        //         //     await ExternalPath.getExternalStoragePublicDirectory(
        //         //         ExternalPath.DIRECTORY_PICTURES))

        //         )
        //     .toList());
        final fs = (await directory
            .listSync(recursive: true)
            .where((e) => e is File && isImage(e.path))
            .toList()
            .cast<File>());
        Utils.logger.i('ALL FILES : ' + fs.toString());
        files.addAll(fs);
        Utils.logger.i('after adding files');
        yield files.map((f) => f.path).toList();
        ;
        Utils.logger.i('after yield');
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }

    // logger.i('Files testtttttttttttt : ' +
    //     (await cD(ExternalPath.DIRECTORY_PICTURES))
    //         .listSync(recursive: true)
    //         .where((e) => e is File && isImage(e.path))
    //         .toList()
    //         .toString());
    // logger.i('ALL FILES : ' + files.toString());
    // yield files
    //     .where((e) => e is File && isImage(e.path))
    //     .cast<File>()
    //     .toList();
  }

  static bool isImage(String path) {
    final lu = lookupMimeType(path);
    if (lu == null) {
      return false;
    } else {
      return lu.startsWith('image/');
    }
  }

  static Future<File> compressImage(File file) async {
    if (file.statSync().size > 500000) {
      return await FlutterNativeImage.compressImage(file.path,
          quality: 5, percentage: 100);
    } else {
      return file;
    }
  }

  static bool isFileHidden(String path) => basename(path).startsWith('.');
}

extension PaddingExtension on Widget {
  Padding applyPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);
}
