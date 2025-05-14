// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_virale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BaseViraleAdapter extends TypeAdapter<BaseVirale> {
  @override
  final int typeId = 4;

  @override
  BaseVirale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BaseVirale(
      nom: fields[0] as String,
      agents: (fields[1] as List?)?.cast<AgentPathogene>(),
    );
  }

  @override
  void write(BinaryWriter writer, BaseVirale obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nom)
      ..writeByte(1)
      ..write(obj.agents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseViraleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
