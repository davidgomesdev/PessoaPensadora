import 'package:json_annotation/json_annotation.dart';
import 'package:pessoa_pensadora/model/pessoa_text.dart';

import '../service/text_store.dart';

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

  @JsonKey(includeFromJson: false)
  bool isFullIndex;

  PessoaCategory(this.id, String title, this.parentCategory, this.subcategories,
      this.texts,
      {this.isIndex = false})
      : title = title.replaceAll(RegExp('(\\d+\\.)+ '), ''),
        isFullIndex = false;

  PessoaCategory.fullIndex(this.subcategories)
      : title = "Índice",
        isIndex = true,
        isFullIndex = true,
        texts = [],
        id = indexID;

  PessoaCategory.mainIndex(PessoaCategory fullIndex, this.subcategories)
      : title = "Índice",
        isIndex = true,
        isFullIndex = false,
        texts = fullIndex.texts,
        id = indexID;

  factory PessoaCategory.fromJson(Map<String, dynamic> json) =>
      _$PessoaCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$PessoaCategoryToJson(this);
}
