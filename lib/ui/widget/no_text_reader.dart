import 'package:flutter/material.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class NoTextReader extends StatelessWidget {
  const NoTextReader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "Pessoa Pensadora",
              style: bonitoTextTheme.displayMedium,
            ),
            Text(
                "Textos de Fernando Pessoa, provenientes de Arquivo Pessoa (sem qualquer afiliação)",
                style: bonitoTextTheme.labelSmall!
                    .copyWith(fontStyle: FontStyle.italic)),
          ],
        )
      ],
    ));
  }
}
