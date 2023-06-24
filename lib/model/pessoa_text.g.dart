// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pessoa_text.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PessoaTextAdapter extends TypeAdapter<PessoaText> {
  @override
  final int typeId = 1;

  @override
  PessoaText read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PessoaText(
      fields[1] as int,
      fields[2] as String,
      fields[4] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PessoaText obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.author);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PessoaTextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
