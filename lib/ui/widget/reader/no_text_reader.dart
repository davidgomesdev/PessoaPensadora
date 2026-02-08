import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            child: Column(
              children: [
                Text(
                    'main_menu_subtitle'.tr
                ),
                SizedBox(
                  height: 8,
                ),
                Text('main_menu_subtitle_note'.tr)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
