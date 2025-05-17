// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anticorps.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnticorpsAdapter extends TypeAdapter<Anticorps> {
  @override
  final int typeId = 1;

  @override
  Anticorps read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anticorps(
      nom: fields[1] as String,
      pv: fields[2] as int,
      typeAttaque: fields[3] as String,
      degats: fields[4] as int,
      coutRessources: fields[5] as int,
      tempsProduction: fields[6] as int,
    )
      ..id = fields[0] as String
      ..level = fields[7] as int
      ..specialization = fields[8] as String?
      ..memory = (fields[9] as List).cast<String>().toSet();
  }

  @override
  void write(BinaryWriter writer, Anticorps obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.pv)
      ..writeByte(3)
      ..write(obj.typeAttaque)
      ..writeByte(4)
      ..write(obj.degats)
      ..writeByte(5)
      ..write(obj.coutRessources)
      ..writeByte(6)
      ..write(obj.tempsProduction)
      ..writeByte(7)
      ..write(obj.level)
      ..writeByte(8)
      ..write(obj.specialization)
      ..writeByte(9)
      ..write(obj.memory.toList());
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
