import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/service/action_service.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/ui/screen/reader_screen.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

import 'model/pessoa_text.dart';

const _savedTextsBoxName = 'savedTexts';

Future<void> main() async {
  EquatableConfig.stringify = true;

  await Hive.initFlutter();

  Hive.registerAdapter(PessoaTextAdapter());

  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: bonitoTheme,
      home: FutureBuilder<PessoaCategory>(
          future: initializeDependencies(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) return ReaderScreen(snapshot.data!);
            if (snapshot.hasError) snapshot.printError();

            return const CircularProgressIndicator();
          }),
    );
  }

  Future<PessoaCategory> initializeDependencies(BuildContext context) async {
    Box<PessoaText> box = await getSavedTextsBox();

    log.i('Saved texts box initialized successfully');

    Get.put(ActionService(box));
    return await parseTexts(context);
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

  Future<PessoaCategory> parseTexts(BuildContext context) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/json_files/texts.json");
    Iterable json = jsonDecode(data);

    final categories = List<PessoaCategory>.from(
        json.map((it) => PessoaCategory.fromJson(it)));

    final index = PessoaCategory.index();

    index.subcategories = categories;

    for (var it in categories) {
      it.parentCategory = index;

      fillCategory(index, it);
    }

    return index;
  }

  PessoaCategory fillCategory(PessoaCategory parent, PessoaCategory current) {
    fillTexts(current);

    for (var element in current.subcategories) {
      fillCategory(current, element);
    }

    return current..parentCategory = parent;
  }

  void fillTexts(PessoaCategory category) {
    for (var text in category.texts) {
      text.category = category;
    }

    category.texts.sort((prev, next) => prev.id.compareTo(next.id));
  }
}
