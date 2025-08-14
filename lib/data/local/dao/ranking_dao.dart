import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../../../models/ranking.dart';

class RankingDAO {
  Future<Box<Ranking>> get _box async {
    if (!Hive.isBoxOpen('rankings')) {
      await Hive.openBox<Ranking>('rankings');
    }
    return Hive.box<Ranking>('rankings');
  }

  Future<List<Ranking>> getAll() async => (await _box).values.toList();

  Future<List<Ranking>> getByCliente(String nombreCliente) async {
    return (await _box).values
        .where((r) => r.cliente.nombre == nombreCliente)
        .toList();
  }

  Future<List<Ranking>> getByUsuario(String numeroIdentificacion) async {
    return (await _box).values
        .where(
          (r) => r.usuario.usuario.numeroIdentificacion == numeroIdentificacion,
        )
        .toList();
  }

  Future<Ranking?> getMensual(
    String numeroIdentificacion,
    String periodo,
  ) async {
    return (await _box).values.firstWhereOrNull(
      (r) =>
          r.usuario.usuario.numeroIdentificacion == numeroIdentificacion &&
          r.periodo == periodo,
    );
  }

  Future<void> insert(Ranking ranking) async {
    await (await _box).add(ranking);
  }

  Future<void> update(int key, Ranking rankingActualizado) async {
    await (await _box).put(key, rankingActualizado);
  }

  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }
}
