// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memoire_immunitaire.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoireImmunitaireAdapter extends TypeAdapter<MemoireImmunitaire> {
  @override
  final int typeId = 7;

  @override
  MemoireImmunitaire read(BinaryReader reader) {
    return MemoireImmunitaire();
  }

  @override
  void write(BinaryWriter writer, MemoireImmunitaire obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.signatures);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoireImmunitaireAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
