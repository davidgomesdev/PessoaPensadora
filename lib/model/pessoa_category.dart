import 'package:json_annotation/json_annotation.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';

part 'pessoa_category.g.dart';

@JsonSerializable()
class PessoaCategory {
  int id;
  String title;
  PessoaCategory? parentCategory;
  List<PessoaCategory> subcategories;
  List<PessoaText> texts;

  @JsonKey(defaultValue: false)
  bool isIndex;

  PessoaCategory(this.id, String title, this.parentCategory, this.subcategories,
      this.texts)
      : isIndex = false,
        title = title.replaceAll(RegExp('(\\d+\\.)+ '), '');

  PessoaCategory.index(this.subcategories)
      : title = "Índice",
        isIndex = true,
        texts = [],
        id = 0;

  factory PessoaCategory.fromJson(Map<String, dynamic> json) =>
      _$PessoaCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$PessoaCategoryToJson(this);
}
