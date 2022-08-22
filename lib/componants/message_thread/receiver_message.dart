import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/models/message.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';

class ReceiverMessage extends StatelessWidget {
  final String photoUrl;
  final Message message;
  const ReceiverMessage(
      {Key? key, required this.photoUrl, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        alignment: Alignment.topLeft,
        widthFactor: 0.75,
        child: Stack(children: [
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                        decoration: BoxDecoration(
                            color: bubbleDark,
                            borderRadius: BorderRadius.circular(30)),
                        position: DecorationPosition.background,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: _handleMessageType(
                                type: message.type, context: context))),
                    Padding(
                        padding: const EdgeInsets.only(top: 12, left: 12),
                        child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                                DateFormat('dd MMM, h:mm a', 'fr_FR')
                                    .format(message.timeStamp),
                                style: Theme.of(context)
                                    .textTheme
                                    .overline!
                                    .copyWith(color: Colors.white70))))
                  ])),
          CircleAvatar(
              backgroundColor: Colors.black,
              radius: 18,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Icon(Icons.person, color: Colors.white),
                  )))
        ]));
  }

  Widget _handleMessageType(
      {required String type, required BuildContext context}) {
    if (type == 'text') {
      return Text(message.content,
          softWrap: true,
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(height: 1.2, color: Colors.white));
    } else if (type == 'gif') {
      return Container(
        height: 240,
        width: 220,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
                imageUrl: message.content,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (BuildContext context, String url,
                        DownloadProgress loadingProgress) =>
                    LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.white, size: 50))),
      );
    } else if (type == 'image') {
      return Container(
          height: 240,
          width: 220,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: message.content,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (BuildContext context, String url,
                        DownloadProgress progress) =>
                    LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.white, size: 30),
                errorWidget: (_, __, ___) => Icon(
                  Icons.error,
                  color: bubbleDark,
                ),
              )));
    } else {
      final VideoPlayerController controller =
          VideoPlayerController.network(message.content);
      return Container(
          height: 240,
          width: 220,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VideoPlayer(controller)));
    }
  }
}
