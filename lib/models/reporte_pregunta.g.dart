// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reporte_pregunta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportePreguntaAdapter extends TypeAdapter<ReportePregunta> {
  @override
  final int typeId = 12;

  @override
  ReportePregunta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportePregunta(
      idReporte: fields[0] as int,
      idPregunta: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ReportePregunta obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.idReporte)
      ..writeByte(1)
      ..write(obj.idPregunta);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportePreguntaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
