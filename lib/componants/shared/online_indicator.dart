import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';

class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 15,
        width: 15,
        decoration: BoxDecoration(
            color: indicatorBubble,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 3.0, color: Colors.black)));
  }
}
