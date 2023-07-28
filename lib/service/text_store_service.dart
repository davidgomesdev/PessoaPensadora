import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:pessoa_bonito/dto/box/box_person_category.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

import '../dto/box/box_person_text.dart';

class TextStoreService {
  final Map<int, BoxPessoaText> texts;
  final Map<int, BoxPessoaCategory> categories;
  final PessoaCategory index;

  TextStoreService._(this.index,
      {required this.texts, required this.categories});

  static Future<TextStoreService> initialize(AssetBundle assetBundle) async {
    final categories = <int, BoxPessoaCategory>{};
    final texts = <int, BoxPessoaText>{};
    final index = await _parseIndex(texts, categories, assetBundle);

    final service = TextStoreService._(
      index,
      texts: texts,
      categories: categories,
    );

    log.i('Index initialized successfully.');

    return service;
  }

  static Future<PessoaCategory> _parseIndex(Map<int, BoxPessoaText> texts,
      Map<int, BoxPessoaCategory> categories, AssetBundle assetBundle) async {
    return await _parseJson(assetBundle, texts, categories);
  }

  static Future<PessoaCategory> _parseJson(
    AssetBundle assetBundle,
    Map<int, BoxPessoaText> texts,
    Map<int, BoxPessoaCategory> categories,
  ) async {
    String data = await assetBundle.loadString("assets/json_files/texts.json");
    Iterable json = jsonDecode(data);

    final parsedCategories = List<PessoaCategory>.from(
        json.map((it) => PessoaCategory.fromJson(it)));

    final index = PessoaCategory.index(parsedCategories);

    for (var it in parsedCategories) {
      it.parentCategory = index;

      _fillCategory(texts, categories, index, it);
    }

    return index;
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

  category.texts.sort((prev, next) => prev.id.compareTo(next.id));
}
