// controllers/menu_admin_controller.dart
import 'package:flutter/material.dart';
import '/models/cliente_usuario.dart';
import '/core/entities/menu_option.dart';
import '/views/modificar_usuario_screen.dart';
import '/views/reporte_instruccion_screen.dart';
import '/views/reportes_historial_screen.dart';
import '/views/editar_variables_screen.dart';
import '/views/formulario_usuario_admin.dart';
import '/views/visualizar_cd_screen.dart';

import '/core/utils/navigation_helper.dart';

class MenuAdminController {
  final ClienteUsuario clienteUsuario;

  MenuAdminController(this.clienteUsuario);

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
        title: 'Editar Variables',
        icon: Icons.settings,
        color: const Color(0xFFA84813),
        onTap:
            (context) => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        EditarVariablesScreen(clienteUsuario: clienteUsuario),
              ),
            ),
      ),
      MenuOption(
        title: 'Agregar Usuario',
        icon: Icons.person_add,
        color: const Color(0xFFA84813),
        onTap:
            (context) => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => FormularioUsuarioAdminScreen(
                      clienteUsuario: clienteUsuario,
                    ),
              ),
            ),
      ),
      MenuOption(
        title: 'Visualizar Ciencia de Datos',
        icon: Icons.bar_chart,
        color: const Color(0xFFCD5D1B),
        onTap:
            (context) => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => VisualizarCienciaDatosScreen(
                      clienteUsuario: clienteUsuario,
                    ),
              ),
            ),
      ),
      MenuOption(
        title: 'Cerrar Sesión',
        icon: Icons.exit_to_app,
        color: Colors.redAccent,
        onTap: (context) => NavigationHelper.cerrarSesion(context),
      ),
    ];
  }

  // 👉 Lógica centralizada para logout
  void cerrarSesion(BuildContext context) {
    NavigationHelper.cerrarSesion(context);
  }
}
