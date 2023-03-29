import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/componants/shared/user_details.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupUsersView extends StatefulWidget {
  final String groupId;
  const GroupUsersView({super.key, required this.groupId});

  @override
  State<GroupUsersView> createState() => _GroupUsersViewState();
}

class _GroupUsersViewState extends State<GroupUsersView> {
  late Group group =
      Provider.of<GroupProvider>(context).getGroup(widget.groupId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height * 0.80,
            decoration: BoxDecoration(color: background),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Row(
                  children: [
                    IconButton(
                        iconSize: 32,
                        icon: Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                SizedBox(height: 30),
                Flexible(
                    child: Text("Membres de ${group.name}",
                        style: TextStyle(color: Colors.white, fontSize: 32))),
                SizedBox(height: 50),
                Expanded(
                  child: ListView.builder(
                      itemCount: group.users.length - 1,
                      itemBuilder: (context, index) {
                        final u = group.users.elementAt(index);
                        if (u.id ==
                            Provider.of<ClientProvider>(context, listen: false)
                                .client
                                .id) {
                          return Container();
                        }
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) =>
                                    UserDetails(user: u, conversation: false));
                          },
                          child: ListTile(
                              leading: ProfileImage(
                                  online: u.online, photoUrl: u.photoUrl),
                              title: Text(u.username)),
                        );
                      }),
                )
              ],
            )),
      ),
    );
  }
}
