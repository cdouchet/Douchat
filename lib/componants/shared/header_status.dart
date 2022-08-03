import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class HeaderStatus extends StatefulWidget {
  final String username;
  final String? photoUrl;
  final bool online;
  final bool? typing;
  const HeaderStatus(
      {Key? key,
      required this.username,
      this.photoUrl,
      required this.online,
      required this.typing})
      : super(key: key);

  @override
  State<HeaderStatus> createState() => _HeaderStatusState();
}

class _HeaderStatusState extends State<HeaderStatus> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.maxFinite,
        child: Row(children: [
          GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: ProfileImage(
                  online: widget.online, photoUrl: widget.photoUrl)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(widget.username.trim(),
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        fontSize: 14.0, fontWeight: FontWeight.bold))),
            Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(widget.typing == null ? 'online' : 'typing',
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 16)))
          ])
        ]));
  }
}
