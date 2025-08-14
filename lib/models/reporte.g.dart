// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reporte.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReporteAdapter extends TypeAdapter<Reporte> {
  @override
  final int typeId = 3;

  @override
  Reporte read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reporte(
      idReporte: fields[0] as int,
      clienteUsuario: fields[1] as ClienteUsuario,
      fechaHora: fields[2] as DateTime,
      sincronizado: fields[3] as bool,
      idRemoto: fields[4] as String?,
      solucion: fields[5] as String,
      aprobacion: fields[6] as String,
      fechaSubida: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Reporte obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.idReporte)
      ..writeByte(1)
      ..write(obj.clienteUsuario)
      ..writeByte(2)
      ..write(obj.fechaHora)
      ..writeByte(3)
      ..write(obj.sincronizado)
      ..writeByte(4)
      ..write(obj.idRemoto)
      ..writeByte(5)
      ..write(obj.solucion)
      ..writeByte(6)
      ..write(obj.aprobacion)
      ..writeByte(7)
      ..write(obj.fechaSubida);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReporteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
