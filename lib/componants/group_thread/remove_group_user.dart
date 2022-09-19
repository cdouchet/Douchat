import 'package:douchat3/componants/shared/custom_text_field.dart';
import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/services/groups/group_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:douchat3/utils/utils.dart';

class RemoveGroupUser extends StatefulWidget {
  final String groupId;
  final GroupService groupService;
  final Group group;
  const RemoveGroupUser(
      {super.key,
      required this.groupService,
      required this.groupId,
      required this.group});

  @override
  State<RemoveGroupUser> createState() => _RemoveGroupUserState();
}

class _RemoveGroupUserState extends State<RemoveGroupUser> {
  List<String> selectedUsers = [];
  TextEditingController controller = TextEditingController();
  String search = '';

  @override
  Widget build(BuildContext context) {
    List<User> users = widget.group.users
        .where((u) =>
            u.id !=
            Provider.of<ClientProvider>(context, listen: false).client.id)
        .toList();
    if (controller.text.isNotEmpty) {
      users.removeWhere((u) => !u.username
          .toLowerCase()
          .trim()
          .contains(controller.text.toLowerCase().trim()));
    }
    return Scaffold(
      body: Center(
        child: Container(
            decoration: BoxDecoration(
                color: background, borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.all(24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(right: 48),
                          child: IconButton(
                              icon:
                                  Icon(Icons.chevron_left, color: Colors.white),
                              onPressed: () => Navigator.pop(context))),
                      Text('Supprimer un utilisateur',
                          style: Theme.of(context).textTheme.bodyMedium)
                    ],
                  )),
              Text('Utilisateurs', style: Theme.of(context).textTheme.bodySmall)
                  .applyPadding(const EdgeInsets.only(bottom: 12)),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: CustomTextField(
                  controller: controller,
                  hint: 'Recherche',
                  onChanged: (s) {
                    search = s;
                    setState(() {});
                  },
                  inputAction: TextInputAction.done,
                ),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        final User user = users[index];
                        return GestureDetector(
                          onTap: () {
                            if (selectedUsers.contains(user.id)) {
                              selectedUsers.remove(user.id);
                            } else {
                              selectedUsers.add(user.id);
                            }
                            setState(() {});
                          },
                          child: ListTile(
                              leading: ProfileImage(
                                  online: user.online,
                                  photoUrl: user.photoUrl,
                                  isGroup: false),
                              title: Text(user.username),
                              trailing: selectedUsers.contains(user.id)
                                  ? Icon(Icons.check, color: Colors.white)
                                  : null),
                        );
                      })),
              Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                ElevatedButton(
                    child: Text('Supprimer'),
                    onPressed: selectedUsers.isNotEmpty ? () {
                      Navigator.pop(context);
                      for (String id in selectedUsers) {
                        widget.groupService
                            .removeGroupUser(userId: id, id: widget.groupId);
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45))))
              ])
            ])),
      ),
    );
  }
}
