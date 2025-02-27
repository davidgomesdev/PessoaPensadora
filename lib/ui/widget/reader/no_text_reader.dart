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
          Text(
            "Pessoa Pensadora",
            style: bonitoTextTheme.displayMedium,
          ),
          const SizedBox(
            height: 32,
          ),
          DefaultTextStyle(
            style: bonitoTextTheme.labelSmall!
                .copyWith(fontStyle: FontStyle.italic),
            child: const Column(
              children: [
                Text(
                    "Textos de Fernando Pessoa, provenientes de Arquivo Pessoa"),
                SizedBox(
                  height: 8,
                ),
                Text("(sem qualquer afiliação)")
              ],
            ),
          ),
        ],
      ),
    );
  }
}
