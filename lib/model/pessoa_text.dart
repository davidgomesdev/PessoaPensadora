import 'package:hive/hive.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';

part 'pessoa_text.g.dart';

@HiveType(typeId: 1)
class PessoaText {
  /// Nullable only when persisted. In other cases, should never be null.
  final PessoaCategory? category;
  @HiveField(0)
  final String link;
  @HiveField(1)
  final int id;

  @HiveField(2)
  final String title;
  @HiveField(3)
  final String content;
  @HiveField(4)
  final String author;

  PessoaText(this.link, this.id, this.title, this.author, this.content)
      : category = null;

  PessoaText.preview(this.link, this.category, this.id, {required this.title})
      : content = "",
        author = "";

  PessoaText.full(this.link, this.category, this.id,
      {required this.title, required this.content, required String author})
      : author = author.trim();
}
