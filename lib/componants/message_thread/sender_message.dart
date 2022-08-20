import 'package:douchat3/models/message.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SenderMessage extends StatelessWidget {
  final Message message;
  const SenderMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: 0.75,
        child: Stack(children: [
          Padding(
              padding: const EdgeInsets.only(right: 30),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                DecoratedBox(
                    decoration: BoxDecoration(
                        color: primary,
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
                                .copyWith(height: 1.2, color: Colors.white)))),
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
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30)),
                      child: Icon(Icons.check_circle_rounded,
                          color: message.read == true
                              ? Colors.green
                              : Colors.white,
                          size: 20))))
        ]));
  }
}
