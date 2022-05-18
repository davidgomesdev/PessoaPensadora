import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/ui/screen/reader_screen.dart';

void main() {
  EquatableConfig.stringify = true;

  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: bonitoTheme,
      home: ReaderScreen(),
    );
  }
}
