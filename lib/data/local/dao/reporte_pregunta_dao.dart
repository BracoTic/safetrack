import 'package:hive/hive.dart';
import '../../../models/reporte_pregunta.dart';

class ReportePreguntaDAO {
  Future<Box<ReportePregunta>> get _box async {
    if (!Hive.isBoxOpen('reporte_pregunta')) {
      await Hive.openBox<ReportePregunta>('reporte_pregunta');
    }
    return Hive.box<ReportePregunta>('reporte_pregunta');
  }

  Future<List<ReportePregunta>> getAll() async {
    return (await _box).values.toList();
  }

  Future<List<int>> getPreguntasByReporte(int idReporte) async {
    final box = await _box;
    return box.values
        .where((rp) => rp.idReporte == idReporte)
        .map((rp) => rp.idPregunta)
        .toList();
  }

  Future<List<int>> getReportesByPregunta(int idPregunta) async {
    final box = await _box;
    return box.values
        .where((rp) => rp.idPregunta == idPregunta)
        .map((rp) => rp.idReporte)
        .toList();
  }

  Future<void> insert(ReportePregunta rp) async {
    await (await _box).add(rp);
  }

  Future<void> insertMany(List<ReportePregunta> relaciones) async {
    final box = await _box;
    await box.addAll(relaciones);
  }

  Future<void> delete(ReportePregunta rp) async {
    final box = await _box;
    final key = box.keys.cast<dynamic>().firstWhere(
      (key) => box.get(key) == rp,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
    }
  }

  Future<void> deleteByReporte(int idReporte) async {
    final box = await _box;
    final keys =
        box.keys.where((key) {
          final rp = box.get(key);
          return rp != null && rp.idReporte == idReporte;
        }).toList();

    await box.deleteAll(keys);
  }

  Future<void> deleteByPregunta(int idPregunta) async {
    final box = await _box;
    final keys =
        box.keys.where((key) {
          final rp = box.get(key);
          return rp != null && rp.idPregunta == idPregunta;
        }).toList();

    await box.deleteAll(keys);
  }
}
