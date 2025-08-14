import 'package:hive/hive.dart';
import 'cliente.dart';
import 'cliente_usuario.dart';

part 'ranking.g.dart';

@HiveType(typeId: 0)
class Ranking extends HiveObject {
  @HiveField(0)
  Cliente cliente;

  @HiveField(1)
  ClienteUsuario usuario;

  @HiveField(2)
  String periodo; // Ej: '2025-06' para junio 2025

  @HiveField(3)
  int puntuacion;

  @HiveField(4)
  String medalla;

  @HiveField(5)
  bool sincronizado;

  @HiveField(6)
  String? idRemoto;

  Ranking({
    required this.cliente,
    required this.usuario,
    required this.periodo,
    this.puntuacion = 0,
    this.medalla = 'Sin medalla',
    this.sincronizado = false,
    this.idRemoto,
  });
}
