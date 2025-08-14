import 'package:hive/hive.dart';
import '../../../models/tema.dart';

class TemaDAO {
  Future<Box<Tema>> get _box async {
    if (!Hive.isBoxOpen('temas')) {
      await Hive.openBox<Tema>('temas');
    }
    return Hive.box<Tema>('temas');
  }

  Future<List<Tema>> getAll() async => (await _box).values.toList();

  Future<void> insert(Tema tema) async {
    await (await _box).add(tema);
  }

  Future<void> update(int key, Tema temaActualizado) async {
    await (await _box).put(key, temaActualizado);
  }

  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }
}
