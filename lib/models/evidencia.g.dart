// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidencia.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvidenciaAdapter extends TypeAdapter<Evidencia> {
  @override
  final int typeId = 5;

  @override
  Evidencia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Evidencia(
      reporte: fields[0] as Reporte,
      clasificacion: fields[1] as Clasificacion,
      fechaHora: fields[2] as DateTime,
      ubicacion: fields[3] as String?,
      imgInseguro: fields[4] as String?,
      sincronizado: fields[5] as bool,
      idRemoto: fields[6] as String?,
      imgBytes: fields[7] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, Evidencia obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.reporte)
      ..writeByte(1)
      ..write(obj.clasificacion)
      ..writeByte(2)
      ..write(obj.fechaHora)
      ..writeByte(3)
      ..write(obj.ubicacion)
      ..writeByte(4)
      ..write(obj.imgInseguro)
      ..writeByte(5)
      ..write(obj.sincronizado)
      ..writeByte(6)
      ..write(obj.idRemoto)
      ..writeByte(7)
      ..write(obj.imgBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvidenciaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
