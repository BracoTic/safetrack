import '../../models/usuario.dart';
import '../../models/cliente.dart';
import '../../models/cliente_usuario.dart';
import '../../models/rol.dart';
import '../../data/local/dao/usuario_dao.dart';
import '../../data/local/dao/cliente_usuario_dao.dart';
import '../../data/local/dao/cliente_dao.dart';

class FormularioUsuarioSoloNormalController {
  final UsuarioDAO _usuarioDao = UsuarioDAO();
  final ClienteUsuarioDAO _clienteUsuarioDao = ClienteUsuarioDAO();
  final ClienteDAO _clienteDao = ClienteDAO();

  Future<List<Cliente>> obtenerClientes() async {
    return await _clienteDao.getAll();
  }

  Future<String?> registrarUsuario({
    required Cliente cliente,
    required String tipoIdentificacion,
    required String numeroIdentificacion,
    required String nombre,
    required String cargo,
    required String empresa,
    required String contrasena,
    required String correo,
    required String telefono,
  }) async {
    final usuarioExistente = await _usuarioDao.getByNumeroIdentificacion(
      numeroIdentificacion,
    );

    if (usuarioExistente != null) {
      final yaRegistrado = await _clienteUsuarioDao.getByClienteYUsuario(
        cliente.nombre,
        numeroIdentificacion,
      );
      if (yaRegistrado != null) {
        return '⚠️ El usuario ya está registrado para este cliente.';
      }
    }

    final usuario =
        usuarioExistente ??
        Usuario(
          tipoIdentificacion: tipoIdentificacion,
          numeroIdentificacion: numeroIdentificacion,
          nombre: nombre,
          cargo: cargo,
          empresa: empresa,
          rol: Rol.normal,
          contrasena: contrasena,
          correo: correo,
          telefono: telefono,
        );

    if (usuarioExistente == null) {
      await _usuarioDao.insert(usuario);
    }

    final relacion = ClienteUsuario(
      cliente: cliente,
      usuario: usuario,
      rol: Rol.normal,
    );

    await _clienteUsuarioDao.insert(relacion);

    return null; // Todo OK
  }
}
