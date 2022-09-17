// import 'package:better_player/better_player.dart';
// import 'package:flutter/material.dart';

// class VideoPreview extends StatefulWidget {
//   final String url;
//   const VideoPreview({Key? key, required this.url}) : super(key: key);

//   @override
//   State<VideoPreview> createState() => _VideoPreviewState();
// }

// class _VideoPreviewState extends State<VideoPreview> {
//   late BetterPlayerController controller;
//   bool isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     final BetterPlayerDataSource dataSource =
//         BetterPlayerDataSource.network(widget.url);
//     controller = BetterPlayerController(
//         BetterPlayerConfiguration(
//             autoPlay: false,
//             fit: BoxFit.cover,
//             looping: true,
//             controlsConfiguration: BetterPlayerControlsConfiguration(
//                 enableFullscreen: false,
//                 enableAudioTracks: false,
//                 enableMute: false,
//                 enableOverflowMenu: false,
//                 enablePip: false,
//                 enablePlayPause: false,
//                 enableProgressBar: false,
//                 enablePlaybackSpeed: false,
//                 enableProgressBarDrag: false,
//                 enableProgressText: false,
//                 enableQualities: false,
//                 enableRetry: false,
//                 enableSkips: false,
//                 enableSubtitles: false)),
//         betterPlayerDataSource: dataSource);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _handleOnTap,
//       child: Container(
//           height: 240,
//           width: 220,
//           child: Stack(
//             children: [
//               Icon(Icons.play_arrow,
//                   color: Color.fromARGB(255, 98, 98, 98), size: 30),
//               ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: BetterPlayer(controller: controller)),
//             ],
//           )),
//     );
//   }

//   void _handleOnTap() {
//     if (!isPlaying) {
//       controller.play();
//       isPlaying = true;
//       setState(() {});
//     } else {}
//   }
// }

import 'package:douchat3/componants/message_thread/message/fullscreen_video.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  const VideoPreview({super.key, required this.url});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideo;
  late ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url, videoPlayerOptions: VideoPlayerOptions());
    _initializeVideo = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 220,
      child: FutureBuilder<void>(future: _initializeVideo, builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.connectionState == ConnectionState.done) {
          return GestureDetector(onTap: () {
            if (!_controller.value.isPlaying) {
              _controller.play();
              isPlaying.value = true;
            } else {
              _controller.seekTo(Duration());
              _controller.pause();
              isPlaying.value = false;
              Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenVideo(url: widget.url, startingDuration: _controller.value.position)));
            }
          }, child: 
           ValueListenableBuilder<bool>(
            valueListenable: isPlaying,
             builder: (context, bool value, Widget? child) {
              return AspectRatio(aspectRatio: _controller.value.aspectRatio, child: Stack(
                children: [
                  VideoPlayer(_controller),
                           if (!value)
                  Align(alignment: Alignment.center, child: Icon(FontAwesomeIcons.play, color: Colors.white))
                ],
              ));
             }
           ));
        } else {
          return LoadingAnimationWidget.threeArchedCircle(color: Colors.white, size: 30);
        }
      }),
    );
  }
}