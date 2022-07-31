import 'package:douchat3/themes/colors.dart';
import 'package:flutter/widgets.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        width: 50,
        child: isLightTheme(context)
            ? Image.asset('assets/shower2.png', fit: BoxFit.fill)
            : Image.asset('assets/shower2.png', fit: BoxFit.fill));
  }
}
