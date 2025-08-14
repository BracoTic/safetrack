import 'package:hive/hive.dart';

part 'cliente.g.dart';

@HiveType(typeId: 8)
class Cliente extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  String logoPath;

  @HiveField(2)
  String colorPrimario;

  @HiveField(3)
  String colorSecundario;

  @HiveField(4)
  bool sincronizado;

  @HiveField(5)
  String? idRemoto;

  Cliente({
    required this.nombre,
    required this.logoPath,
    required this.colorPrimario,
    required this.colorSecundario,
    this.sincronizado = false,
    this.idRemoto,
  });
}
