import 'package:pessoa_bonito/model/pessoa_text.dart';

class PessoaCategory {
  String link;
  String title;
  PessoaCategory? previousCategory;
  late List<PessoaCategory> subcategories;
  late List<PessoaText> texts;
  bool isPreview;

  PessoaCategory(this.link,
      {required this.title,
      this.previousCategory,
      required List<PessoaTextBuilder> textBuilders,
      required this.subcategories,
      required this.isPreview}) {
    this.texts = textBuilders.map((builder) => builder.build(this)).toList();
  }

  PessoaCategory.full(this.link,
      {required this.title,
      this.previousCategory,
      required List<PessoaTextBuilder> textBuilders,
      required List<PessoaCategoryBuilder> subcategoryBuilders})
      : isPreview = false {
    this.texts = textBuilders.map((builder) => builder.build(this)).toList();
    this.subcategories =
        subcategoryBuilders.map((builder) => builder.build(this)).toList();
  }

  PessoaCategory.preview(this.link, {required this.title})
      : isPreview = true,
        subcategories = [],
        texts = [];

  PessoaCategory.index(this.link, {required this.subcategories})
      : title = "Índice",
        isPreview = false,
        texts = [];
}

// Used for subcategories to have circular dependency with their parent category
class PessoaCategoryBuilder {
  String link;
  String title;
  late PessoaCategory previousCategory;
  List<PessoaCategory> subcategories;
  late List<PessoaTextBuilder> textBuilders;
  bool isPreview;

  PessoaCategoryBuilder(this.link, this.title, this.previousCategory,
      List<PessoaTextBuilder> textBuilders, this.subcategories, this.isPreview);

  PessoaCategoryBuilder.preview(this.link, {required this.title})
      : isPreview = true,
        subcategories = [],
        textBuilders = [];

  PessoaCategory build(PessoaCategory previousCategory) {
    return PessoaCategory(link,
        title: title,
        previousCategory: previousCategory,
        textBuilders: textBuilders,
        subcategories: subcategories,
        isPreview: true);
  }
}
