import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BonitoTheme {
  static const bgDeep      = Color(0xFF000000);
  static const bgPrimary   = Color(0xFF080808);
  static const bgSecondary = Color(0xFF111111);
  static const bgElevated  = Color(0xFF1A1A1A);
  static const bgHover     = Color(0xFF212121);
  static const borderCol   = Color(0xFF1D1D1D);
  static const borderMid   = Color(0xFF2E2E2E);
  static const gold        = Color(0xFFD4D4D4);
  static const goldDim     = Color(0xFF686868);
  static const goldBright  = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFFEEEEEE);
  static const textDim     = Color(0xFFAAAAAA);
  static const textMuted   = Color(0xFF505050);
  static const greenTone   = Color(0xFF909090);
}

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
  textButtonTheme: TextButtonThemeData(style: ButtonStyle(overlayColor: ButtonStyleButton.allOrNull(Colors.white), foregroundColor: ButtonStyleButton.allOrNull(Colors.white70))),
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
