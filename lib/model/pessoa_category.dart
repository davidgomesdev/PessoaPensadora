import 'package:json_annotation/json_annotation.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';

part 'pessoa_category.g.dart';

@JsonSerializable()
class PessoaCategory {
  @JsonKey(defaultValue: "")
  String link;
  String title;
  PessoaCategory? parentCategory;
  List<PessoaCategory> subcategories;
  List<PessoaText> texts;
  @JsonKey(defaultValue: false)
  bool isIndex;

  @Deprecated("Only for the Json Serializer.")
  PessoaCategory({required this.title, this.parentCategory})
      : isIndex = false,
        texts = List.empty(),
        subcategories = List.empty(),
        link = "";

  PessoaCategory.index()
      : title = "Índice",
        isIndex = true,
        texts = [],
        link = "",
        subcategories = List.empty();

  factory PessoaCategory.fromJson(Map<String, dynamic> json) =>
      _$PessoaCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$PessoaCategoryToJson(this);
}
