// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rol.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RolAdapter extends TypeAdapter<Rol> {
  @override
  final int typeId = 2;

  @override
  Rol read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Rol.normal;
      case 1:
        return Rol.especial;
      case 2:
        return Rol.admin;
      default:
        return Rol.normal;
    }
  }

  @override
  void write(BinaryWriter writer, Rol obj) {
    switch (obj) {
      case Rol.normal:
        writer.writeByte(0);
        break;
      case Rol.especial:
        writer.writeByte(1);
        break;
      case Rol.admin:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
