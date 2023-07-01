import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/model/saved_text.dart';
import 'package:pessoa_bonito/service/action_service.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

const _savedTextsBoxName = 'savedTexts';

class BootService {
  Future initializeDependencies(BuildContext context) async {
    Box<SavedText> box = await getSavedTextsBox();

    log.i('Saved texts box initialized successfully');

    Get.put(ActionService(box));

    Get.put(await parseTexts(context));
    return Future.value();
  }

  Future<Box<SavedText>> getSavedTextsBox() async {
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
