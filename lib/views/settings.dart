import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/api/api.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/profile_photo.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  final UserService userService;
  const Settings({Key? key, required this.userService}) : super(key: key);

  String get routeName => 'settings';

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with WidgetsBindingObserver {
  bool typing = false;
  final TextEditingController textEditingController = TextEditingController();

    @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("CHANGING APP LIFE CYCLE");
    print(state.toString());
    if (state == AppLifecycleState.resumed) {
      notificationsPlugin.cancelAll();
    }
    Provider.of<AppLifeCycleProvider>(context, listen: false).setAppState(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context, listen: true);
    return Scaffold(
        // appBar: AppBar(
        //     leading: IconButton(
        //         icon: Icon(Icons.arrow_back),
        //         onPressed: () => Navigator.pop(context))),
        body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
          Row(children: [
            IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context))
          ]),
          GestureDetector(
            onTap: () {
              Provider.of<ProfilePhotoProvider>(context, listen: false)
                  .getImage()
                  .then((_) {
                final photoFile =
                    Provider.of<ProfilePhotoProvider>(context, listen: false)
                        .photoFile;
                if (Provider.of<ProfilePhotoProvider>(context, listen: false)
                        .photoFile !=
                    null) {
                  Api.uploadProfilePicture(photoFile).then((url) {
                    widget.userService
                        .changePhotoUrl(context: context, photoUrl: url!);
                  }).catchError((obj) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Erreur durant le téléchargement de l\'image')));
                  });
                }
              });
            },
            child: ClipRRect(
                    borderRadius: BorderRadius.circular(250),
                    child: CachedNetworkImage(
                        imageUrl: clientProvider.client.photoUrl,
                        width: 175,
                        height: 175,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) => const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 102)))
                .applyPadding(const EdgeInsets.only(bottom: 12)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CustomTextField(
              //     hint: clientProvider.client.username,
              //     onChanged: null,
              //     inputAction: TextInputAction.done,
              //     onSubmitted: (String str) {}),
              GestureDetector(
                onTap: () {
                  setState(() => typing = true);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WillPopScope(
                            child: AlertDialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 24),
                                content: GestureDetector(
                                    onTap: () {
                                      if (textEditingController
                                          .text.isNotEmpty) {
                                        print('changing username');
                                        widget.userService.changeUsername(
                                            context: context,
                                            username:
                                                textEditingController.text);
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
                                                  border: InputBorder.none,
                                                  hintText:
                                                      'Entrer un nouveau nom',
                                                  hintStyle: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(
                                                          color: Colors.white
                                                              .withOpacity(0.1),
                                                          fontSize: 24)),
                                              controller: textEditingController,
                                              autofocus: true,
                                              maxLines: 1,
                                              minLines: 1,
                                              textAlign: TextAlign.center,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white))
                                        ])))),
                            onWillPop: () {
                              setState(() => typing = false);

                              return Future.value(true);
                            });
                      });
                },
                child: Container(
                    alignment: Alignment.center,
                    child: Visibility(
                        visible: !typing,
                        child: Container(
                            margin: const EdgeInsets.all(20),
                            child: Text(clientProvider.client.username,
                                style:
                                    Theme.of(context).textTheme.headline4)))),
              ),
              const Icon(FontAwesomeIcons.pencil, color: Colors.white, size: 18)
            ],
          ),
          IconButton(
              onPressed: () => print(Get.currentRoute),
              icon: Icon(Icons.temple_buddhist)),
          Expanded(child: ListView(children: const []))
        ])));
  }
}
