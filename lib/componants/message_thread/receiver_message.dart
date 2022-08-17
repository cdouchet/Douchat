import 'package:douchat3/models/message.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                            child: Text(message.content,
                                softWrap: true,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(height: 1.2)))),
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
                  child: Image.network(photoUrl,
                      width: 30, height: 30, fit: BoxFit.cover)))
        ]));
  }
}
