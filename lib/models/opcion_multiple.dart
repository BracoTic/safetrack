import 'package:hive/hive.dart';

part 'opcion_multiple.g.dart';

@HiveType(typeId: 10)
class OpcionMultiple extends HiveObject {
  @HiveField(0)
  int idPregunta;

  @HiveField(1)
  String textoOpcion;

  @HiveField(2)
  bool sincronizado;

  @HiveField(3)
  String? idRemoto;

  OpcionMultiple({
    required this.idPregunta,
    required this.textoOpcion,
    this.sincronizado = false,
    this.idRemoto,
  });
}
