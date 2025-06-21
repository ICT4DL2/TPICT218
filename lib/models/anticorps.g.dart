// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anticorps.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnticorpsAdapter extends TypeAdapter<Anticorps> {
  @override
  final int typeId = 8;

  @override
  Anticorps read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anticorps(
      nom: fields[1] as String,
      pv: fields[2] as int,
      typeAttaque: fields[4] as String,
      degats: fields[5] as int,
      armure: fields[3] as double,
      initiative: fields[6] as int,
      coutRessources: fields[10] as int,
      tempsProduction: fields[11] as int,
    )
      ..specialization = fields[12] as String?
      ..memory = (fields[13] as List).cast<String>()
      ..id = fields[0] as String
      ..customType = fields[88] as String?
      ..level = fields[8] as int
      ..mutationLevel = fields[9] as int;
  }

  @override
  void write(BinaryWriter writer, Anticorps obj) {
    writer
      ..writeByte(14)
      ..writeByte(10)
      ..write(obj.coutRessources)
      ..writeByte(11)
      ..write(obj.tempsProduction)
      ..writeByte(12)
      ..write(obj.specialization)
      ..writeByte(13)
      ..write(obj.memory.toList())
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
      other is AnticorpsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
