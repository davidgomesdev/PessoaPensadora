import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final bonitoTextTheme = GoogleFonts.robotoTextTheme(
  ThemeData.dark().textTheme.copyWith(
        headline2: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        headline3: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        headline4:
            const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
        headline5: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        subtitle1: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
        subtitle2: const TextStyle(fontSize: 14.0),
        bodyText2: const TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.normal, height: 1.4),
      ),
);
final bonitoTheme = ThemeData.dark().copyWith(
  textTheme: bonitoTextTheme,
);
