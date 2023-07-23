// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_person_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoxPersonCategoryAdapter extends TypeAdapter<BoxPersonCategory> {
  @override
  final int typeId = 11;

  @override
  BoxPersonCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoxPersonCategory(
      fields[10] as int,
      fields[20] as String,
      fields[30] as int,
      (fields[40] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, BoxPersonCategory obj) {
    writer
      ..writeByte(4)
      ..writeByte(10)
      ..write(obj.id)
      ..writeByte(20)
      ..write(obj.title)
      ..writeByte(30)
      ..write(obj.parentCategory)
      ..writeByte(40)
      ..write(obj.subcategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxPersonCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
