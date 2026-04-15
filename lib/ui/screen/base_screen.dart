import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/screen/boot_screen.dart';
import 'package:pessoa_pensadora/ui/screen/category_screen.dart';
import 'package:pessoa_pensadora/ui/screen/history_screen.dart';
import 'package:pessoa_pensadora/ui/screen/home_screen.dart';
import 'package:pessoa_pensadora/ui/screen/text_reader_screen.dart';
import 'package:pessoa_pensadora/ui/screen/saved_texts_screen.dart';
import 'package:pessoa_pensadora/ui/screen/search_screen.dart';
import 'package:pessoa_pensadora/ui/screen/splash_screen.dart';
import 'package:pessoa_pensadora/ui/screen/texts_list_screen.dart';


var startedAt = DateTime.timestamp();
DateTime? finishedAt;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
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
      initialRoute: BootScreen.routeName,
      getPages: buildAppPages(),
    );
  }

  List<GetPage<dynamic>> buildAppPages() {
    return [
      GetPage(name: BootScreen.routeName, page: () => const BootScreen()),
      buildPage(HomeScreen.routeName, const HomeScreen()),
      buildPage(SavedTextsScreen.routeName, const SavedTextsScreen()),
      buildPage(TextReaderScreen.routeName, const TextReaderScreen()),
      buildPage(HistoryScreen.routeName, const HistoryScreen()),
      buildPage(SearchScreen.routeName, const SearchScreen()),
      buildPage(CategoryScreen.routeName, const CategoryScreen()),
      buildPage(TextsListScreen.routeName, const TextsListScreen()),
    ];
  }

  GetPage buildPage(String route, Widget screen) {
    return GetPage(
        name: route,
        page: () {
           if (finishedAt == null) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               Get.offNamed(BootScreen.routeName);
             });
             return SplashScreen();
           }
          return screen;
        });
  }
}
