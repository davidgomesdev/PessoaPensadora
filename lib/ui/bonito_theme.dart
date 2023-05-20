import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final bonitoTextTheme = GoogleFonts.robotoTextTheme(
  ThemeData.dark().textTheme.copyWith(
        displayMedium:
            const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        displaySmall:
            const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        headlineMedium:
            const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
        headlineSmall:
            const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        titleMedium:
            const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
        titleSmall: const TextStyle(fontSize: 14.0),
        bodyMedium: const TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.normal, height: 1.4),
      ),
);
final bonitoTheme = ThemeData.dark().copyWith(
  textTheme: bonitoTextTheme,
);
