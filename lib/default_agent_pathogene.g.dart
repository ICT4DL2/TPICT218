// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_agent_pathogene.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DefaultAgentPathogeneAdapter extends TypeAdapter<DefaultAgentPathogene> {
  @override
  final int typeId = 11;

  @override
  DefaultAgentPathogene read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DefaultAgentPathogene(
      nom: fields[1] as String,
      agentType: fields[11] as String,
      level: fields[12] as int,
      pv: fields[2] as int,
      armure: fields[3] as double,
      degats: fields[5] as int,
      initiative: fields[6] as int,
    )
      ..id = fields[0] as String
      ..typeAttaque = fields[4] as String
      ..customType = fields[88] as String?
      ..mutationLevel = fields[9] as int;
  }

  @override
  void write(BinaryWriter writer, DefaultAgentPathogene obj) {
    writer
      ..writeByte(11)
      ..writeByte(11)
      ..write(obj.agentType)
      ..writeByte(12)
      ..write(obj.level)
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
      ..writeByte(9)
      ..write(obj.mutationLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefaultAgentPathogeneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
