import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'reporte.dart';
import 'clasificacion.dart';

part 'evidencia.g.dart';

@HiveType(typeId: 5)
class Evidencia extends HiveObject {
  @HiveField(0)
  Reporte reporte;

  @HiveField(1)
  Clasificacion clasificacion;

  @HiveField(2)
  DateTime fechaHora;

  /// Coordenadas, texto u otra referencia libre
  @HiveField(3)
  String? ubicacion;

  /// Ruta de archivo local (Android/iOS/desktop). En Web normalmente será inútil.
  @HiveField(4)
  String? imgInseguro;

  /// Sincronización con backend
  @HiveField(5)
  bool sincronizado;

  /// ID en el backend (si aplica)
  @HiveField(6)
  String? idRemoto;

  /// 🔴 NUEVO: bytes de imagen (para Web; también usable en móvil si prefieres).
  /// Guardamos la imagen directamente en Hive para soportar navegadores.
  @HiveField(7)
  Uint8List? imgBytes;

  Evidencia({
    required this.reporte,
    required this.clasificacion,
    required this.fechaHora,
    this.ubicacion,
    this.imgInseguro,
    this.sincronizado = false,
    this.idRemoto,
    this.imgBytes, // nuevo parámetro opcional
  });

  // ---- Helpers de compatibilidad / conveniencia ----
  int get idReporte => reporte.idReporte;
  int get idClasificacion => clasificacion.key as int;

  bool get hasBytes => imgBytes != null && imgBytes!.isNotEmpty;
  bool get hasFilePath => (imgInseguro ?? '').isNotEmpty;

  @override
  String toString() =>
      'Evidencia(reporte: ${reporte.idReporte}, clasif: $idClasificacion, fecha: $fechaHora, hasBytes: $hasBytes, path: $imgInseguro)';
}
