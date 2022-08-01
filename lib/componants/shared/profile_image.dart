import 'package:douchat3/componants/shared/online_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfileImage extends StatelessWidget {
  final bool online;
  final String? photoUrl;
  const ProfileImage({Key? key, required this.online, required this.photoUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Stack(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(126),
              child: photoUrl != null
                  ? Image.network(photoUrl!,
                      width: 126, height: 126, fit: BoxFit.cover)
                  : const Icon(Icons.person, color: Colors.white, size: 24)),
          Align(
              alignment: Alignment.topRight,
              child: online ? const OnlineIndicator() : Container())
        ]));
  }
}
