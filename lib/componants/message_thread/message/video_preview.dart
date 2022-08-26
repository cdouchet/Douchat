import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  const VideoPreview({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late BetterPlayerController controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    final BetterPlayerDataSource dataSource =
        BetterPlayerDataSource.network(widget.url);
    controller = BetterPlayerController(
        BetterPlayerConfiguration(
            autoPlay: false,
            fit: BoxFit.cover,
            looping: true,
            controlsConfiguration: BetterPlayerControlsConfiguration(
                enableFullscreen: false,
                enableAudioTracks: false,
                enableMute: false,
                enableOverflowMenu: false,
                enablePip: false,
                enablePlayPause: false,
                enableProgressBar: false,
                enablePlaybackSpeed: false,
                enableProgressBarDrag: false,
                enableProgressText: false,
                enableQualities: false,
                enableRetry: false,
                enableSkips: false,
                enableSubtitles: false)),
        betterPlayerDataSource: dataSource);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleOnTap,
      child: Container(
          height: 240,
          width: 220,
          child: Stack(
            children: [
              Icon(Icons.play_arrow,
                  color: Color.fromARGB(255, 98, 98, 98), size: 30),
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BetterPlayer.network(widget.url)),
            ],
          )),
    );
  }

  void _handleOnTap() {
    if (!isPlaying) {
      controller.play();
      isPlaying = true;
      setState(() {});
    } else {}
  }
}
