import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/ui/routes.dart';
import 'package:pessoa_bonito/ui/screen/home_screen.dart';
import 'package:pessoa_bonito/ui/screen/saved_text_reader_screen.dart';
import 'package:pessoa_bonito/ui/screen/saved_texts_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        theme: bonitoTheme,
        initialRoute: Routes.homeScreen,
        getPages: [
          GetPage(name: Routes.homeScreen, page: () => const HomeScreen()),
          GetPage(
              name: Routes.savedScreen, page: () => const SavedTextsScreen()),
          GetPage(
              name: Routes.readSavedScreen,
              page: () => const SavedTextReaderScreen())
        ]);
  }
}
