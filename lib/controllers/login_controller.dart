import '/data/local/dao/usuario_dao.dart';
import '/data/local/dao/cliente_usuario_dao.dart';
import '/data/local/dao/cliente_dao.dart';
import '/models/cliente.dart';
import '/core/utils/navigation_helper.dart';
import '/models/cliente_usuario.dart';
import 'package:flutter/material.dart';

class LoginController {
  final UsuarioDAO _usuarioDao = UsuarioDAO();
  final ClienteUsuarioDAO _clienteUsuarioDao = ClienteUsuarioDAO();
  final ClienteDAO _clienteDao = ClienteDAO();

  Future<List<Cliente>> cargarClientes() async {
    return await _clienteDao.getAll();
  }

  /// Retorna:
  /// success, message, rol, usuario, clienteUsuario
  Future<Map<String, dynamic>> login({
    required Cliente cliente,
    required String tipoIdentificacion,
    required String numeroIdentificacion,
    required String contrasena,
  }) async {
    final usuario = await _usuarioDao.getByIdentificacionYContrasena(
      tipoIdentificacion,
      numeroIdentificacion,
      contrasena,
    );

    if (usuario == null) {
      return {'success': false, 'message': 'Credenciales inválidas'};
    }

    final relacion = await _clienteUsuarioDao.getByClienteYUsuario(
      cliente.nombre,
      numeroIdentificacion,
    );

    if (relacion == null) {
      return {
        'success': false,
        'message': 'Usuario no vinculado a este cliente',
      };
    }

    return {
      'success': true,
      'message': '',
      'rol': relacion.rol,
      'usuario': usuario,
      'clienteUsuario': relacion,
    };
  }

  void irAlMenuDespuesDeLogin(
    BuildContext context,
    ClienteUsuario clienteUsuario,
  ) {
    NavigationHelper.volverAlMenu(context, clienteUsuario);
  }
}
