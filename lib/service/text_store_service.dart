import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';

class TextStoreService {
  PessoaCategory index;

  TextStoreService._(this.index);

  static Future<TextStoreService> initialize(AssetBundle assetBundle) async {
    return TextStoreService._(await parseTexts(assetBundle));
  }

  static Future<PessoaCategory> parseTexts(AssetBundle assetBundle) async {
    String data = await assetBundle.loadString("assets/json_files/texts.json");
    Iterable json = jsonDecode(data);

    final categories = List<PessoaCategory>.from(
        json.map((it) => PessoaCategory.fromJson(it)));

    final index = PessoaCategory.index();

    index.subcategories = categories;

    for (var it in categories) {
      it.parentCategory = index;

      _fillCategory(index, it);
    }

    return index;
  }
}

PessoaCategory _fillCategory(PessoaCategory parent, PessoaCategory current) {
  _fillTexts(current);

  for (var element in current.subcategories) {
    _fillCategory(current, element);
  }

  return current..parentCategory = parent;
}

void _fillTexts(PessoaCategory category) {
  for (var text in category.texts) {
    text.category = category;
  }

  category.texts.sort((prev, next) => prev.id.compareTo(next.id));
}
