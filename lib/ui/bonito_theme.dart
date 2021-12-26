import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final bonitoTextTheme = GoogleFonts.latoTextTheme(
  ThemeData.dark().textTheme.copyWith(
    headline2: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    headline3: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    headline4: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
    subtitle1: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
    subtitle2: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
    bodyText2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
  ),
);
final bonitoTheme = ThemeData.dark().copyWith(
  textTheme: bonitoTextTheme,
);
