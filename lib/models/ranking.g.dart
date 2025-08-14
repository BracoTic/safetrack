// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RankingAdapter extends TypeAdapter<Ranking> {
  @override
  final int typeId = 0;

  @override
  Ranking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ranking(
      cliente: fields[0] as Cliente,
      usuario: fields[1] as ClienteUsuario,
      periodo: fields[2] as String,
      puntuacion: fields[3] as int,
      medalla: fields[4] as String,
      sincronizado: fields[5] as bool,
      idRemoto: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Ranking obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.cliente)
      ..writeByte(1)
      ..write(obj.usuario)
      ..writeByte(2)
      ..write(obj.periodo)
      ..writeByte(3)
      ..write(obj.puntuacion)
      ..writeByte(4)
      ..write(obj.medalla)
      ..writeByte(5)
      ..write(obj.sincronizado)
      ..writeByte(6)
      ..write(obj.idRemoto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
