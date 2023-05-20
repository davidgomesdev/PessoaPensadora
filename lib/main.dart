import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pessoa_bonito/service/action_service.dart';
import 'package:pessoa_bonito/service/arquivo_pessoa_service.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/ui/screen/reader_screen.dart';

import 'model/pessoa_text.dart';

Future<void> main() async {
  EquatableConfig.stringify = true;

  await initializeDependencies();

  runApp(const HomeScreen());
}

Future<void> initializeDependencies() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PessoaTextAdapter());
  Box<PessoaText> box = await Hive.openBox('savedTexts');

  Get.put(ArquivoPessoaService());
  Get.put(ActionService(box));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: bonitoTheme,
      home: ReaderScreen(),
    );
  }
}
