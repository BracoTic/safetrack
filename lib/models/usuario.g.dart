// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsuarioAdapter extends TypeAdapter<Usuario> {
  @override
  final int typeId = 1;

  @override
  Usuario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Usuario(
      tipoIdentificacion: fields[0] as String,
      numeroIdentificacion: fields[1] as String,
      nombre: fields[2] as String,
      cargo: fields[3] as String,
      empresa: fields[4] as String,
      rol: fields[5] as Rol,
      contrasena: fields[6] as String,
      correo: fields[7] as String,
      telefono: fields[8] as String,
      sincronizado: fields[9] as bool,
      idRemoto: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Usuario obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.tipoIdentificacion)
      ..writeByte(1)
      ..write(obj.numeroIdentificacion)
      ..writeByte(2)
      ..write(obj.nombre)
      ..writeByte(3)
      ..write(obj.cargo)
      ..writeByte(4)
      ..write(obj.empresa)
      ..writeByte(5)
      ..write(obj.rol)
      ..writeByte(6)
      ..write(obj.contrasena)
      ..writeByte(7)
      ..write(obj.correo)
      ..writeByte(8)
      ..write(obj.telefono)
      ..writeByte(9)
      ..write(obj.sincronizado)
      ..writeByte(10)
      ..write(obj.idRemoto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
