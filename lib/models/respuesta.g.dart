// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'respuesta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RespuestaAdapter extends TypeAdapter<Respuesta> {
  @override
  final int typeId = 21;

  @override
  Respuesta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Respuesta(
      reporte: fields[0] as Reporte,
      pregunta: fields[1] as Pregunta,
      respuesta: fields[2] as String,
      sincronizado: fields[3] as bool,
      idRemoto: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Respuesta obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.reporte)
      ..writeByte(1)
      ..write(obj.pregunta)
      ..writeByte(2)
      ..write(obj.respuesta)
      ..writeByte(3)
      ..write(obj.sincronizado)
      ..writeByte(4)
      ..write(obj.idRemoto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RespuestaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
