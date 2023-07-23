import 'package:hive/hive.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';

part 'bookmarked_text.g.dart';

@HiveType(typeId: 1)
class BookmarkedText {
  @HiveField(10)
  final int id;
  @HiveField(20)
  final SavedCategory category;
  @HiveField(30)
  final String title;
  @HiveField(40)
  String content;
  @HiveField(50)
  final String author;

  BookmarkedText(this.id, this.category, this.title, this.author, this.content);

  factory BookmarkedText.from(PessoaText text) => BookmarkedText(
      text.id,
      SavedCategory.from(text.category!),
      text.title,
      text.author,
      text.content);

  PessoaText toModel() {
    return PessoaText(id, title, author, content);
  }
}

@HiveType(typeId: 2)
class SavedCategory {
  @HiveField(10)
  final int id;
  @HiveField(20)
  final String title;

  SavedCategory(this.id, this.title);

  factory SavedCategory.from(PessoaCategory category) =>
      SavedCategory(category.id, category.title);
}
