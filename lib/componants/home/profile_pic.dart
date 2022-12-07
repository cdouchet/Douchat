import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final NetworkImage? image;
  const ProfilePicture({Key? key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      foregroundImage: image,
      backgroundColor: backgroundGrey,
    );
  }
}
