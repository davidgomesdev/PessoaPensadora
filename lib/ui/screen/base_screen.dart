import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
import 'package:pessoa_pensadora/ui/screen/category_screen.dart';
import 'package:pessoa_pensadora/ui/screen/history_screen.dart';
import 'package:pessoa_pensadora/ui/screen/home_screen.dart';
import 'package:pessoa_pensadora/ui/screen/text_reader_screen.dart';
import 'package:pessoa_pensadora/ui/screen/saved_texts_screen.dart';
import 'package:pessoa_pensadora/ui/screen/search_screen.dart';
import 'package:pessoa_pensadora/ui/screen/splash_screen.dart';
import 'package:pessoa_pensadora/ui/screen/texts_list_screen.dart';

import 'boot_screen.dart';

var startedAt = DateTime.timestamp();
DateTime? finishedAt;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }

    return GetMaterialApp(
      title: kIsWeb
          ? "Pessoa Pensadora - Toda a obra de Fernando Pessoa"
          : "Pessoa Pensadora",
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: BonitoTheme.bgPrimary,
        appBarTheme: const AppBarTheme(
          backgroundColor: BonitoTheme.bgSecondary,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: BonitoTheme.bgSecondary,
          selectedItemColor: BonitoTheme.gold,
          unselectedItemColor: BonitoTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: BonitoTheme.gold,
          surface: BonitoTheme.bgPrimary,
        ),
        textTheme: bonitoTextTheme.apply(bodyColor: BonitoTheme.textPrimary),
        dividerColor: BonitoTheme.borderMid,
      ),
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
      buildPage(Routes.searchScreen, const SearchScreen()),
      buildPage(Routes.categoryScreen, const CategoryScreen()),
      buildPage(Routes.textsListScreen, const TextsListScreen()),
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
