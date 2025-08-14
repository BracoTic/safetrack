import 'package:hive/hive.dart';
import 'rol.dart';

part 'usuario.g.dart';

@HiveType(typeId: 1)
class Usuario extends HiveObject {
  @HiveField(0)
  String tipoIdentificacion;

  @HiveField(1)
  String numeroIdentificacion;

  @HiveField(2)
  String nombre;

  @HiveField(3)
  String cargo;

  @HiveField(4)
  String empresa;

  @HiveField(5)
  Rol rol;

  @HiveField(6)
  String contrasena;

  @HiveField(7)
  String correo;

  @HiveField(8)
  String telefono;

  @HiveField(9)
  bool sincronizado;

  @HiveField(10)
  String? idRemoto;

  Usuario({
    required this.tipoIdentificacion,
    required this.numeroIdentificacion,
    required this.nombre,
    required this.cargo,
    required this.empresa,
    required this.rol,
    required this.contrasena,
    required this.correo,
    required this.telefono,
    this.sincronizado = false,
    this.idRemoto,
  });
}
