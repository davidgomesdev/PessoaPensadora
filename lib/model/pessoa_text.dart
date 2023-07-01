import 'package:json_annotation/json_annotation.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';

part 'pessoa_text.g.dart';

@JsonSerializable()
class PessoaText {
  PessoaCategory? category;
  @JsonKey(defaultValue: 0)
  final int id;
  final String title;
  final String content;
  final String author;

  PessoaText(this.id, this.title, this.author, this.content);

  factory PessoaText.fromJson(Map<String, dynamic> json) =>
      _$PessoaTextFromJson(json);

  Map<String, dynamic> toJson() => _$PessoaTextToJson(this);
}
