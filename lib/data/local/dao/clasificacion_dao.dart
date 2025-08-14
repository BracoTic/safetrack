import 'package:hive/hive.dart';
import '/models/clasificacion.dart';

class ClasificacionDAO {
  Future<Box<Clasificacion>> get _box async {
    if (!Hive.isBoxOpen('clasificaciones')) {
      await Hive.openBox<Clasificacion>('clasificaciones');
    }
    return Hive.box<Clasificacion>('clasificaciones');
  }

  Future<List<Clasificacion>> getAll() async {
    return (await _box).values.toList();
  }

  Future<void> insert(Clasificacion clasificacion) async {
    await (await _box).add(clasificacion);
  }

  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }

  Future<void> update(int key, Clasificacion clasificacionActualizada) async {
    await (await _box).put(key, clasificacionActualizada);
  }

  Future<Clasificacion?> getById(int id) async {
    return (await _box).get(id);
  }

  Future<List<Clasificacion>> getNoSincronizadas() async {
    return (await _box).values.where((c) => !c.sincronizado).toList();
  }
}
