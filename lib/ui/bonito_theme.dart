import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final defaultDarkTheme = ThemeData.dark();
final bonitoTextTheme = GoogleFonts.robotoTextTheme(
  defaultDarkTheme.textTheme.copyWith(
        displayMedium:
            const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        displaySmall:
            const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        headlineMedium:
            const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
        headlineSmall:
            const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        titleMedium: const TextStyle(fontSize: 18.0),
        titleSmall:
            const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
        bodyMedium: const TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.normal, height: 1.4),
        bodySmall: const TextStyle(fontSize: 14.0),
        labelMedium: const TextStyle(fontSize: 14.0),
        labelSmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w300,
          color: Colors.grey.shade300,
        ),
      ),
);
final bonitoTheme = defaultDarkTheme.copyWith(
  primaryColor: Colors.white70,
  textTheme: bonitoTextTheme.apply(bodyColor: Colors.white),
  focusColor: Colors.white,
  colorScheme:
      defaultDarkTheme.colorScheme.copyWith(primary: Colors.white),
  dividerColor: Colors.white70,
  listTileTheme: const ListTileThemeData(
    selectedColor: Colors.white,
    selectedTileColor: Colors.white10,
    textColor: Colors.white,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    hintStyle: TextStyle(
      color: Colors.amber,
    ),
    labelStyle: TextStyle(
      color: Colors.white,
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(style: BorderStyle.solid, color: Colors.white),
    ),
  )
);
