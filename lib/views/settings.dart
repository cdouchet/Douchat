import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/api/api.dart';
import 'package:douchat3/componants/shared/cached_image_with_cookie.dart';
import 'package:douchat3/main.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/profile_photo.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final TextEditingController emailController = TextEditingController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("CHANGING APP LIFE CYCLE");
    print(state.toString());
    if (state == AppLifecycleState.resumed) {
      notificationsPlugin.cancelAll();
    }
    Provider.of<AppLifeCycleProvider>(context, listen: false)
        .setAppState(state);
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
            child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(children: [
          IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context))
        ]),
        ClipRRect(
            borderRadius: BorderRadius.circular(250),
            child: CachedImageWithCookie(
                image: CachedNetworkImage(
                    imageUrl: clientProvider.client.photoUrl,
                    width: 175,
                    height: 175,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) {
                      return const Icon(Icons.person,
                          color: Colors.white, size: 102);
                    }))).applyPadding(const EdgeInsets.only(bottom: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                child: Visibility(
                    visible: !typing,
                    child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Text(clientProvider.client.username,
                            style: Theme.of(context).textTheme.headline4)))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
              onPressed: () => _changeUsername(),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(FontAwesomeIcons.pencil, color: Colors.white)),
                Text('Changer de nom'),
              ]),
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45)))),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
              onPressed: () => _changePhoto(),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.photo, color: Colors.white)),
                Text('Changer de photo'),
              ]),
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45)))),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45))),
            onPressed: () => _changeEmail(),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.email, color: Colors.white)),
              Text("Changer d'email")
            ]))
      ]),
    )));
  }

  _changePhoto() {
    Provider.of<ProfilePhotoProvider>(context, listen: false)
        .getImage()
        .then((_) {
      final photoFile =
          Provider.of<ProfilePhotoProvider>(context, listen: false).photoFile;
      if (Provider.of<ProfilePhotoProvider>(context, listen: false).photoFile !=
          null) {
        try {
          Api.uploadProfilePicture(photoFile).then((url) {
            widget.userService.changePhotoUrl(context: context, photoUrl: url!);
          });
        } catch (e, s) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Erreur durant le téléchargement de l\'image')));
          Utils.logger.i("Could not update photo url through api", e, s);
        }
      }
    });
  }

  _changeEmail() {
    setState(() => typing = true);
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            child: AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                content: GestureDetector(
                    onTap: () {
                      if (emailController.text.isNotEmpty) {
                        Api.updateEmail(emailController.text).then((res) {
                          String text = "";
                          if (res.statusCode == 401) {
                            text = "Relancez l'application";
                          } else if (res.statusCode == 500) {
                            text =
                                "Erreur du serveur. Veuillez réessayer plus tard";
                          } else {
                            text = "Votre email a été mise à jour";
                          }

                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(text)));
                          Navigator.of(context).pop();
                          setState(() {
                            typing = false;
                          });
                        });
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: Wrap(children: [
                          TextField(
                              maxLength: 20,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Entrer une nouvelle email',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(
                                          color: Colors.white.withOpacity(0.1),
                                          fontSize: 24)),
                              controller: emailController,
                              autofocus: true,
                              maxLines: 1,
                              minLines: 1,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ])))),
            onWillPop: () {
              setState(() => typing = false);

              return Future.value(true);
            },
          );
        });
  }

  _changeUsername() {
    setState(() => typing = true);
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
              child: AlertDialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  content: GestureDetector(
                      onTap: () {
                        if (textEditingController.text.isNotEmpty) {
                          print('changing username');
                          widget.userService.changeUsername(
                              context: context,
                              username: textEditingController.text);
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
                                    hintText: 'Entrer un nouveau nom',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            fontSize: 24)),
                                controller: textEditingController,
                                autofocus: true,
                                maxLines: 1,
                                minLines: 1,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))
                          ])))),
              onWillPop: () {
                setState(() => typing = false);

                return Future.value(true);
              });
        });
  }
}
