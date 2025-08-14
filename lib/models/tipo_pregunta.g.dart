// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_pregunta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipoPreguntaAdapter extends TypeAdapter<TipoPregunta> {
  @override
  final int typeId = 11;

  @override
  TipoPregunta read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoPregunta.string;
      case 1:
        return TipoPregunta.multiple;
      default:
        return TipoPregunta.string;
    }
  }

  @override
  void write(BinaryWriter writer, TipoPregunta obj) {
    switch (obj) {
      case TipoPregunta.string:
        writer.writeByte(0);
        break;
      case TipoPregunta.multiple:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoPreguntaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
