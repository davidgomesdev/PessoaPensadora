// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pessoa_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PessoaText _$PessoaTextFromJson(Map<String, dynamic> json) => PessoaText(
      json['id'] as int? ?? 0,
      json['title'] as String,
      json['author'] as String,
      json['content'] as String,
    )..category = json['category'] == null
        ? null
        : PessoaCategory.fromJson(json['category'] as Map<String, dynamic>);

Map<String, dynamic> _$PessoaTextToJson(PessoaText instance) =>
    <String, dynamic>{
      'category': instance.category,
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'author': instance.author,
    };
