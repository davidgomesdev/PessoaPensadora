import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
import 'package:pessoa_pensadora/ui/screen/history_screen.dart';
import 'package:pessoa_pensadora/ui/screen/home_screen.dart';
import 'package:pessoa_pensadora/ui/screen/saved_text_reader_screen.dart';
import 'package:pessoa_pensadora/ui/screen/saved_texts_screen.dart';
import 'package:pessoa_pensadora/ui/screen/splash_screen.dart';

import 'boot_screen.dart';

var startedAt = DateTime.timestamp();
DateTime? finishedAt;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: bonitoTheme,
      initialRoute: Routes.bootScreen,
      getPages: buildAppPages(),
    );
  }

  List<GetPage<dynamic>> buildAppPages() {
    return [
      GetPage(name: Routes.bootScreen, page: () => const BootScreen()),
      buildPage(Routes.homeScreen, const HomeScreen()),
      buildPage(Routes.savedScreen, const SavedTextsScreen()),
      buildPage(Routes.readTextScreen, const TextReaderScreen()),
      buildPage(Routes.historyScreen, const HistoryScreen()),
    ];
  }

  GetPage buildPage(String route, Widget screen) {
    return GetPage(
        name: route,
        page: () {
          if (finishedAt == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offNamed(Routes.bootScreen);
            });
            return SplashScreen();
          }
          return screen;
        });
  }
}
