import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/componants/message_thread/message/video_preview.dart';
import 'package:douchat3/componants/shared/cached_image_with_cookie.dart';
import 'package:douchat3/composition_root.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/views/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class GroupSenderMessage extends StatelessWidget {
  final GroupMessage message;
  final bool isLastMessage;
  const GroupSenderMessage(
      {Key? key, required this.message, required this.isLastMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Utils.showModalGroupMessageOptions(
            context: context, message: message, sender: true);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: 0.75,
              child: Stack(children: [
                Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DecoratedBox(
                              decoration: BoxDecoration(
                                  color: message.type == "text"
                                      ? primary
                                      : Colors.transparent,
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
                            height: 30,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                reverse: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: message.reactions.length,
                                itemBuilder: (BuildContext context, int index) =>
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
                                              CompositionRoot.groupService
                                                  .removeReaction({
                                                "clientId":
                                                    Provider.of<ClientProvider>(
                                                            context,
                                                            listen: false)
                                                        .client
                                                        .id,
                                                "emoji":
                                                    message.reactions[index].emoji,
                                                "id": message.id,
                                                "group": message.group
                                              });
                                              Provider.of<GroupProvider>(
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
                                                          .reactions[index].emoji);
                                            } else {
                                              CompositionRoot.groupService
                                                  .addReaction({
                                                "clientId":
                                                    Provider.of<ClientProvider>(
                                                            context,
                                                            listen: false)
                                                        .client
                                                        .id,
                                                "emoji":
                                                    message.reactions[index].emoji,
                                                "id": message.id,
                                                "group": message.group
                                              });
                                              Provider.of<GroupProvider>(
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
                                                          .reactions[index].emoji);
                                            }
                                          },
                                          child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 3, horizontal: 6),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  color: message.reactions[index].ids
                                                          .contains(
                                                              Provider.of<ClientProvider>(context, listen: false)
                                                                  .client
                                                                  .id)
                                                      ? Colors.blue.withOpacity(0.3)
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
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                      DateFormat('dd MMM, h:mm a', 'fr_FR')
                                          .format(message.timeStamp),
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline!
                                          .copyWith(color: Colors.white70))))
                        ])),
              ])),
          !message.type.startsWith('temp')
              ?
              //  Padding(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              //     child: Align(
              //         alignment: Alignment.centerRight,
              //         child: DecoratedBox(
              //             decoration: BoxDecoration(
              //                 color: Colors.black,
              //                 borderRadius: BorderRadius.circular(30)),
              //             child: Icon(Icons.check_circle_rounded,
              //                 color: message.read == true
              //                     ? Colors.green
              //                     : Colors.white,
              //                 size: 20))))
              isLastMessage
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: Builder(builder: (BuildContext context) {
                        String readMessage = "Lu par ";
                        final readBy = List.from(message.readBy);
                        Utils.logger.i('READ BY : ${message.readBy}');
                        readBy.removeWhere((e) => e == Provider.of<ClientProvider>(context, listen: false).client.id);
                        Utils.logger.i('AFTER REMOVAL : $readBy');
                        if (readBy.isNotEmpty) {
                          for (int i = 0;
                              i < readBy.length && i < 3;
                              i++) {
                            final User user = Provider.of<GroupProvider>(
                                    context,
                                    listen: false)
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
                                  "${user.username}${i == 2 || i == (readBy.length - 1) ? ' ' : ', '}";
                            }
                          }
                          if (readBy.length > 3) {
                            final int others = readBy.length - 3;
                            readMessage +=
                                "et ${others} autre${others == 1 ? '' : 's'}";
                          }
                        }
                        return Text(readBy.isEmpty ? '' : readMessage,
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(
                                    color: Colors.white.withOpacity(0.3)));
                      }))
                  : Container()
              : Container()
        ],
      ),
    );
  }

  Widget _handleMessageType(
      {required String type, required BuildContext context}) {
        final readBy = message.readBy;
                        Utils.logger.i('READ BY : ${message.readBy}');
                        readBy.removeWhere((e) => e == Provider.of<ClientProvider>(context, listen: false).client.id);
                        Utils.logger.i('AFTER REMOVAL : $readBy');
    if (type.startsWith('temp_loading') || type.startsWith('temp_error')) {
      if (type.split('_')[2] == 'image') {
        return Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                  height: 170,
                  width: 100,
                  child: Image.file(File(message.content), fit: BoxFit.cover)),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: type.startsWith('temp_loading')
                    ? LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.white, size: 10)
                    : Icon(Icons.error, color: bubbleDark))
          ],
        );
      } else {
        final VideoPlayerController controller =
            VideoPlayerController.file(File(message.content));
        controller.initialize();
        return Stack(children: [
          Align(
              alignment: Alignment.center,
              child: Container(
                  height: 170, width: 100, child: VideoPlayer(controller))),
          Align(
              alignment: Alignment.bottomRight,
              child: type.startsWith('temp_loading')
                  ? LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.white, size: 10)
                  : Icon(Icons.error, color: bubbleDark))
        ]);
      }
    } else if (type == 'text') {
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
                  fit: BoxFit.cover,
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
                child: Hero(
                  tag: message.content,
                  child: CachedImageWithCookie(
                    image: CachedNetworkImage(
                      imageUrl: message.content,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (BuildContext context, String url,
                              DownloadProgress progress) =>
                          LoadingAnimationWidget.threeArchedCircle(
                              color: Colors.white, size: 30),
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.error, color: bubbleDark),
                    ),
                  ),
                ))),
      );
    } else {
      return Container(
          height: 240,
          width: 220,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<String?>(
        future: const FlutterSecureStorage().read(key: 'access_token'),
          builder: (context, AsyncSnapshot<String?> snap) {
        if (snap.hasData) {
          return VideoPreview(url: message.content, cookie: snap.data!);
        } else {
          return LoadingAnimationWidget.threeArchedCircle(
              color: Colors.white, size: 30);
        }
      })));
    }
  }
}
