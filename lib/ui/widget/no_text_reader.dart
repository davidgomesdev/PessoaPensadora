import 'package:flutter/material.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class NoTextReader extends StatelessWidget {
  const NoTextReader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        Column(
          children: [
            Text(
              "Pessoa Pensadora",
              style: bonitoTextTheme.displayMedium,
            ),
            Text(
                "Textos provenientes de Arquivo Pessoa (sem qualquer afiliação)",
                style: bonitoTextTheme.labelSmall!
                    .copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
        Text(
            "Nota: atualmente apenas inclui parte dos textos. No futuro haverá uma opção para poder ler a sua obra na íntegra.",
            style: bonitoTextTheme.labelSmall!
                .copyWith(fontStyle: FontStyle.italic))
      ],
    ));
  }
}
