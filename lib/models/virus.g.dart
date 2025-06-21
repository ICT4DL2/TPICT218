// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'virus.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VirusAdapter extends TypeAdapter<Virus> {
  @override
  final int typeId = 5;

  @override
  Virus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Virus(
      pv: fields[2] as int,
      armure: fields[3] as double,
      degats: fields[5] as int,
      initiative: fields[6] as int,
    )
      ..id = fields[0] as String
      ..typeAttaque = fields[4] as String
      ..customType = fields[88] as String?
      ..level = fields[8] as int
      ..mutationLevel = fields[9] as int;
  }

  @override
  void write(BinaryWriter writer, Virus obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.pv)
      ..writeByte(3)
      ..write(obj.armure)
      ..writeByte(4)
      ..write(obj.typeAttaque)
      ..writeByte(5)
      ..write(obj.degats)
      ..writeByte(6)
      ..write(obj.initiative)
      ..writeByte(88)
      ..write(obj.customType)
      ..writeByte(8)
      ..write(obj.level)
      ..writeByte(9)
      ..write(obj.mutationLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VirusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
