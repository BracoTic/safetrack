import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/pregunta.dart';
import '../models/opcion_multiple.dart';
import '../models/reporte_pregunta.dart';

class EditarPreguntaController {
  final Pregunta pregunta;
  final Box<Pregunta> _preguntasBox = Hive.box<Pregunta>('preguntas');
  final Box<OpcionMultiple> _opcionesBox = Hive.box<OpcionMultiple>(
    'opcionesMultiple',
  );
  final Box<ReportePregunta> _reportePreguntaBox = Hive.box<ReportePregunta>(
    'reporte_pregunta',
  );

  EditarPreguntaController(this.pregunta);

  List<OpcionMultiple> getOpciones() {
    return _opcionesBox.values
        .where((o) => o.idPregunta == pregunta.idPregunta)
        .toList();
  }

  List<TextEditingController> initOpcionesControllers() {
    return getOpciones()
        .map((o) => TextEditingController(text: o.textoOpcion))
        .toList();
  }

  Future<void> guardarCambios({
    required String texto,
    required String referencia,
    required int nuevoOrden,
    required bool obligatoria,
    required bool activa,
    // Imagen dual (opcional; si vienen null no se toca la imagen)
    String? nuevaImagenPath,
    Uint8List? nuevaImagenBytes,
    String? nuevaImagenMime,
    String? nuevaImagenNombre,
    required List<String> opcionesTexto,
  }) async {
    // Datos básicos
    pregunta
      ..texto = texto
      ..referencia = referencia
      ..obligatoria = obligatoria
      ..activa = activa;

    // Imagen: si se pasa bytes, priorizamos bytes (web); si se pasa path, usamos path (no-web)
    if (nuevaImagenBytes != null) {
      pregunta
        ..imagenApoyoBytes = nuevaImagenBytes
        ..imagenApoyoMime = nuevaImagenMime
        ..imagenApoyoNombre = nuevaImagenNombre
        ..imagenApoyo = null; // limpiar ruta
    } else if (nuevaImagenPath != null) {
      if (nuevaImagenPath.isEmpty) {
        // limpiar completamente
        pregunta
          ..imagenApoyo = null
          ..imagenApoyoBytes = null
          ..imagenApoyoMime = null
          ..imagenApoyoNombre = null;
      } else {
        pregunta
          ..imagenApoyo = nuevaImagenPath
          ..imagenApoyoBytes = null
          ..imagenApoyoMime = null
          ..imagenApoyoNombre = null;
      }
    }

    await pregunta.save();

    // Opciones si la pregunta es múltiple
    if (pregunta.tipoPregunta.name == 'multiple') {
      final anteriores = getOpciones();
      for (var o in anteriores) {
        await o.delete();
      }

      for (final textoOpcion in opcionesTexto) {
        final t = textoOpcion.trim();
        if (t.isNotEmpty) {
          await _opcionesBox.add(
            OpcionMultiple(idPregunta: pregunta.idPregunta, textoOpcion: t),
          );
        }
      }
    }

    await _reordenar(nuevoOrden);
  }

  Future<void> eliminarPregunta() async {
    // Borrar opciones múltiples
    for (var o in getOpciones()) {
      await o.delete();
    }

    // Borrar relaciones en reporte_pregunta
    final relaciones =
        _reportePreguntaBox.values
            .where((rp) => rp.idPregunta == pregunta.idPregunta)
            .toList();

    for (var rp in relaciones) {
      final key = _reportePreguntaBox.keys.firstWhere(
        (k) => _reportePreguntaBox.get(k) == rp,
      );
      await _reportePreguntaBox.delete(key);
    }

    // Borrar la pregunta
    await pregunta.delete();
  }

  Future<void> _reordenar(int nuevoOrden) async {
    final activas =
        _preguntasBox.values.where((p) => p.activa && p != pregunta).toList()
          ..sort((a, b) => a.numeroOrden.compareTo(b.numeroOrden));

    nuevoOrden = nuevoOrden.clamp(1, activas.length + 1);
    activas.insert(nuevoOrden - 1, pregunta);

    for (int i = 0; i < activas.length; i++) {
      activas[i].numeroOrden = i + 1;
      await activas[i].save();
    }

    if (!pregunta.activa) {
      pregunta.numeroOrden = 0;
      await pregunta.save();
    }
  }
}
