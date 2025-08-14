import 'package:hive/hive.dart';
import '../../../models/pregunta.dart';
import '../../../models/reporte_pregunta.dart';

class PreguntaDAO {
  Future<Box<Pregunta>> get _box async {
    if (!Hive.isBoxOpen('preguntas')) {
      await Hive.openBox<Pregunta>('preguntas');
    }
    return Hive.box<Pregunta>('preguntas');
  }

  Future<List<Pregunta>> getAll() async => (await _box).values.toList();

  Future<int> insert(Pregunta pregunta) async {
    return await (await _box).add(pregunta);
  }

  Future<void> update(int key, Pregunta pregunta) async {
    await (await _box).put(key, pregunta);
  }

  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }

  Future<Pregunta?> getById(int id) async {
    return (await _box).get(id);
  }

  Future<List<Pregunta>> getByReporte(int idReporte) async {
    final reportePreguntaBox = await Hive.openBox<ReportePregunta>(
      'reporte_pregunta',
    );
    final preguntasBox = await _box;

    return reportePreguntaBox.values
        .where((rp) => rp.idReporte == idReporte)
        .map((rp) => preguntasBox.get(rp.idPregunta))
        .whereType<Pregunta>()
        .toList();
  }

  Future<List<Pregunta>> getNoSincronizadas() async {
    return (await _box).values.where((p) => !p.sincronizado).toList();
  }

  /// ✅ Nuevo: obtener solo preguntas activas
  Future<List<Pregunta>> getAllActivas() async {
    return (await _box).values.where((p) => p.activa).toList();
  }
}
