import 'package:chewie/chewie.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideo extends StatefulWidget {
  final String url;
  final Duration startingDuration;
  const FullScreenVideo({super.key, required this.url, required this.startingDuration});

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  late VideoPlayerController controller;
  late ChewieController chewieController;

  @override
  void initState() {
    controller = VideoPlayerController.network(widget.url);
    controller.initialize();
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
        Utils.logger.i(widget.startingDuration);
        chewieController.seekTo(widget.startingDuration);
        chewieController.play();
    super.initState();
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
    return Scaffold(body: SafeArea(
      child: Center(
        child: Stack(
          children: [
            Chewie(controller: chewieController),
            Align(alignment: Alignment.topLeft, child: IconButton(icon: Icon(Icons.chevron_left, color: Colors.white), onPressed: () => Navigator.pop(context))),
          ],
        ),
      ),
    ));
  }
}