import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/componants/message_thread/message/video_preview.dart';
import 'package:douchat3/componants/shared/cached_image_with_cookie.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/views/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class GroupReceiverMessage extends StatelessWidget {
  final String photoUrl;
  final GroupMessage message;
  final bool isLastMessage;
  const GroupReceiverMessage(
      {Key? key,
      required this.photoUrl,
      required this.message,
      required this.isLastMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Utils.showModalGroupMessageOptions(
            context: context, message: message, sender: false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 6),
            child: Text((Provider.of<UserProvider>(context, listen: true)
                .users
                .firstWhere((u) => u.id == message.from,
                    orElse: () =>
                        Provider.of<GroupProvider>(context, listen: true)
                            .getGroup(message.group)
                            .users
                            .firstWhere((u) => u.id == message.from))).username, style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(color: Colors.white.withOpacity(0.8))),
          ),
          FractionallySizedBox(
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
          isLastMessage
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    left: 8,
                  ),
                  child: Builder(builder: (BuildContext context) {
                    String readMessage = "Lu par ";
                    List<String> readBy = message.readBy;
                    readBy.removeWhere((e) =>
                        e ==
                        Provider.of<ClientProvider>(context, listen: false)
                            .client
                            .id);
                    for (int i = 0; i < readBy.length && i < 3; i++) {
                      final User user =
                          Provider.of<GroupProvider>(context, listen: false)
                              .getGroup(message.group)
                              .users
                              .firstWhere((u) => u.id == readBy[i],
                                  orElse: () => User(
                                      id: 'no_user',
                                      username: '',
                                      photoUrl: '',
                                      online: false));
                      if (user.id != 'no_user') {
                        readMessage +=
                            "${user.username}${i == 2 || i == (readBy.length - 1) ? ' ' : ','}";
                      }
                    }
                    if (readBy.length > 3) {
                      final int others = readBy.length - 3;
                      readMessage +=
                          "et ${others} autre${others == 1 ? '' : 's'}}";
                    }
                    return Text(readBy.length == 0 ? '' : readMessage,
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: Colors.white.withOpacity(0.3)));
                  }))
              : Container()
        ],
      ),
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
