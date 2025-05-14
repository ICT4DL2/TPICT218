// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'champignon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChampignonAdapter extends TypeAdapter<Champignon> {
  @override
  final int typeId = 3;

  @override
  Champignon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Champignon(
      pv: fields[1] as int,
      armure: fields[2] as double,
      degats: fields[4] as int,
      initiative: fields[5] as int,
    )
      ..invisible = fields[6] as bool
      ..customType = fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, Champignon obj) {
    writer
      ..writeByte(8)
      ..writeByte(6)
      ..write(obj.invisible)
      ..writeByte(0)
      ..write(obj.nom)
      ..writeByte(1)
      ..write(obj.pv)
      ..writeByte(2)
      ..write(obj.armure)
      ..writeByte(3)
      ..write(obj.typeAttaque)
      ..writeByte(4)
      ..write(obj.degats)
      ..writeByte(5)
      ..write(obj.initiative)
      ..writeByte(8)
      ..write(obj.customType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChampignonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
