import 'dart:io';

import 'package:douchat3/providers/media_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:export_video_frame/export_video_frame.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({Key? key}) : super(key: key);

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage>
    with AutomaticKeepAliveClientMixin {
  late Stream<List<String>> internalFiles;
  @override
  void initState() {
    internalFiles = _getAllStorageFiles();
    super.initState();
    _initialSetup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initialSetup() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<MediaProvider>(context, listen: false).setFiles([]);
      Provider.of<MediaProvider>(context, listen: false).setPickedFiles([]);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<bool>(
        future: _checkMediaPermission(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          final mediaProvider =
              Provider.of<MediaProvider>(context, listen: true);
          if (!snapshot.hasData) {
            return Container();
          } else {
            bool storagePermissionGranted = snapshot.data!;
            Utils.logger.d(
                'storage permission : ' + storagePermissionGranted.toString());
            if (!storagePermissionGranted) {
              return RefreshIndicator(
                onRefresh: () =>
                    Future.delayed(Duration.zero, () => setState(() {})),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: IconButton(
                            icon: Icon(Icons.storage),
                            onPressed: () async {
                              if (Platform.isAndroid) {
                                Permission.storage.request().then((status) {
                                  if (status.isGranted) {
                                    setState(
                                        () => storagePermissionGranted = true);
                                  }
                                });
                              } else {
                                final PermissionState _ps = await PhotoManager
                                    .requestPermissionExtend();
                                if (_ps.isAuth) {
                                  setState(
                                      () => storagePermissionGranted = true);
                                }
                              }
                            }),
                      ),
                      Text('Autoriser l\'accès aux fichiers')
                    ],
                  ),
                ),
              );
            } else {
              return StreamBuilder<List<String>>(
                stream: internalFiles,
                builder:
                    (BuildContext context, AsyncSnapshot<List<String>> snap) {
                  if (snap.hasData) {
                    final files = snap.data!;
                    Utils.logger.i('Files : ' + files.toString());
                    Utils.logger.i('Provider picked files : ' +
                        mediaProvider.pickedFiles.toString());
                    return Column(
                      children: [
                        if (mediaProvider.pickedFiles.isNotEmpty)
                          Flexible(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 6),
                                  child: Container(
                                    color: bubbleDark,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            mediaProvider.pickedFiles.length,
                                        itemBuilder:
                                            (BuildContext context, int i) {
                                          return Container(
                                              height: 100,
                                              width: 70,
                                              margin: const EdgeInsets.only(
                                                  right: 6),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Stack(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: _isImage(mediaProvider
                                                              .pickedFiles[i]
                                                              .path)
                                                          ? Image(
                                                              image: FileImage(
                                                                  mediaProvider.pickedFiles[
                                                                      i]),
                                                              fit: BoxFit.cover,
                                                              height: 100,
                                                              width: 70,
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
                                                                          size: 20))
                                                          : FutureBuilder(
                                                              future: _generateThumbnail(mediaProvider.pickedFiles[i].path),
                                                              builder: (BuildContext context, AsyncSnapshot<File?> thumbnail) {
                                                                if (thumbnail
                                                                    .hasData) {
                                                                  if (thumbnail
                                                                          .data !=
                                                                      null) {
                                                                    final controller =
                                                                        VideoPlayerController.file(
                                                                            thumbnail.data!);
                                                                    return Stack(
                                                                        children: [
                                                                          Align(
                                                                              alignment: Alignment.center,
                                                                              child: Image.file(thumbnail.data!, fit: BoxFit.cover, height: 100, width: 70)),
                                                                          Align(
                                                                              alignment: Alignment.center,
                                                                              child: Icon(Icons.play_arrow))
                                                                        ]);
                                                                  } else {
                                                                    return Center(
                                                                        child: Icon(
                                                                            Icons.error));
                                                                  }
                                                                } else {
                                                                  return Center(
                                                                      child: LoadingAnimationWidget.threeArchedCircle(
                                                                          color: Colors
                                                                              .white,
                                                                          size:
                                                                              50));
                                                                }
                                                              }),
                                                    ),
                                                  ),
                                                  Align(
                                                      alignment: Alignment
                                                          .bottomLeft,
                                                      child: RawMaterialButton(
                                                          onPressed: () => Provider.of<
                                                                      MediaProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .removePickedFilesAtIndex(
                                                                  i),
                                                          elevation: 0,
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxHeight: 21,
                                                                  maxWidth: 21),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          fillColor:
                                                              Colors.white,
                                                          child: Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.black,
                                                              size: 21),
                                                          shape:
                                                              CircleBorder()))
                                                ],
                                              ));
                                        }),
                                  ))),
                        Expanded(
                          flex: 5,
                          child: Stack(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12),
                                  itemCount: files.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final file = files[index];
                                    final fileo = File(file);
                                    return GestureDetector(
                                      onTap: () {
                                        final mp = Provider.of<MediaProvider>(
                                            context,
                                            listen: false);
                                        if (mp.files
                                            .map((f) => f.path)
                                            .any((f) => f == file)) {
                                          mp.removeFile(fileo);
                                        } else {
                                          mp.addFile(fileo);
                                        }
                                      },
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: _isImage(file)
                                              ? Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Positioned.fill(
                                                      child: Image(
                                                          image:
                                                              FileImage(fileo),
                                                          height: 50,
                                                          width: 50,
                                                          loadingBuilder: (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) =>
                                                              loadingProgress ==
                                                                      null
                                                                  ? child
                                                                  : LoadingAnimationWidget.threeArchedCircle(
                                                                      color: Colors
                                                                          .white,
                                                                      size:
                                                                          20)),
                                                    ),
                                                    if (mediaProvider.files
                                                        .map((f) => f.path)
                                                        .any((f) => f == file))
                                                      Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Icon(
                                                              Icons.check,
                                                              color: primary,
                                                              size: 24)),
                                                  ],
                                                )
                                              : _isVideo(file)
                                                  ? FutureBuilder<File?>(
                                                      future: ExportVideoFrame
                                                          .exportImageBySeconds(
                                                              fileo,
                                                              Duration(
                                                                  seconds: 0),
                                                              0),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<File?>
                                                              thumbnail) {
                                                        if (thumbnail.hasData) {
                                                          if (thumbnail.data !=
                                                              null) {
                                                            return Stack(
                                                                fit: StackFit
                                                                    .expand,
                                                                children: [
                                                                  Positioned.fill(
                                                                      child: Image.file(
                                                                          thumbnail
                                                                              .data!,
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              50)),
                                                                  Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              top:
                                                                                  3,
                                                                              right:
                                                                                  3),
                                                                          child: Icon(
                                                                              Icons.play_arrow,
                                                                              color: Color.fromARGB(255, 199, 199, 199),
                                                                              size: 32))),
                                                                  if (mediaProvider
                                                                      .files
                                                                      .map((f) => f
                                                                          .path)
                                                                      .any((f) =>
                                                                          f ==
                                                                          file))
                                                                    Align(
                                                                        alignment:
                                                                            Alignment
                                                                                .bottomRight,
                                                                        child: Icon(
                                                                            Icons
                                                                                .check,
                                                                            color:
                                                                                primary)),
                                                                ]);
                                                          } else {
                                                            return Center(
                                                                child: Icon(Icons
                                                                    .error));
                                                          }
                                                        } else {
                                                          return Center(
                                                              child: LoadingAnimationWidget
                                                                  .threeArchedCircle(
                                                                      color: Colors
                                                                          .white,
                                                                      size:
                                                                          50));
                                                        }
                                                      })
                                                  : Container()),
                                    );
                                  }),
                            ),
                            Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, right: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(120)),
                                    child: IconButton(
                                        icon: Icon(Icons.fullscreen),
                                        onPressed: () async {
                                          final files = await _pickImages();
                                          if (files != null) {
                                            Utils.logger.i('CHOSEN FILES : ' +
                                                files.toString());
                                            Provider.of<MediaProvider>(context,
                                                    listen: false)
                                                .addAllPickedFiles(files);
                                          }
                                        }),
                                  ),
                                )),
                            if (mediaProvider.files.isNotEmpty)
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    child: RawMaterialButton(
                                        fillColor: primary,
                                        shape: const CircleBorder(),
                                        elevation: 5,
                                        padding: const EdgeInsets.all(12),
                                        child: const Icon(Icons.send),
                                        onPressed: () {
                                          Navigator.pop(context, {
                                            'type': 'medias',
                                            'medias': mediaProvider.files +
                                                mediaProvider.pickedFiles
                                          });
                                        }),
                                  ))
                          ]),
                        ),
                      ],
                    );
                  } else {
                    print('SNAP HAS NO DATA');
                    return Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                            color: Colors.white, size: 50));
                  }
                },
              );
            }
          }
        });
  }

  Future<bool> _checkMediaPermission() async =>
      await Permission.storage.isGranted;

  Stream<List<String>> _getAllStorageFiles() async* {
    if (Platform.isAndroid) {
      List<Directory> directories = [];
      List<FileSystemEntity> files = [];
      Future<Directory> cD(String ext) async =>
          Directory(await ExternalPath.getExternalStoragePublicDirectory(ext));
      directories.add(await cD(ExternalPath.DIRECTORY_DOWNLOADS));
      directories.add(await cD(ExternalPath.DIRECTORY_PICTURES));
      directories.add(await cD(ExternalPath.DIRECTORY_DOCUMENTS));
      Utils.logger.i('ALL DIRECTORIES : ' + directories.toString());
      try {
        for (final Directory directory in directories) {
          final fs = (await directory
              .listSync(recursive: true)
              .where((e) => e is File && (_isImage(e.path) || _isVideo(e.path)))
              .toList()
              .cast<File>());
          Utils.logger.i('ALL FILES : ' + fs.toString());
          files.addAll(fs);
          Utils.logger.i('after adding files');
          files.sort(
              (a, b) => b.statSync().changed.compareTo(a.statSync().changed));
          yield files.map((f) => f.path).toList();
          Utils.logger.i('after yield');
        }
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
      }
    } else {
      try {
        List<String> files = [];
        final List<AssetPathEntity> paths =
            await PhotoManager.getAssetPathList();
        for (int i = 0; i < paths.length; i++) {
          for (AssetPathEntity path in paths) {
            for (AssetEntity event
                in await path.getAssetListRange(start: 0, end: 80)) {
              File? f = await event.file;
              if (f != null) {
                files.add(f.path);
                yield files;
              }
            }
            // paths[i]
            //     .getAssetListRange(start: 0, end: 80)
            //     .asStream()
            //     .listen((event) {
            //   event.forEach((e) async {
            //     File? f = await e.file;
            //     Utils.logger.i("New file : ${f}");
            //     if (f != null) {
            //       files.add(f.path);
            //     }
            //   });
            // });
          }
        }
        // LocalImageProvider imageProvider = LocalImageProvider();
        // bool hasPermission = await imageProvider.initialize();
        // if (hasPermission) {
        //   final images = await imageProvider.findLatest(50);
        //   if (images.isNotEmpty) {
        //     images.first;
        //   }
        // }
      } catch (e, s) {
        Utils.logger.i('Error while processing ios medias', e, s);
      }
    }
  }

  Future<List<File>?> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 50);
    return files.map((f) => File(f.path)).toList();
    return null;
  }

  bool _isImage(String path) {
    final lu = lookupMimeType(path);
    if (lu == null) {
      return false;
    } else {
      return lu.startsWith('image/');
    }
  }

  bool _isVideo(String path) {
    final lu = lookupMimeType(path);
    if (lu == null) {
      return false;
    } else {
      return lu.startsWith('video/');
    }
  }

  static Future<File?> _generateThumbnail(String videoPath) async {
    final p = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        quality: 50,
        imageFormat: ImageFormat.PNG,
        thumbnailPath: (await getTemporaryDirectory()).path);
    if (p == null) {
      return null;
    }
    return File(p);
  }

  Future<File> _compressImage(File file) async {
    if (file.statSync().size > 500000 && _isImage(file.path)) {
      return await FlutterNativeImage.compressImage(file.path,
          quality: 5, percentage: 100);
    } else {
      return file;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  bool get wantKeepAlive => true;
}
