import 'package:flutter/material.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class NoTextReader extends StatelessWidget {
  const NoTextReader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      "Pessoa Pensadora",
      style: bonitoTextTheme.displayMedium,
    ));
  }
}
