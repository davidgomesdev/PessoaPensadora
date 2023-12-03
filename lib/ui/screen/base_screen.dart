import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/ui/routes.dart';
import 'package:pessoa_bonito/ui/screen/history_screen.dart';
import 'package:pessoa_bonito/ui/screen/home_screen.dart';
import 'package:pessoa_bonito/ui/screen/saved_text_reader_screen.dart';
import 'package:pessoa_bonito/ui/screen/saved_texts_screen.dart';

import 'boot_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        theme: bonitoTheme,
        initialRoute: Routes.bootScreen,
        getPages: buildAppPages());
  }

  List<GetPage<dynamic>> buildAppPages() {
    return [
      GetPage(name: Routes.bootScreen, page: () => const BootScreen()),
      GetPage(name: Routes.homeScreen, page: () => const HomeScreen()),
      GetPage(name: Routes.savedScreen, page: () => const SavedTextsScreen()),
      GetPage(
        name: Routes.readTextScreen,
        page: () => const TextReaderScreen(),
      ),
      GetPage(
        name: Routes.historyScreen,
        page: () => const HistoryScreen(),
      )
    ];
  }
}
