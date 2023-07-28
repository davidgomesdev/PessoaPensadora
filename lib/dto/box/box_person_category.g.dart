// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_person_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoxPessoaCategoryAdapter extends TypeAdapter<BoxPessoaCategory> {
  @override
  final int typeId = 11;

  @override
  BoxPessoaCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoxPessoaCategory(
      fields[10] as int,
      fields[20] as String,
      fields[30] as int,
      (fields[40] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, BoxPessoaCategory obj) {
    writer
      ..writeByte(4)
      ..writeByte(10)
      ..write(obj.id)
      ..writeByte(20)
      ..write(obj.title)
      ..writeByte(30)
      ..write(obj.parentCategoryId)
      ..writeByte(40)
      ..write(obj.subcategoryIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxPessoaCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
