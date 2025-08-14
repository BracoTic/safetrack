import 'package:hive/hive.dart';
import '../../../models/usuario.dart';
import 'package:collection/collection.dart';

class UsuarioDAO {
  Future<Box<Usuario>> get _box async {
    if (!Hive.isBoxOpen('usuarios')) {
      await Hive.openBox<Usuario>('usuarios');
    }
    return Hive.box<Usuario>('usuarios');
  }

  Future<List<Usuario>> getAll() async => (await _box).values.toList();

  Future<Usuario?> getByIdentificacionYContrasena(
    String tipoIdentificacion,
    String numeroIdentificacion,
    String contrasena,
  ) async {
    return (await _box).values.firstWhereOrNull(
      (u) =>
          u.tipoIdentificacion == tipoIdentificacion &&
          u.numeroIdentificacion == numeroIdentificacion &&
          u.contrasena == contrasena,
    );
  }

  Future<Usuario?> getByNumeroIdentificacion(
    String numeroIdentificacion,
  ) async {
    return (await _box).values.firstWhereOrNull(
      (u) => u.numeroIdentificacion == numeroIdentificacion,
    );
  }

  Future<void> insert(Usuario usuario) async {
    await (await _box).add(usuario);
  }

  Future<void> delete(Usuario usuario) async {
    await usuario.delete();
  }
}
