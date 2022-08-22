import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/componants/shared/online_indicator.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final bool online;
  final String? photoUrl;
  final double size;
  const ProfileImage(
      {Key? key, required this.online, required this.photoUrl, this.size = 126})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Stack(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(126),
              child: photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: photoUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 42),
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 42)),
          Align(
              alignment: Alignment.topRight,
              child: online ? const OnlineIndicator() : Container())
        ]));
  }
}
