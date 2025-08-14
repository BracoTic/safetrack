import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'tipo_pregunta.dart';
import 'tema.dart';

part 'pregunta.g.dart';

@HiveType(typeId: 9)
class Pregunta extends HiveObject {
  @HiveField(0)
  int idPregunta;

  @HiveField(1)
  Tema tema;

  @HiveField(2)
  String texto;

  @HiveField(3)
  TipoPregunta tipoPregunta;

  @HiveField(4)
  bool activa;

  @HiveField(5)
  bool obligatoria;

  @HiveField(6)
  int numeroOrden;

  /// Ruta de archivo local (Android/iOS/desktop).
  /// Se mantiene por compatibilidad.
  @HiveField(7)
  String? imagenApoyo;

  @HiveField(8)
  bool sincronizado;

  @HiveField(9)
  String? idRemoto;

  @HiveField(10)
  String? referencia;

  // ─── NUEVO: soporte Web ────────────────────────────────────────────────────

  /// Bytes de la imagen de apoyo (para Web o cuando prefieras persistir bytes).
  @HiveField(11)
  Uint8List? imagenApoyoBytes;

  /// Opcional: tipo MIME de la imagen (ej. 'image/png', 'image/jpeg').
  @HiveField(12)
  String? imagenApoyoMime;

  /// Opcional: nombre de archivo original (ej. 'foto.png').
  @HiveField(13)
  String? imagenApoyoNombre;

  // ─── Getters de conveniencia (sin dependencias de Flutter) ────────────────

  /// ¿Tiene imagen por cualquier medio (ruta o bytes)?
  bool get hasImagenApoyo =>
      (imagenApoyo != null && imagenApoyo!.isNotEmpty) ||
      (imagenApoyoBytes != null && imagenApoyoBytes!.isNotEmpty);

  /// ¿Tiene imagen guardada como archivo (ruta)?
  bool get hasImagenArchivo => imagenApoyo != null && imagenApoyo!.isNotEmpty;

  /// ¿Tiene imagen guardada como bytes (web)?
  bool get hasImagenBytes =>
      imagenApoyoBytes != null && imagenApoyoBytes!.isNotEmpty;

  Pregunta({
    required this.idPregunta,
    required this.tema,
    required this.texto,
    required this.tipoPregunta,
    this.activa = true,
    this.obligatoria = true,
    required this.numeroOrden,
    this.imagenApoyo,
    this.sincronizado = false,
    this.idRemoto,
    this.referencia,
    // nuevos (opcionales)
    this.imagenApoyoBytes,
    this.imagenApoyoMime,
    this.imagenApoyoNombre,
  });
}
