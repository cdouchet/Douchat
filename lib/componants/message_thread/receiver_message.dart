import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/componants/message_thread/message/video_preview.dart';
import 'package:douchat3/componants/shared/cached_image_with_cookie.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/conversations/message.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/conversation_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/views/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ReceiverMessage extends StatelessWidget {
  final String photoUrl;
  final Message message;
  const ReceiverMessage(
      {Key? key, required this.photoUrl, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Utils.showModalMessageOptions(
            context: context, message: message, sender: false);
      },
      child: FractionallySizedBox(
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
                              color: message.type == "text" ? bubbleDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(30)),
                          position: DecorationPosition.background,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              child: _handleMessageType(
                                  type: message.type, context: context))),
                      if (message.reactions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: SizedBox(
                            height: 23,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: message.reactions.length,
                                itemBuilder: (BuildContext context,
                                        int index) =>
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            if (message.reactions[index].ids
                                                .contains(
                                                    Provider.of<ClientProvider>(
                                                            context,
                                                            listen: false)
                                                        .client
                                                        .id)) {
                                              CompositionRoot.messageService
                                                  .removeReaction({
                                                "clientId":
                                                    Provider.of<ClientProvider>(
                                                            context,
                                                            listen: false)
                                                        .client
                                                        .id,
                                                "emoji": message
                                                    .reactions[index].emoji,
                                                "id": message.id,
                                                "to": message.to
                                              });
                                              Provider.of<ConversationProvider>(
                                                      context,
                                                      listen: false)
                                                  .removeReaction(
                                                      id: message.id,
                                                      userId: Provider.of<
                                                                  ClientProvider>(
                                                              context,
                                                              listen: false)
                                                          .client
                                                          .id,
                                                      emoji: message
                                                          .reactions[index]
                                                          .emoji);
                                            } else {
                                              CompositionRoot.messageService
                                                  .addReaction({
                                                "clientId":
                                                    Provider.of<ClientProvider>(
                                                            context,
                                                            listen: false)
                                                        .client
                                                        .id,
                                                "emoji": message
                                                    .reactions[index].emoji,
                                                "id": message.id,
                                                "to": message.to
                                              });
                                              Provider.of<ConversationProvider>(
                                                      context,
                                                      listen: false)
                                                  .addReaction(
                                                      id: message.id,
                                                      userId: Provider.of<
                                                                  ClientProvider>(
                                                              context,
                                                              listen: false)
                                                          .client
                                                          .id,
                                                      emoji: message
                                                          .reactions[index]
                                                          .emoji);
                                            }
                                          },
                                          child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 3, horizontal: 6),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  color: message
                                                          .reactions[index].ids
                                                          .contains(
                                                              Provider.of<ClientProvider>(context, listen: false)
                                                                  .client
                                                                  .id)
                                                      ? Colors.blue
                                                          .withOpacity(0.3)
                                                      : Color.fromARGB(
                                                          255, 63, 63, 63)),
                                              child: Text(
                                                  "${message.reactions[index].emoji} ${message.reactions[index].ids.length}",
                                                  style: TextStyle(fontSize: 14)))),
                                    )),
                          ),
                        ),
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
                    child: CachedImageWithCookie(
                      image: CachedNetworkImage(
                        imageUrl: photoUrl,
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            Icon(Icons.person, color: Colors.white),
                      ),
                    )))
          ])),
    );
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
            child: CachedImageWithCookie(
              image: CachedNetworkImage(
                  imageUrl: message.content,
                  fit: BoxFit.fill,
                  progressIndicatorBuilder: (BuildContext context, String url,
                          DownloadProgress loadingProgress) =>
                      LoadingAnimationWidget.threeArchedCircle(
                          color: Colors.white, size: 50)),
            )),
      );
    } else if (type == 'image') {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ImagePreview(imageUrl: message.content)));
        },
        child: Container(
            height: 240,
            width: 220,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedImageWithCookie(
                  image: CachedNetworkImage(
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
                  ),
                ))),
      );
    } else {
      return FutureBuilder<String?>(
          future: const FlutterSecureStorage().read(key: 'access_token'),
          builder: (context, AsyncSnapshot<String?> snap) {
        if (snap.hasData) {
          return ClipRRect(borderRadius: BorderRadius.circular(12), child: VideoPreview(url: message.content, cookie: snap.data!));
        } else {
          return LoadingAnimationWidget.threeArchedCircle(
              color: Colors.white, size: 30);
        }
      });
    }
  }
}
