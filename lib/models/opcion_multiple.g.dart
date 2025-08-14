// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opcion_multiple.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OpcionMultipleAdapter extends TypeAdapter<OpcionMultiple> {
  @override
  final int typeId = 10;

  @override
  OpcionMultiple read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OpcionMultiple(
      idPregunta: fields[0] as int,
      textoOpcion: fields[1] as String,
      sincronizado: fields[2] as bool,
      idRemoto: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OpcionMultiple obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.idPregunta)
      ..writeByte(1)
      ..write(obj.textoOpcion)
      ..writeByte(2)
      ..write(obj.sincronizado)
      ..writeByte(3)
      ..write(obj.idRemoto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpcionMultipleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
