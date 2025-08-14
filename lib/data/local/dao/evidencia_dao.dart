import 'package:hive/hive.dart';
import '../../../models/evidencia.dart';

class EvidenciaDAO {
  Future<Box<Evidencia>> get _box async {
    if (!Hive.isBoxOpen('evidencias')) {
      await Hive.openBox<Evidencia>('evidencias');
    }
    return Hive.box<Evidencia>('evidencias');
  }

  Future<int> insert(Evidencia evidencia) async {
    return await (await _box).add(evidencia);
  }

  Future<List<Evidencia>> getByReporte(int idReporte) async {
    return (await _box).values
        .where((e) => e.reporte.idReporte == idReporte)
        .toList();
  }

  Future<List<Evidencia>> getNoSincronizadas() async {
    return (await _box).values.where((e) => !e.sincronizado).toList();
  }

  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }

  Future<void> update(int key, Evidencia evidencia) async {
    await (await _box).put(key, evidencia);
  }

  Future<Evidencia?> getById(int id) async {
    return (await _box).get(id);
  }
}
