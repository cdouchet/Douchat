import 'package:douchat3/componants/shared/custom_text_field.dart';
import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  List<User> selectedUsers = [];
  late TextEditingController titleController = TextEditingController();
  late TextEditingController searchController = TextEditingController();
  String title = '';
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: Text('Annuler',
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.blue)),
              ),
              Text('Nouveau groupe'),
              Builder(builder: (context) {
                final bool cc =
                    selectedUsers.length > 1 && titleController.text.isNotEmpty;
                return GestureDetector(
                    onTap: () {
                      if (cc) {
                        Navigator.pop(context, {
                          'title': titleController.text,
                          'users': selectedUsers.map((u) => u.id).toList()
                        });
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text('Créer',
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: cc ? Colors.blue : Colors.grey)));
              }),
            ]).applyPadding(const EdgeInsets.only(bottom: 24)),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomTextField(
                      controller: titleController,
                      hint: 'Nouveau groupe',
                      onChanged: (s) {
                        title = s;
                      },
                      inputAction: TextInputAction.done,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: selectedUsers.length,
                        itemBuilder: (BuildContext context, int index) {
                          final User u =
                              Provider.of<UserProvider>(context, listen: true)
                                  .users
                                  .firstWhere(
                                      (us) => us.id == selectedUsers[index].id);
                          return ListTile(
                              leading: ProfileImage(
                                  online: u.online, photoUrl: u.photoUrl),
                              title: Text(u.username),
                              trailing: GestureDetector(
                                  onTap: () {
                                    selectedUsers.remove(u);
                                    setState(() {});
                                  },
                                  child:
                                      Icon(Icons.delete, color: Colors.white)));
                        }),
                  ),
                ],
              ),
            ),
            Text('Users', style: Theme.of(context).textTheme.bodyMedium)
                .applyPadding(const EdgeInsets.only(bottom: 18)),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                child: CustomTextField(
                  controller: searchController,
                  hint: 'Recherche',
                  onChanged: (s) {
                    search = s;
                    setState(() {});
                  },
                  inputAction: TextInputAction.done,
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                padding: EdgeInsets.only(bottom: 60),
                child: Builder(builder: (context) {
                  List<User> up =
                      Provider.of<UserProvider>(context, listen: true).users;
                  if (searchController.text.isNotEmpty) {
                    up = up
                        .where((u) => u.username
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase()))
                        .toList();
                  }
                  return ListView.builder(
                      itemCount: up.length,
                      itemBuilder: (BuildContext context, int index) {
                        final u = up[index];
                        return GestureDetector(
                          onTap: () {
                            if (selectedUsers.contains(u)) {
                              selectedUsers.remove(u);
                            } else {
                              selectedUsers.add(u);
                            }
                            setState(() {});
                          },
                          child: ListTile(
                              leading: ProfileImage(
                                  online: u.online, photoUrl: u.photoUrl),
                              title: Text(u.username),
                              trailing: selectedUsers.contains(u)
                                  ? Icon(Icons.check, color: Colors.white)
                                  : null),
                        );
                      });
                }),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
