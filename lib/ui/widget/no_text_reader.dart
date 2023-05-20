import 'package:flutter/material.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';

class NoTextReader extends StatelessWidget {
  const NoTextReader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      "Arquivo Pessoa (Bonito)",
      style: bonitoTextTheme.displayMedium,
    ));
  }
}
