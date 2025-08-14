import '../../models/cliente_usuario.dart';

class ModificarUsuarioController {
  final ClienteUsuario clienteUsuario;

  ModificarUsuarioController(this.clienteUsuario);

  void actualizarDatos({
    required String nombre,
    required String cargo,
    required String empresa,
    required String contrasena,
    required String correo,
    required String telefono,
  }) {
    clienteUsuario.usuario.nombre = nombre;
    clienteUsuario.usuario.cargo = cargo;
    clienteUsuario.usuario.empresa = empresa;
    clienteUsuario.usuario.contrasena = contrasena;
    clienteUsuario.usuario.correo = correo;
    clienteUsuario.usuario.telefono = telefono;
  }

  Future<void> guardar() async {
    await clienteUsuario.usuario.save();
  }
}
