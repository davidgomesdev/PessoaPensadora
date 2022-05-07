import 'package:pessoa_bonito/model/pessoa_text.dart';

class PessoaCategory {
  String link;
  String title;
  PessoaCategory? parentCategory;
  List<PessoaCategory> subcategories;
  List<PessoaText> texts;
  bool isPreview;

  PessoaCategory.full(this.link, {required this.title, this.parentCategory})
      : isPreview = false,
        texts = List.empty(),
        subcategories = List.empty();

  PessoaCategory.preview(this.link,
      {required this.title, required this.parentCategory})
      : isPreview = true,
        subcategories = [],
        texts = [];

  PessoaCategory.index(this.link)
      : title = "Índice",
        isPreview = false,
        texts = [],
        subcategories = List.empty();

  void setSubcategories(List<PessoaCategory> subcategories) =>
      this.subcategories = subcategories;

  void setTexts(List<PessoaText> texts) => this.texts = texts;
}
