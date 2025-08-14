// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clasificacion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasificacionAdapter extends TypeAdapter<Clasificacion> {
  @override
  final int typeId = 6;

  @override
  Clasificacion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Clasificacion(
      nombre: fields[0] as String,
      descripcion: fields[1] as String?,
      sincronizado: fields[2] as bool,
      idRemoto: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Clasificacion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.descripcion)
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
      other is ClasificacionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
