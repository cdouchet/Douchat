import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideo extends StatefulWidget {
  final String url;
  final Duration startingDuration;
  final String cookie;
  const FullScreenVideo(
      {super.key,
      required this.url,
      required this.startingDuration,
      required this.cookie});

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  late VideoPlayerController controller;
  late ChewieController chewieController;

  @override
  void initState() {
    try {
      controller = VideoPlayerController.network(widget.url,
          httpHeaders: {'cookie': widget.cookie});
      // controller.initialize();
      chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: true,
          looping: true,
          fullScreenByDefault: true,
          allowMuting: true,
          aspectRatio: controller.value.aspectRatio,
          showControls: true,
          deviceOrientationsOnEnterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp
          ]);
      // Utils.logger.i(widget.startingDuration);
      chewieController.seekTo(widget.startingDuration);
      chewieController.play();
      super.initState();
    } catch (e, s) {
      Utils.logger.i('error in initstate fullscreen video', e, s);
    }
  }

  @override
  void dispose() {
    chewieController.pause();
    controller.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(
                  icon: Icon(Icons.download, color: Colors.white),
                  onPressed: () async {
                    final String cookie = (await const FlutterSecureStorage()
                        .read(key: 'access_token'))!;
                    if (Platform.isAndroid) {
                      FlutterDownloader.enqueue(
                          url: widget.url,
                          savedDir: (await getExternalStorageDirectory())!.path,
                          fileName: widget.url.split('/').last,
                          headers: {'cookie': cookie},
                          openFileFromNotification: true,
                          requiresStorageNotLow: false,
                          saveInPublicStorage: true,
                          showNotification: true);
                    } else if (Platform.isIOS) {
                      GallerySaver.saveVideo(widget.url,
                          headers: {'cookie': cookie});
                      // ImageDownloader.downloadImage(widget.url,
                      //     headers: {'cookie': cookie}).then((String? id) {
                      //   if (id != null) {
                      //     Fluttertoast.showToast(
                      //         msg: 'Image téléchargée',
                      //         gravity: ToastGravity.BOTTOM);
                      //   } else {
                      //     Fluttertoast.showToast(
                      //         msg: 'Erreur durant le téléchargement',
                      //         gravity: ToastGravity.BOTTOM);
                      //   }
                      // });
                    }
                    //  else if (kIsWeb) {
                    //   WebUtils.downloadFile(widget.url);
                    // }
                  })
            ]),
        body: SafeArea(
          child: Center(
            child: Chewie(controller: chewieController),
          ),
        ));
  }
}
