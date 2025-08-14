import 'package:hive/hive.dart';
import '/models/cliente.dart';

class ClienteDAO {
  Future<Box<Cliente>> get _box async {
    if (!Hive.isBoxOpen('clientes')) {
      await Hive.openBox<Cliente>('clientes');
    }
    return Hive.box<Cliente>('clientes');
  }

  Future<List<Cliente>> getAll() async => (await _box).values.toList();

  Future<Cliente?> getById(int key) async => (await _box).get(key);

  Future<void> save(Cliente cliente) async {
    await (await _box).add(cliente);
  }

  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }

  Future<void> update(int key, Cliente clienteActualizado) async {
    await (await _box).put(key, clienteActualizado);
  }
}
