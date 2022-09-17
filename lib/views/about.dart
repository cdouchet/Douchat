import 'package:douchat3/main.dart';
import 'package:douchat3/providers/app_life_cycle_provider.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> with WidgetsBindingObserver {
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
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => Navigator.pop(context))),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                        child: Text('A propos...',
                            style: Theme.of(context).textTheme.headline3))
                    .applyPadding(const EdgeInsets.only(bottom: 30)),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30)),
                            child: Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 20))
                        .applyPadding(const EdgeInsets.only(right: 12)),
                    Flexible(
                      child: Text(
                          'Cette icône signifie que le message a été envoyé mais n\'a pas encore été lu.'),
                    ),
                  ],
                ).applyPadding(const EdgeInsets.only(bottom: 12)),
                Row(
                  children: [
                    DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30)),
                            child: Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 20))
                        .applyPadding(const EdgeInsets.only(right: 12)),
                    Flexible(
                      child: Text(
                          'Cette icône signifie que le message a été envoyé et a été lu.'),
                    ),
                  ],
                ).applyPadding(const EdgeInsets.only(bottom: 24)),
                Text('Vous pouvez ajouter des contacts via le menu partage d\'identifiants > Scanner un code QR.')
                    .applyPadding(const EdgeInsets.only(bottom: 24)),
                Text('Si vous me demandez très gentillement, je chercherai à faire une version iOS.')
                    .applyPadding(const EdgeInsets.only(bottom: 48)),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.heart, color: Colors.red)
                        .applyPadding(const EdgeInsets.only(right: 18)),
                    Flexible(
                      child: Text(
                          'A big shoutout to island coder 876 on Youtube (go subscribe) A.K.A vykes-mac on Github for the base structure and design of the app.'),
                    ),
                  ],
                )
              ],
            )
          ]),
        )));
  }
}
