// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregunta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PreguntaAdapter extends TypeAdapter<Pregunta> {
  @override
  final int typeId = 9;

  @override
  Pregunta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pregunta(
      idPregunta: fields[0] as int,
      tema: fields[1] as Tema,
      texto: fields[2] as String,
      tipoPregunta: fields[3] as TipoPregunta,
      activa: fields[4] as bool,
      obligatoria: fields[5] as bool,
      numeroOrden: fields[6] as int,
      imagenApoyo: fields[7] as String?,
      sincronizado: fields[8] as bool,
      idRemoto: fields[9] as String?,
      referencia: fields[10] as String?,
      imagenApoyoBytes: fields[11] as Uint8List?,
      imagenApoyoMime: fields[12] as String?,
      imagenApoyoNombre: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Pregunta obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.idPregunta)
      ..writeByte(1)
      ..write(obj.tema)
      ..writeByte(2)
      ..write(obj.texto)
      ..writeByte(3)
      ..write(obj.tipoPregunta)
      ..writeByte(4)
      ..write(obj.activa)
      ..writeByte(5)
      ..write(obj.obligatoria)
      ..writeByte(6)
      ..write(obj.numeroOrden)
      ..writeByte(7)
      ..write(obj.imagenApoyo)
      ..writeByte(8)
      ..write(obj.sincronizado)
      ..writeByte(9)
      ..write(obj.idRemoto)
      ..writeByte(10)
      ..write(obj.referencia)
      ..writeByte(11)
      ..write(obj.imagenApoyoBytes)
      ..writeByte(12)
      ..write(obj.imagenApoyoMime)
      ..writeByte(13)
      ..write(obj.imagenApoyoNombre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreguntaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
