import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:pessoa_pensadora/dto/box/box_person_category.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

import '../dto/box/box_person_text.dart';

const indexID = 0;

class TextStoreService {
  final Map<int, BoxPessoaText> texts;
  final Map<int, BoxPessoaCategory> categories;
  final PessoaCategory index;

  TextStoreService._(this.index,
      {required this.texts, required this.categories});

  static Future<TextStoreService> initialize(AssetBundle assetBundle) async {
    final categories = <int, BoxPessoaCategory>{};
    final texts = <int, BoxPessoaText>{};

    String data = await assetBundle.loadString("assets/json_files/all_texts.json");
    Iterable json = jsonDecode(data);

    final parsedCategories = List<PessoaCategory>.from(
        json.map((it) => PessoaCategory.fromJson(it)));

    final index = PessoaCategory.index(parsedCategories);

    for (var it in parsedCategories) {
      it.parentCategory = index;

      _fillCategory(texts, categories, index, it);
    }

    final service = TextStoreService._(
      index,
      texts: texts,
      categories: categories,
    );

    log.i('Index initialized successfully.');

    return service;
  }

  BoxPessoaCategory getCategory(int id) {
    final category = categories[id];

    assert(category != null, "The category shouldn't be null");

    return category!;
  }

  BoxPessoaCategory getTextRootCategory(int textId) {
    final text = texts[textId];

    assert(text != null, "The text shouldn't be null");

    return text!.rootCategory;
  }
}

PessoaCategory _fillCategory(
    Map<int, BoxPessoaText> texts,
    Map<int, BoxPessoaCategory> categories,
    PessoaCategory parent,
    PessoaCategory current) {
  if (!categories.containsKey(current.id)) {
    categories[current.id] = BoxPessoaCategory.from(current, parent.id);
  }

  _fillTexts(texts, current);

  for (var element in current.subcategories) {
    _fillCategory(texts, categories, current, element);
  }

  return current..parentCategory = parent;
}

void _fillTexts(Map<int, BoxPessoaText> texts, PessoaCategory category) {
  for (var text in category.texts) {
    if (!texts.containsKey(text.id)) {
      texts[text.id] = BoxPessoaText.from(text, category.id);
    }

    text.category = category;
  }

  _sortByTitleAlphabetically(category);
}

void _sortByTitleAlphabetically(PessoaCategory category) {
  category.texts.sort((prev, next) => prev.title.compareTo(next.title));
}
