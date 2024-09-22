import 'dart:collection';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pessoa_pensadora/dto/box/box_person_category.dart';
import 'package:pessoa_pensadora/model/pessoa_text.dart';

import '../../service/text_store.dart';

part 'box_person_text.g.dart';

@HiveType(typeId: 10)
class BoxPessoaText {
  @HiveField(10)
  final int id;
  @HiveField(20)
  final int categoryId;
  @HiveField(30)
  final String title;
  @HiveField(40)
  String content;
  @HiveField(50)
  final String author;

  BoxPessoaText(
    this.id,
    this.categoryId,
    this.title,
    this.content,
    this.author,
  );

  factory BoxPessoaText.from(PessoaText text, int categoryId) => BoxPessoaText(
        text.id,
        categoryId,
        text.title,
        text.content,
        text.author,
      );

  Queue<BoxPessoaCategory> get categoryTree {
    final categories = Get.find<TextStoreService>().categories;
    final currentCategory = categories[categoryId]!;
    final tree = Queue.of([currentCategory]);
    int parentCategoryId = currentCategory.parentCategoryId;

    while (parentCategoryId != indexID) {
      final parentCategory = categories[parentCategoryId]!;

      tree.addFirst(parentCategory);
      parentCategoryId = parentCategory.parentCategoryId;
    }

    return tree;
  }

  BoxPessoaCategory get rootCategory => categoryTree.first;

  BoxPessoaCategory get category =>
      Get.find<TextStoreService>().categories[categoryId]!;
}
