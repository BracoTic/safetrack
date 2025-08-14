import 'package:hive/hive.dart';

part 'tema.g.dart';

@HiveType(typeId: 7)
class Tema extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  String? descripcion;

  @HiveField(2)
  bool sincronizado;

  @HiveField(3)
  String? idRemoto;

  Tema({
    required this.nombre,
    this.descripcion,
    this.sincronizado = false,
    this.idRemoto,
  });
}
