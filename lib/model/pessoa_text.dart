import 'package:pessoa_bonito/model/pessoa_category.dart';

class PessoaText {
  final PessoaCategory category;
  final String link;

  int get id => link._getId();
  final String title;
  final String? content;
  final String? author;

  PessoaText(this.link, this.category,
      {required this.title, this.content, String? author})
      : author = author?.trim();
}

class PessoaTextBuilder {
  final String link;
  final String title;
  final String? content;
  final String? author;

  PessoaTextBuilder(this.link,
      {required this.title, this.content, this.author});

  PessoaText build(PessoaCategory category) => PessoaText(this.link, category,
      title: title, content: content, author: author);
}

extension RegexParse on String {
  int _getId() {
    final regexResult = RegExp(r'\/.+\/(.+)').firstMatch(this);
    String? id = regexResult?.group(1);

    if (id == null) return -1;

    return int.parse(id);
  }
}
