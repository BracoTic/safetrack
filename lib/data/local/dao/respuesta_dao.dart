import 'package:hive/hive.dart';
import '../../../models/respuesta.dart';

class RespuestaDAO {
  Future<Box<Respuesta>> get _box async {
    if (!Hive.isBoxOpen('respuestas')) {
      await Hive.openBox<Respuesta>('respuestas');
    }
    return Hive.box<Respuesta>('respuestas');
  }

  /// ✅ Insertar nueva respuesta
  Future<void> insert(Respuesta respuesta) async {
    final box = await _box;
    await box.add(respuesta);
  }

  /// ✅ Obtener todas las respuestas asociadas a un reporte
  Future<List<Respuesta>> getByReporte(int idReporte) async {
    final box = await _box;
    return box.values.where((r) => r.reporte.key == idReporte).toList();
  }

  /// ✅ Obtener una respuesta específica por reporte y pregunta
  Future<Respuesta?> getByReporteYPregunta(
    int idReporte,
    int idPregunta,
  ) async {
    final box = await _box;
    try {
      return box.values.firstWhere(
        (r) => r.reporte.key == idReporte && r.pregunta.key == idPregunta,
      );
    } catch (_) {
      return null;
    }
  }

  /// ✅ Eliminar todas las respuestas de un reporte (opcional)
  Future<void> deleteAllByReporte(int idReporte) async {
    final box = await _box;
    final toDelete =
        box.values
            .where((r) => r.reporte.key == idReporte)
            .map((r) => r.key)
            .toList();
    await box.deleteAll(toDelete);
  }
}
