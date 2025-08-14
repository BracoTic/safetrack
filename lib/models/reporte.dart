import 'package:hive/hive.dart';
import 'cliente_usuario.dart';

part 'reporte.g.dart';

@HiveType(typeId: 3)
class Reporte extends HiveObject {
  @HiveField(0)
  int idReporte; // Identificador único del reporte

  @HiveField(1)
  ClienteUsuario clienteUsuario;

  @HiveField(2)
  DateTime fechaHora; // Fecha de creación local

  @HiveField(3)
  bool sincronizado;

  @HiveField(4)
  String? idRemoto;

  @HiveField(5)
  String solucion; // Editable por usuarios especiales o admin

  @HiveField(6)
  String aprobacion; // "pendiente", "aprobado", "rechazado"

  @HiveField(7)
  DateTime? fechaSubida; // Fecha de sincronización con la nube

  Reporte({
    required this.idReporte,
    required this.clienteUsuario,
    required this.fechaHora,
    this.sincronizado = false,
    this.idRemoto,
    this.solucion = 'Pendiente',
    this.aprobacion = 'pendiente',
    this.fechaSubida,
  });
}
