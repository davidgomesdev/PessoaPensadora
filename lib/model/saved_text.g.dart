// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_text.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedTextAdapter extends TypeAdapter<SavedText> {
  @override
  final int typeId = 1;

  @override
  SavedText read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedText(
      fields[10] as int,
      fields[20] as SavedCategory,
      fields[30] as String,
      fields[50] as String,
      fields[40] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedText obj) {
    writer
      ..writeByte(5)
      ..writeByte(10)
      ..write(obj.id)
      ..writeByte(20)
      ..write(obj.category)
      ..writeByte(30)
      ..write(obj.title)
      ..writeByte(40)
      ..write(obj.content)
      ..writeByte(50)
      ..write(obj.author);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedTextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavedCategoryAdapter extends TypeAdapter<SavedCategory> {
  @override
  final int typeId = 2;

  @override
  SavedCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedCategory(
      fields[10] as int,
      fields[20] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedCategory obj) {
    writer
      ..writeByte(2)
      ..writeByte(10)
      ..write(obj.id)
      ..writeByte(20)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
