import 'package:hive/hive.dart';
import '../../../models/opcion_multiple.dart';

class OpcionMultipleDAO {
  Future<Box<OpcionMultiple>> get _box async {
    if (!Hive.isBoxOpen('opcionesMultiple')) {
      await Hive.openBox<OpcionMultiple>('opcionesMultiple');
    }
    return Hive.box<OpcionMultiple>('opcionesMultiple');
  }

  Future<List<OpcionMultiple>> getAll() async {
    return (await _box).values.toList();
  }

  Future<int> insert(OpcionMultiple opcion) async {
    return await (await _box).add(opcion);
  }

  Future<void> update(int key, OpcionMultiple opcion) async {
    await (await _box).put(key, opcion);
  }

  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }

  Future<OpcionMultiple?> getById(int id) async {
    return (await _box).get(id);
  }

  Future<List<OpcionMultiple>> getByPregunta(int idPregunta) async {
    return (await _box).values
        .where((o) => o.idPregunta == idPregunta)
        .toList();
  }

  Future<List<OpcionMultiple>> getNoSincronizadas() async {
    return (await _box).values.where((o) => !o.sincronizado).toList();
  }
}
