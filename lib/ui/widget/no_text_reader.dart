import 'package:flutter/material.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';

class NoTextReader extends StatelessWidget {
  const NoTextReader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      "Arquivo Pessoa (Bonito)",
      style: bonitoTextTheme.displayMedium,
    ));
  }
}
