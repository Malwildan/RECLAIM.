// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relapse_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RelapseEntryAdapter extends TypeAdapter<RelapseEntry> {
  @override
  final int typeId = 2;

  @override
  RelapseEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RelapseEntry(
      id: fields[0] as String?,
      userId: fields[1] as String,
      triggerSource: fields[2] as String,
      location: fields[3] as String,
      notes: fields[4] as String,
      occurredAt: fields[5] as DateTime,
      isSynced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RelapseEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.triggerSource)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.occurredAt)
      ..writeByte(6)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelapseEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
