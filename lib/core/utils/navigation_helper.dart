import 'package:flutter/material.dart';
import 'package:safetrack/views/reportes_historial_screen.dart';
import '../../models/cliente_usuario.dart';
import '../../views/menu_admin_screen.dart';
import '../../views/menu_especial_screen.dart';
import '../../views/menu_normal_screen.dart';
import '../../views/editar_variables_screen.dart';
import '../../views/login_screen.dart';
import '../../views/inicio_screen.dart'; // 👈 NUEVO

class NavigationHelper {
  static void volverAlMenu(
    BuildContext context,
    ClienteUsuario clienteUsuario,
  ) {
    final rol = clienteUsuario.rol.toString().split('.').last.toLowerCase();

    Widget pantalla;
    if (rol == 'admin') {
      pantalla = MenuAdminScreen(clienteUsuario: clienteUsuario);
    } else if (rol == 'especial') {
      pantalla = MenuEspecialScreen(clienteUsuario: clienteUsuario);
    } else {
      pantalla = MenuNormalScreen(clienteUsuario: clienteUsuario);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  static Widget buildEditarVariables(ClienteUsuario clienteUsuario) {
    return EditarVariablesScreen(clienteUsuario: clienteUsuario);
  }

  static Widget buildReporteHistorial(ClienteUsuario clienteUsuario) {
    return ReportesHistorialScreen(clienteUsuario: clienteUsuario);
  }

  static void cancelarRegistro(BuildContext context) {
    Navigator.pop(context);
  }

  static void cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// 👇 NUEVO: flecha en Login que vuelve a Inicio
  static void irAInicio(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InicioScreen()),
    );
    // Si usas rutas con nombre:
    // Navigator.pushReplacementNamed(context, '/inicio');
  }
}
