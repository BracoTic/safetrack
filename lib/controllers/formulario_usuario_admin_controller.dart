// lib/controllers/usuarios/formulario_usuario_admin_controller.dart

import '../../models/usuario.dart';
import '../../models/rol.dart';
import '../../models/cliente.dart';
import '../../models/cliente_usuario.dart';
import '../../data/local/dao/usuario_dao.dart';
import '../../data/local/dao/cliente_usuario_dao.dart';

class FormularioUsuarioAdminController {
  final UsuarioDAO _usuarioDao = UsuarioDAO();
  final ClienteUsuarioDAO _clienteUsuarioDao = ClienteUsuarioDAO();

  /// Crea o reutiliza el Usuario y SIEMPRE vincula con el cliente del admin
  /// mediante ClienteUsuario (con el rol seleccionado).
  ///
  /// Devuelve `null` si todo OK; string con error si algo falla/ya existe.
  Future<String?> registrarUsuario({
    required Cliente cliente, // 👈 cliente del admin (p.ej. Serinco)
    required String tipoIdentificacion,
    required String numeroIdentificacion,
    required String nombre,
    required String cargo,
    required String empresa,
    required String contrasena,
    required Rol rol, // 👈 rol elegido en el form (normal/especial/admin)
    required String correo,
    required String telefono,
  }) async {
    // 1) Buscar si ya existe el Usuario por número de identificación
    final usuarioExistente = await _usuarioDao.getByNumeroIdentificacion(
      numeroIdentificacion,
    );

    Usuario usuario;
    if (usuarioExistente != null) {
      // Ya existe el usuario globalmente
      usuario = usuarioExistente;

      // 1.a) ¿Ya está vinculado con este cliente?
      final yaRegistrado = await _clienteUsuarioDao.getByClienteYUsuario(
        cliente.nombre,
        numeroIdentificacion,
      );
      if (yaRegistrado != null) {
        // Mismo criterio que el formulario “normal”: evitar duplicado
        return '⚠️ El usuario ya está registrado para este cliente.';
      }

      // (Opcional: podrías actualizar datos básicos del usuario aquí si quieres)
      // usuario.nombre = nombre; ... await usuario.save();
    } else {
      // 2) Crear el Usuario nuevo con el rol elegido
      usuario = Usuario(
        tipoIdentificacion: tipoIdentificacion,
        numeroIdentificacion: numeroIdentificacion,
        nombre: nombre,
        cargo: cargo,
        empresa: empresa,
        rol:
            rol, // Nota: sigues guardando también el rol en Usuario (como en tu flujo normal)
        contrasena: contrasena,
        correo: correo,
        telefono: telefono,
      );
      await _usuarioDao.insert(usuario);
    }

    // 3) Crear la relación ClienteUsuario (rol por cliente)
    final relacion = ClienteUsuario(
      cliente: cliente,
      usuario: usuario,
      rol: rol,
    );
    await _clienteUsuarioDao.insert(relacion);

    return null; // Todo OK
  }
}
