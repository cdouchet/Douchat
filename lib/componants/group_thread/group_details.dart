import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/componants/group_thread/group_users_view.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class GroupDetails extends StatefulWidget {
  final String groupId;
  const GroupDetails({super.key, required this.groupId});

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  Future<String> getToken() async {
    return await const FlutterSecureStorage().read(key: "access_token") ?? "";
  }

  late Group group =
      Provider.of<GroupProvider>(context).getGroup(widget.groupId);

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(color: background),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Transform.translate(
                offset: Offset(0, -100),
                child: FutureBuilder<String>(
                    future: getToken(),
                    builder: (context, snap) {
                      return snap.hasData
                          ? CircleAvatar(
                              maxRadius: 80,
                              minRadius: 80,
                              backgroundImage: CachedNetworkImageProvider(
                                  group.photoUrl ?? "",
                                  headers: {"cookie": snap.data!}))
                          : Container();
                    }),
              )
            ]),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.translate(
                      offset: Offset(0, -80),
                      child: Text(
                        group.name,
                        style: TextStyle(color: Colors.white, fontSize: 36),
                        overflow: TextOverflow.ellipsis,
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) =>
                                GroupUsersView(groupId: widget.groupId));
                      },
                      child: ListTile(
                          leading:
                              Icon(Icons.group, color: Colors.red, size: 30),
                          title: Text("Voir les memebres")))
                ]),
          ],
        ));
  }
}
