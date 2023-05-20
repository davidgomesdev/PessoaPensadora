import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pessoa_bonito/service/action_service.dart';
import 'package:pessoa_bonito/service/arquivo_pessoa_service.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/ui/screen/reader_screen.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

import 'model/pessoa_text.dart';

const _savedTextsBoxName = 'savedTexts';

Future<void> main() async {
  EquatableConfig.stringify = true;

  await initializeDependencies();

  runApp(const HomeScreen());
}

Future<void> initializeDependencies() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PessoaTextAdapter());
  Box<PessoaText> box = await getSavedTextsBox();

  log.i('Saved texts box initialized successfully');

  Get.put(ArquivoPessoaService());
  Get.put(ActionService(box));
}

Future<Box<PessoaText>> getSavedTextsBox() async {
  try {
    return await Hive.openBox(_savedTextsBoxName);
  } catch (ex) {
    log.w('Error opening saved texts box, re-creating it', ex);
    await Hive.deleteBoxFromDisk(_savedTextsBoxName);
    return await Hive.openBox(_savedTextsBoxName);
  }
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
