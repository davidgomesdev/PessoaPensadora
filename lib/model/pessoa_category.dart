import 'package:pessoa_bonito/model/pessoa_text.dart';

class PessoaCategory {
  String link;
  String title;
  PessoaCategory? parentCategory;
  List<PessoaCategory> subcategories;
  List<PessoaText> texts;
  CategoryType type;

  PessoaCategory.full(this.link, {required this.title, this.parentCategory})
      : type = CategoryType.Full,
        texts = List.empty(),
        subcategories = List.empty();

  PessoaCategory.preview(this.link,
      {required this.title, required this.parentCategory})
      : type = CategoryType.Preview,
        subcategories = [],
        texts = [];

  PessoaCategory.index(this.link)
      : title = "Índice",
        type = CategoryType.Index,
        texts = [],
        subcategories = List.empty();

  void setSubcategories(List<PessoaCategory> subcategories) =>
      this.subcategories = subcategories;

  void setTexts(List<PessoaText> texts) => this.texts = texts;
}

enum CategoryType { Index, Preview, Full }
