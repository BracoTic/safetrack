// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_usuario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClienteUsuarioAdapter extends TypeAdapter<ClienteUsuario> {
  @override
  final int typeId = 4;

  @override
  ClienteUsuario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClienteUsuario(
      cliente: fields[0] as Cliente,
      usuario: fields[1] as Usuario,
      rol: fields[2] as Rol,
      sincronizado: fields[3] as bool,
      idRemoto: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClienteUsuario obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cliente)
      ..writeByte(1)
      ..write(obj.usuario)
      ..writeByte(2)
      ..write(obj.rol)
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
      other is ClienteUsuarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
