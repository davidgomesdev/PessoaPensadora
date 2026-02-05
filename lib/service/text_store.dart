import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:numerus/numerus.dart';
import 'package:pessoa_pensadora/dto/box/box_person_category.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

import '../dto/box/box_person_text.dart';
import '../util/string_utils.dart';

const indexID = 0;

const mainCategories = [
  26, // 1. Poemas de Alberto Caeiro
  23, // 2. Poesia de Álvaro de Campos
  25, // 3. Odes de Ricardo Reis
  27, // 4. Poesia Ortónima de Fernando Pessoa
  33, // 5. Livro do Desassossego
  24, // 6. MENSAGEM
  67, // 8. Textos Heterónimos
  139, // 17. Textos Publicados em vida
  10000, // Rubaiyat
];

class TextStoreService {
  final Map<int, BoxPessoaText> texts;
  final Map<int, BoxPessoaCategory> categories;
  late final PessoaCategory mainIndex, fullIndex;

  TextStoreService._(this.fullIndex,
      {required this.texts, required this.categories}) {
    mainIndex = PessoaCategory.mainIndex(
      fullIndex,
      fullIndex.subcategories
          .where((cat) => mainCategories.contains(cat.id))
          .toList(growable: false),
    );
  }

  static Future<TextStoreService> initialize(AssetBundle assetBundle) async {
    final categories = <int, BoxPessoaCategory>{};
    final texts = <int, BoxPessoaText>{};

    String data =
        await assetBundle.loadString("assets/json_files/all_texts.json");
    Iterable json = jsonDecode(data);

    final parsedCategories = List<PessoaCategory>.from(
        json.map((it) => PessoaCategory.fromJson(it)));

    final index = PessoaCategory.fullIndex(parsedCategories);

    for (var it in parsedCategories) {
      it.parentCategory = index;

      _fillCategory(texts, categories, index, it);
    }

    final service = TextStoreService._(
      index,
      texts: texts,
      categories: categories,
    );

    log.d('Index initialized successfully.');

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

  if (category.texts.every(
      (text) => substringBefore(text.title, '.').isValidRomanNumeralValue())) {
    category.texts.sort((prev, next) {
      // Should never be null, but just in case, we consider it/**/ as 0
      return (substringBefore(prev.title, '.').toRomanNumeralValue() ?? 0)
          .compareTo(
              substringBefore(next.title, '.').toRomanNumeralValue() ?? 0);
    });

    return;
  }

  // Special case for "O GUARDADOR DE REBANHOS",
  // which is the only one that has a mix of roman numeral and
  // non-roman numeral titles. In this case,
  // we want to sort the roman numeral titles first,
  // followed by the non-roman numeral titles, both sorted alphabetically.
  if (category.id == 2) {
    final romanNumeralTitledTexts = category.texts.where((text) =>
        substringBefore(text.title, " - ").isValidRomanNumeralValue());
    final nonRomanNumeralTitledTexts =
        category.texts.where((text) => !romanNumeralTitledTexts.contains(text));

    final sortedRomanNumeralTitledTexts = romanNumeralTitledTexts.toList()
      ..sort((prev, next) {
        return (substringBefore(prev.title, " - ").toRomanNumeralValue() ?? 0)
            .compareTo(
                substringBefore(next.title, " - ").toRomanNumeralValue() ?? 0);
      });
    final sortedNonRomanNumeralTitledTexts = nonRomanNumeralTitledTexts.toList()
      ..sort((prev, next) => prev.title.compareTo(next.title));

    category.texts
      ..clear()
      ..addAll(sortedRomanNumeralTitledTexts)
      ..addAll(sortedNonRomanNumeralTitledTexts);

    return;
  }

  _sortByTitleAlphabetically(category);
}

void _sortByTitleAlphabetically(PessoaCategory category) {
  category.texts.sort((prev, next) => prev.title.compareTo(next.title));
}
