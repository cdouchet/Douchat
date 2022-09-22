import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/group_thread/add_group_user.dart';
import 'package:douchat3/componants/group_thread/remove_group_user.dart';
import 'package:douchat3/componants/group_thread/update_group_admin.dart';
import 'package:douchat3/componants/shared/cached_image_with_cookie.dart';
import 'package:douchat3/models/groups/group.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/services/groups/group_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:douchat3/utils/utils.dart';

class GroupSettings extends StatefulWidget {
  final String groupId;
  final GroupService groupService;
  const GroupSettings(
      {super.key, required this.groupId, required this.groupService});

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  bool typing = false;
  final TextEditingController groupNameEditingController =
      TextEditingController();
  List<String> selectedUsersToRemove = [];

  @override
  Widget build(BuildContext context) {
    final Group group = Provider.of<GroupProvider>(context, listen: true)
        .getGroup(widget.groupId);
    Utils.logger.i('Group admin: ${group.admin}');
    Utils.logger.i(
        'Client id : ${Provider.of<ClientProvider>(context, listen: false).client.id}}');
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(group.name),
            leading: IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context))),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                              borderRadius: BorderRadius.circular(250),
                              child: CachedImageWithCookie(
                                image: CachedNetworkImage(
                                    imageUrl: group.photoUrl ?? "",
                                    width: 175,
                                    height: 175,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, error, stackTrace) =>
                                        const Icon(Icons.group,
                                            color: Colors.white, size: 102)),
                              ))
                          .applyPadding(const EdgeInsets.only(bottom: 12)),
                      if (group.admin ==
                          Provider.of<ClientProvider>(context, listen: true)
                              .client
                              .id) ...[
                        ElevatedButton(
                            onPressed: () {
                              setState(() => typing = true);
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WillPopScope(
                                        child: AlertDialog(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            insetPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 24),
                                            content: GestureDetector(
                                                onTap: () {
                                                  if (groupNameEditingController
                                                      .text.isNotEmpty) {
                                                    print('changing username');
                                                    widget.groupService
                                                        .changeGroupName(
                                                            name:
                                                                groupNameEditingController
                                                                    .text,
                                                            id: widget.groupId);
                                                  }
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    typing = false;
                                                  });
                                                },
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    color: Colors.transparent,
                                                    child: Wrap(children: [
                                                      TextField(
                                                          maxLength: 20,
                                                          decoration: InputDecoration(
                                                              border: InputBorder
                                                                  .none,
                                                              hintText:
                                                                  'Entrer un nouveau nom',
                                                              hintStyle: Theme.of(context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.1),
                                                                      fontSize:
                                                                          24)),
                                                          controller:
                                                              groupNameEditingController,
                                                          autofocus: true,
                                                          maxLines: 1,
                                                          minLines: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyText1!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      Colors.white))
                                                    ])))),
                                        onWillPop: () {
                                          setState(() => typing = false);
                                          return Future.value(true);
                                        });
                                  });
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(FontAwesomeIcons.pencil,
                                          color: Colors.white)),
                                  Text('Changer le nom')
                                ]),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45)))),
                        ElevatedButton(
                            onPressed: () => _changePhoto(group: group),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(Icons.photo,
                                          color: Colors.white)),
                                  Text('Changer la photo'),
                                ]),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45)))),
                        ElevatedButton(
                            onPressed: () => _changeAdmin(group: group),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(Icons.admin_panel_settings,
                                          color: Colors.white)),
                                  Text('Changer l\'administrateur'),
                                ]),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45)))),
                        ElevatedButton(
                            onPressed: () => _removeUser(group: group),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(Icons.delete,
                                          color: Colors.white)),
                                  Text('Supprimer un utilisateur')
                                ]),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45)))),
                        ElevatedButton(
                            onPressed: () => _addUser(group: group),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child:
                                          Icon(Icons.add, color: Colors.white)),
                                  Text('Ajouter un utilisateur'),
                                ]),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45)))),
                        ElevatedButton(
                            onPressed: () => _leaveGroup(),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(Icons.exit_to_app,
                                          color: Colors.white)),
                                  Text('Quitter le groupe'),
                                ]),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45))))
                      ]
                    ]))));
  }

  _leaveGroup() {
    widget.groupService.leaveGroup(
        clientId: Provider.of<ClientProvider>(context, listen: false).client.id,
        id: widget.groupId);
    Navigator.pop(context);
    Navigator.pop(context);
    Provider.of<GroupProvider>(context, listen: false)
        .removeGroup(widget.groupId);
  }

  Future<void> _changePhoto({required Group group}) async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final String? url = await Api.uploadGroupPicture(
          file: File(file.path), id: widget.groupId);
      Utils.logger.i('PHOTO URL : $url');
      if (url != null) {
        widget.groupService.changeGroupPhoto(url: url, id: widget.groupId);
      } else {
        Fluttertoast.showToast(
            msg: 'Erreur durant l\'upload de l\'image',
            gravity: ToastGravity.BOTTOM);
      }
    }
  }

  _addUser({required Group group}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AddGroupUser(
            groupService: widget.groupService,
            groupId: widget.groupId,
            group: group));
  }

  _removeUser({required Group group}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RemoveGroupUser(
              groupService: widget.groupService,
              groupId: widget.groupId,
              group: group);
        });
  }

  _changeAdmin({required Group group}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => UpdateGroupAdmin(
            groupService: widget.groupService,
            groupId: widget.groupId,
            group: group));
  }
}
