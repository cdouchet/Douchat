import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final Function(String val)? onChanged;
  final double? height;
  final TextInputAction inputAction;
  final bool hideCharacters;
  final void Function(String str)? onSubmitted;
  final TextEditingController? controller;
  const CustomTextField(
      {Key? key,
      required this.hint,
      required this.onChanged,
      this.controller,
      this.height,
      required this.inputAction,
      this.hideCharacters = false,
      this.onSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        decoration: BoxDecoration(
            color: bubbleDark,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
                color: isLightTheme(context)
                    ? const Color(0xFFC4C4C4)
                    : const Color(0xFF393737),
                width: 1.5)),
        child: TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          obscureText: hideCharacters,
          style: const TextStyle(color: bubbleLight),
          keyboardType: TextInputType.text,
          onChanged: onChanged,
          textInputAction: inputAction,
          cursorColor: primary,
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              hintText: hint,
              border: InputBorder.none),
        ));
  }
}
