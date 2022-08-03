import 'package:douchat3/componants/shared/custom_text_field.dart';
import 'package:douchat3/componants/shared/profile_image.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/services/users/user_service.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  final UserService userService;
  const Settings({Key? key, required this.userService}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool typing = false;

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
          ClipRRect(
                  borderRadius: BorderRadius.circular(250),
                  child: Image.network(clientProvider.client.photoUrl,
                      width: 175, height: 175))
              .applyPadding(const EdgeInsets.only(bottom: 12)),
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
                                insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 24),
                                content: GestureDetector(
                                    onTap: () {
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
                                              decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText:
                                                      'Entrer un nouveau nom'))
                                        ])))),
                            onWillPop: () {
                              setState(() => typing = false);
                              return Future.value(true);
                            });
                      });
                },
                child: Text(clientProvider.client.username.trim(),
                        style: Theme.of(context).textTheme.headline4)
                    .applyPadding(const EdgeInsets.only(right: 6)),
              ),
              Icon(FontAwesomeIcons.pencil, color: Colors.white, size: 18)
            ],
          ),
          Expanded(child: ListView(children: []))
        ])));
  }
}
