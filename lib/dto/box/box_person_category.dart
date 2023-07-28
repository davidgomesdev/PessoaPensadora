import 'package:hive/hive.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';

import 'box_person_text.dart';

part 'box_person_category.g.dart';

@HiveType(typeId: 11)
class BoxPessoaCategory {
  @HiveField(10)
  final int id;
  @HiveField(20)
  final String title;
  @HiveField(30)
  final int parentCategoryId;
  @HiveField(40)
  final List<int> subcategoryIds;

  BoxPessoaCategory(
    this.id,
    this.title,
    this.parentCategoryId,
    this.subcategoryIds,
  );

  factory BoxPessoaCategory.from(PessoaCategory category, int parentId) =>
      BoxPessoaCategory(
        category.id,
        category.title,
        parentId,
        category.subcategories.map((e) => e.id).toList(),
      );

  PessoaCategory toModel(
    Map<int, BoxPessoaCategory> categories,
    Map<int, BoxPessoaText> texts,
  ) {
    final parentCategory =
        categories[parentCategoryId]?.toModel(categories, texts);
    final subcategories = subcategoryIds
        .map((subCategoryId) =>
            categories[subCategoryId]!.toModel(categories, texts))
        .toList(growable: false);
    final currentTexts = texts.values
        .where((text) => text.categoryId == id)
        .map((text) => text.toModel(categories, texts))
        .toList(growable: false);

    return PessoaCategory(
        id, title, parentCategory, subcategories, currentTexts);
  }
}
