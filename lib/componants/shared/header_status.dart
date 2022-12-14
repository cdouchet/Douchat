import 'package:douchat3/componants/group_thread/group_details.dart';
import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/componants/shared/user_details.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeaderStatus extends StatefulWidget {
  final String username;
  final String? photoUrl;
  final bool online;
  final bool? typing;
  final bool isGroup;
  final String? groupId;
  bool isPrivateThread;
  final String? privateThreadUserId;
  HeaderStatus(
      {Key? key,
      required this.username,
      this.photoUrl,
      required this.online,
      required this.typing,
      this.isGroup = false,
      this.isPrivateThread = false,
      this.privateThreadUserId,
      this.groupId})
      : assert((isGroup ? groupId != null : groupId == null) &&
            (isPrivateThread
                ? privateThreadUserId != null
                : privateThreadUserId == null)),
        super(key: key);

  @override
  State<HeaderStatus> createState() => _HeaderStatusState();
}

class _HeaderStatusState extends State<HeaderStatus> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.maxFinite,
        child: Row(children: [
          GestureDetector(
              onTap: () {
                if (widget.isGroup) {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) =>
                          GroupDetails(groupId: widget.groupId!));
                  return;
                }
                if (widget.isPrivateThread) {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25))),
                      context: context,
                      builder: (context) => UserDetails(
                          conversation: false,
                          user:
                              Provider.of<UserProvider>(context, listen: false)
                                  .users
                                  .firstWhere(
                                    (u) => u.id == widget.privateThreadUserId,
                                  )));
                  return;
                }
                Scaffold.of(context).openDrawer();
              },
              child: ProfileImage(
                  online: widget.online,
                  photoUrl: widget.photoUrl,
                  isGroup: widget.isGroup)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(widget.username.trim(),
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        fontSize: 14.0, fontWeight: FontWeight.bold))),
            Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                    widget.typing == null
                        ? widget.online
                            ? 'En ligne'
                            : 'Hors ligne'
                        : 'typing',
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 12)))
          ])
        ]));
  }
}
