class PessoaCategory {
  final String title;
  final List<PessoaText> texts;
  final List<PessoaCategory>? subcategories;

  PessoaCategory(
      {required this.title, required this.texts, this.subcategories});
}

class PessoaIndex extends PessoaCategory {
  PessoaIndex({required List<PessoaCategory> categories})
      : super(title: "Índice", texts: [], subcategories: categories);
}

class PessoaText {
  final String title;
  final String content;

  PessoaText(this.title, this.content);
}
