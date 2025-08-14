import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../../../models/cliente_usuario.dart';

class ClienteUsuarioDAO {
  Future<Box<ClienteUsuario>> get _box async {
    if (!Hive.isBoxOpen('cliente_usuarios')) {
      await Hive.openBox<ClienteUsuario>('cliente_usuarios');
    }
    return Hive.box<ClienteUsuario>('cliente_usuarios');
  }

  Future<List<ClienteUsuario>> getAll() async => (await _box).values.toList();

  Future<List<ClienteUsuario>> getByUsuario(String numeroIdentificacion) async {
    return (await _box).values
        .where((cu) => cu.usuario.numeroIdentificacion == numeroIdentificacion)
        .toList();
  }

  Future<List<ClienteUsuario>> getByCliente(String nombreCliente) async {
    return (await _box).values
        .where((cu) => cu.cliente.nombre == nombreCliente)
        .toList();
  }

  Future<ClienteUsuario?> getByClienteYUsuario(
    String nombreCliente,
    String numeroIdentificacion,
  ) async {
    return (await _box).values.firstWhereOrNull(
      (cu) =>
          cu.cliente.nombre == nombreCliente &&
          cu.usuario.numeroIdentificacion == numeroIdentificacion,
    );
  }

  Future<void> insert(ClienteUsuario clienteUsuario) async {
    await (await _box).add(clienteUsuario);
  }

  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }

  Future<void> update(int key, ClienteUsuario actualizado) async {
    await (await _box).put(key, actualizado);
  }
}
