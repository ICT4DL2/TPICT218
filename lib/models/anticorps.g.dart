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
      nom: fields[0] as String,
      pv: fields[1] as int,
      typeAttaque: fields[2] as String,
      degats: fields[3] as int,
      coutRessources: fields[4] as int,
      tempsProduction: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Anticorps obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nom)
      ..writeByte(1)
      ..write(obj.pv)
      ..writeByte(2)
      ..write(obj.typeAttaque)
      ..writeByte(3)
      ..write(obj.degats)
      ..writeByte(4)
      ..write(obj.coutRessources)
      ..writeByte(5)
      ..write(obj.tempsProduction);
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
