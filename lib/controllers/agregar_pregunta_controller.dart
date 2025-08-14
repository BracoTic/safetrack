import 'dart:typed_data';
import 'package:hive/hive.dart';
import '../models/pregunta.dart';
import '../models/opcion_multiple.dart';
import '../models/tema.dart';
import '../models/tipo_pregunta.dart';

class AgregarPreguntaController {
  final Box<Pregunta> _preguntasBox = Hive.box<Pregunta>('preguntas');
  final Box<OpcionMultiple> _opcionesBox = Hive.box<OpcionMultiple>(
    'opcionesMultiple',
  );
  final Box<Tema> _temasBox = Hive.box<Tema>('temas');

  List<Tema> getTemas() => _temasBox.values.toList();

  Future<int> agregarPregunta({
    required String texto,
    required String referencia,
    required TipoPregunta tipo,
    required bool obligatoria,
    required Tema tema,
    // Ruta (móvil/desktop)
    String? imagenPath,
    // Bytes (web)
    Uint8List? imagenBytes,
    String? imagenMime,
    String? imagenNombre,
    required int ordenDeseado,
    List<String>? opciones,
  }) async {
    // Reordenar hueco
    final activas =
        _preguntasBox.values
            .where((p) => p.activa && p.numeroOrden > 0)
            .toList()
          ..sort((a, b) => a.numeroOrden.compareTo(b.numeroOrden));

    int ordenFinal =
        (ordenDeseado <= 0 || ordenDeseado > activas.length)
            ? activas.length + 1
            : ordenDeseado;

    for (var p in activas.reversed) {
      if (p.numeroOrden >= ordenFinal) {
        p.numeroOrden++;
        await p.save();
      }
    }

    // Crear pregunta con soporte dual de imagen
    final nueva = Pregunta(
      idPregunta: 0, // se asigna luego
      tema: tema,
      texto: texto,
      referencia: referencia,
      tipoPregunta: tipo,
      obligatoria: obligatoria,
      numeroOrden: ordenFinal,
      imagenApoyo: imagenPath, // ruta (no-web)
      imagenApoyoBytes: imagenBytes, // bytes (web)
      imagenApoyoMime: imagenMime,
      imagenApoyoNombre: imagenNombre,
    );

    final key = await _preguntasBox.add(nueva);

    // Guardar id autogenerado
    final guardada = _preguntasBox.get(key)!;
    guardada.idPregunta = key;
    await guardada.save();

    // Opciones si aplica
    if (tipo == TipoPregunta.multiple && opciones != null) {
      for (final op in opciones) {
        final t = op.trim();
        if (t.isNotEmpty) {
          await _opcionesBox.add(
            OpcionMultiple(idPregunta: key, textoOpcion: t),
          );
        }
      }
    }

    return key;
  }
}
