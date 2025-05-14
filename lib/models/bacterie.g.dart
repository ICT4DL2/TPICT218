// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bacterie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BacterieAdapter extends TypeAdapter<Bacterie> {
  @override
  final int typeId = 2;

  @override
  Bacterie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bacterie(
      pv: fields[1] as int,
      armure: fields[2] as double,
      degats: fields[4] as int,
      initiative: fields[5] as int,
    )..customType = fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, Bacterie obj) {
    writer
      ..writeByte(7)
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
      other is BacterieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
