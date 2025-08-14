import 'package:hive/hive.dart';
import 'cliente.dart';
import 'usuario.dart';
import 'rol.dart';

part 'cliente_usuario.g.dart';

@HiveType(typeId: 4)
class ClienteUsuario extends HiveObject {
  @HiveField(0)
  Cliente cliente;

  @HiveField(1)
  Usuario usuario;

  @HiveField(2)
  Rol rol;

  @HiveField(3)
  bool sincronizado;

  @HiveField(4)
  String? idRemoto;

  ClienteUsuario({
    required this.cliente,
    required this.usuario,
    required this.rol,
    this.sincronizado = false,
    this.idRemoto,
  });
}
