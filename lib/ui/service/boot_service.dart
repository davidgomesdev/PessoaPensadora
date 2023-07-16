import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/service/bookmark_service.dart';

class BootService {
  Future initializeDependencies(BuildContext context) async {
    Get.put(await BookmarkService.initialize());
    Get.put(await parseTexts(context));

    return Future.value();
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
