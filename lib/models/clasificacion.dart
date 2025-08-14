import 'package:hive/hive.dart';

part 'clasificacion.g.dart';

@HiveType(typeId: 6)
class Clasificacion extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  String? descripcion;

  @HiveField(2)
  bool sincronizado;

  @HiveField(3)
  String? idRemoto;

  Clasificacion({
    required this.nombre,
    this.descripcion,
    this.sincronizado = false,
    this.idRemoto,
  });
}
