// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pessoa_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PessoaCategory _$PessoaCategoryFromJson(Map<String, dynamic> json) =>
    PessoaCategory(
      json['id'] as int,
      json['title'] as String,
      json['parentCategory'] == null
          ? null
          : PessoaCategory.fromJson(
              json['parentCategory'] as Map<String, dynamic>),
      (json['subcategories'] as List<dynamic>)
          .map((e) => PessoaCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['texts'] as List<dynamic>)
          .map((e) => PessoaText.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..isIndex = json['isIndex'] as bool? ?? false;

Map<String, dynamic> _$PessoaCategoryToJson(PessoaCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'parentCategory': instance.parentCategory,
      'subcategories': instance.subcategories,
      'texts': instance.texts,
      'isIndex': instance.isIndex,
    };
