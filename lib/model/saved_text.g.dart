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
    );
  }

  @override
  void write(BinaryWriter writer, SavedText obj) {
    writer
      ..writeByte(1)
      ..writeByte(10)
      ..write(obj.id);
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
