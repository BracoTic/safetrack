import 'package:flutter/material.dart';
import '/models/cliente_usuario.dart';
import '/core/entities/menu_option.dart';
import '/views/reporte_instruccion_screen.dart';
import '/views/modificar_usuario_screen.dart';
import '/views/reportes_historial_screen.dart';
import '/core/utils/navigation_helper.dart';

class MenuNormalController {
  final ClienteUsuario clienteUsuario;

  MenuNormalController(this.clienteUsuario);

  List<MenuOption> getMenuOptions() {
    return [
      MenuOption(
        title: 'Iniciar Reporte',
        icon: Icons.poll,
        color: const Color(0xFFCD5D1B),
        onTap:
            (context) => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ReporteInstruccionScreen(
                      clienteUsuario: clienteUsuario,
                    ),
              ),
            ),
      ),
      MenuOption(
        title: 'Actualizar mis Datos',
        icon: Icons.edit,
        color: const Color(0xFFCD5D1B),
        onTap:
            (context) => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        ModificarUsuarioScreen(clienteUsuario: clienteUsuario),
              ),
            ),
      ),
      MenuOption(
        title: 'Mis Reportes',
        icon: Icons.history,
        color: const Color(0xFFCD5D1B),
        onTap:
            (context) => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        ReportesHistorialScreen(clienteUsuario: clienteUsuario),
              ),
            ),
      ),
      MenuOption(
        title: 'Cerrar Sesión',
        icon: Icons.exit_to_app,
        color: Colors.redAccent,
        onTap:
            (context) =>
                cerrarSesion(context), // ← usa el método del controller
      ),
    ];
  }

  // Lógica centralizada de logout
  void cerrarSesion(BuildContext context) {
    NavigationHelper.cerrarSesion(context);
  }
}
