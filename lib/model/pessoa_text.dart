import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/util/text_utils.dart';

part 'pessoa_text.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class PessoaText {
  /// Nullable only when persisted. In other cases, should never be null.
  PessoaCategory? category;
  @HiveField(1)
  @JsonKey(defaultValue: 0)
  final int id;
  @HiveField(2)
  final String title;
  @HiveField(3)
  String content;
  @HiveField(4)
  final String author;

  PessoaText(this.id, this.title, this.author, this.content) : category = null;

  void format() {
    content = content.removeTitle();
  }

  factory PessoaText.fromJson(Map<String, dynamic> json) =>
      _$PessoaTextFromJson(json);

  Map<String, dynamic> toJson() => _$PessoaTextToJson(this);
}
