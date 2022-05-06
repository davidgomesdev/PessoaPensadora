import 'package:pessoa_bonito/model/pessoa_text.dart';

class PessoaCategory {
  String link;
  String title;
  PessoaCategory? previousCategory;
  late Iterable<PessoaCategory> subcategories;
  late Iterable<PessoaText> texts;
  bool isPreview;

  PessoaCategory(this.link,
      {required this.title,
      this.previousCategory,
      required Iterable<PessoaTextBuilder> textBuilders,
      required this.subcategories,
      required this.isPreview}) {
    this.texts = textBuilders.map((builder) => builder.build(this));
  }

  PessoaCategory.full(this.link,
      {required this.title,
      this.previousCategory,
      required Iterable<PessoaTextBuilder> textBuilders,
      required Iterable<PessoaCategoryBuilder> subcategoryBuilders})
      : isPreview = false {
    this.texts = textBuilders.map((builder) => builder.build(this));
    this.subcategories =
        subcategoryBuilders.map((builder) => builder.build(this));
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
  Iterable<PessoaCategory> subcategories;
  late Iterable<PessoaTextBuilder> textBuilders;
  bool isPreview;

  PessoaCategoryBuilder(
      this.link,
      this.title,
      this.previousCategory,
      Iterable<PessoaTextBuilder> textBuilders,
      this.subcategories,
      this.isPreview);

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
