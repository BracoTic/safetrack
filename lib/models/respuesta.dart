import 'package:hive/hive.dart';
import 'reporte.dart';
import 'pregunta.dart';

part 'respuesta.g.dart';

@HiveType(typeId: 21)
class Respuesta extends HiveObject {
  @HiveField(0)
  Reporte reporte;

  @HiveField(1)
  Pregunta pregunta;

  @HiveField(2)
  String respuesta;

  @HiveField(3)
  bool sincronizado;

  @HiveField(4)
  String? idRemoto;

  Respuesta({
    required this.reporte,
    required this.pregunta,
    required this.respuesta,
    this.sincronizado = false,
    this.idRemoto,
  });
}
