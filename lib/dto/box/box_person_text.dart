import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pessoa_bonito/dto/box/box_person_category.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';

import '../../service/text_store_service.dart';

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

  PessoaText toModel(
    Map<int, BoxPessoaCategory> categories,
    Map<int, BoxPessoaText> texts,
  ) {
    final category = categories[categoryId]!.toModel(categories, texts);

    return PessoaText(id, title, author, content)..category = category;
  }

  BoxPessoaCategory get category =>
      Get.find<TextStoreService>().categories[categoryId]!;
}
