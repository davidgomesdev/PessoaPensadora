import 'package:pessoa_bonito/model/pessoa_category.dart';

class PessoaText {
  final PessoaCategory category;
  final String link;
  final int id;

  final String title;
  final String? content;
  final String? author;

  PessoaText.preview(this.link, this.category, this.id, {required this.title})
      : content = null,
        author = null;

  PessoaText.full(this.link, this.category, this.id,
      {required this.title, required this.content, required String author})
      : author = author.trim();
}
