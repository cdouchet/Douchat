import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const background = Color.fromRGBO(21, 21, 21, 1);
const primary = Color(0xFFEF1B48);
const bubbleDark = Color(0xFF262629);
const bubbleLight = Color(0xFFE8E8E8);
const backgroundGrey = Color.fromARGB(255, 86, 86, 86);

final tabBarTheme = TabBarTheme(
    indicatorSize: TabBarIndicatorSize.label,
    unselectedLabelColor: Colors.black54,
    indicator:
        BoxDecoration(borderRadius: BorderRadius.circular(50), color: primary));

ThemeData darkTheme(BuildContext context) => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(backgroundColor: background),
    tabBarTheme: tabBarTheme.copyWith(unselectedLabelColor: Colors.white70),
    textTheme: GoogleFonts.comfortaaTextTheme(Theme.of(context).textTheme)
        .apply(displayColor: Colors.white),
    visualDensity: VisualDensity.adaptivePlatformDensity);

bool isLightTheme(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light;
}
