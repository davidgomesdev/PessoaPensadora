import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/repository/reader_preference_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class NoTextReader extends StatelessWidget {

  const NoTextReader({super.key});

  @override
  Widget build(BuildContext context) {
    final ReaderPreferenceStore readerPreferenceStore = Get.find();
    final locale = readerPreferenceStore.currentLanguage;

    return Stack(
      children: [
        Positioned(
          bottom: 16,
          right: 16,
          child: IconButton(
            icon: Flag.fromCode(
              locale.next().flagCode,
              flagSize: FlagSize.size_1x1,
              width: 16,
              height: 16,
            ),
            tooltip: 'change_language'.tr,
            onPressed: () async {
              await Get.find<ReaderPreferenceStore>().changeLanguage();
            },
          ),
        ),
        Center(
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
                    Text('main_menu_subtitle'.tr),
                    SizedBox(
                      height: 8,
                    ),
                    Text('main_menu_subtitle_note'.tr)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
