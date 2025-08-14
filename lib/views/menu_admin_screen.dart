// views/menu_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/cliente_usuario.dart';
import '../controllers/menu_admin_controller.dart';
import '../widgets/detalle_usuario_popup.dart';
import '../controllers/usuario_detail_controller.dart';

// 👇 Necesarios para escuchar cambios y recalcular puntajes
import '../models/reporte.dart';
import '../models/ranking.dart';
import '/core/entities/usuario_detalle.dart';

class MenuAdminScreen extends StatelessWidget {
  final ClienteUsuario clienteUsuario;

  const MenuAdminScreen({Key? key, required this.clienteUsuario})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = MenuAdminController(clienteUsuario);
    final options = controller.getMenuOptions();

    // Colores de UI por opción (tu paleta actual del grid)
    const optionColors = <String, Color>{
      'Iniciar Reporte': Color(0xFF4F7BFE),
      'Actualizar mis Datos': Color(0xFF7133FE),
      'Mis Reportes': Color(0xFFF75263),
      'Editar Variables': Color(0xFF52CAF7),
      'Agregar Usuario': Color(0xFF6BD563),
      'Visualizar Ciencia de Datos': Color(0xFFAA8AF1),
      'Cerrar Sesión': Colors.redAccent,
    };

    // Ocultamos "Cerrar Sesión" en el grid (ya está el botón grande abajo)
    final visibleOptions =
        options.where((o) => o.title != 'Cerrar Sesión').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 700;
                    return isMobile
                        ? Column(
                          children: [
                            Image.asset('assets/logo.png', height: 80),
                            const SizedBox(height: 12),
                            Image.asset('assets/cliente.png', height: 80),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/logo.png', height: 100),
                            Image.asset('assets/cliente.png', height: 100),
                          ],
                        );
                  },
                ),
                const SizedBox(height: 20),

                // PANEL INFO USUARIO RESPONSIVO
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF363C53), Color(0xFF0B0C11)],
                    ),
                    border: Border.all(color: const Color(0xFFFF5F00)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;
                      return isMobile
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUsuarioInfo(context),
                              const SizedBox(height: 24),
                              _buildRangoYMedalla(isMobile: true),
                            ],
                          )
                          : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _buildUsuarioInfo(context)),
                              const SizedBox(width: 32),
                              _buildRangoYMedalla(isMobile: false),
                            ],
                          );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // MENU TARJETAS
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 10),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 350,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 2,
                          ),
                      itemCount: visibleOptions.length,
                      itemBuilder: (context, index) {
                        final opt = visibleOptions[index];
                        final color = optionColors[opt.title] ?? opt.color;
                        return _menuCard(
                          opt.title,
                          opt.icon,
                          color,
                          () => opt.onTap(context),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // BOTÓN CERRAR SESIÓN
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => controller.cerrarSesion(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5F00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(47),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'CERRAR SESIÓN',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsuarioInfo(BuildContext context) {
    final usuario = clienteUsuario.usuario;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOLA,',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7D86A7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          usuario.nombre,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Documento: ${usuario.tipoIdentificacion} ${usuario.numeroIdentificacion}',
          style: const TextStyle(color: Color(0xFF7D86A7)),
        ),
        Text(
          'Empresa: ${usuario.empresa}',
          style: const TextStyle(color: Color(0xFF7D86A7)),
        ),
        Text(
          'Cargo: ${usuario.cargo}',
          style: const TextStyle(color: Color(0xFF7D86A7)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              final detalle = await UsuarioDetailController().fetchDetalle(
                usuario,
              ); // ya maneja ranking
              mostrarDetalleUsuarioPopup(context, detalle);
            },
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            label: const Text(
              'VER PERFIL COMPLETO',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5F00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(47),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  /// ────────────────────────────────────────────────────────────────
  /// Puntos en vivo (Mensual / Acumulado) con listeners de Hive
  /// ────────────────────────────────────────────────────────────────
  Widget _buildRangoYMedalla({required bool isMobile}) {
    final reportesStream = Hive.box<Reporte>('reportes').watch();
    final rankingsStream = Hive.box<Ranking>('rankings').watch();

    return StreamBuilder(
      stream: reportesStream,
      builder: (_, __) {
        return StreamBuilder(
          stream: rankingsStream,
          builder: (_, __) {
            final future = UsuarioDetailController().fetchDetalle(
              clienteUsuario.usuario,
            );

            return FutureBuilder<UsuarioDetalle>(
              future: future,
              builder: (context, snapshot) {
                final mensual =
                    snapshot.hasData
                        ? '${snapshot.data!.puntajeMensual} Pts'
                        : '—';
                final anual =
                    snapshot.hasData
                        ? '${snapshot.data!.puntajeAcumulado} Pts'
                        : '—';

                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRangoInfoBox('Mensual:', mensual),
                      const SizedBox(height: 12),
                      _buildRangoInfoBox('Temporada Anual:', anual),
                      const SizedBox(height: 16),
                      const Center(
                        child: Icon(
                          Icons.military_tech,
                          color: Color.fromARGB(255, 255, 81, 0),
                          size: 96,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRangoInfoBox('Mensual:', mensual),
                          const SizedBox(height: 12),
                          _buildRangoInfoBox('Temporada Anual:', anual),
                        ],
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.military_tech,
                        color: Color.fromARGB(255, 255, 81, 0),
                        size: 192,
                      ),
                    ],
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _menuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangoInfoBox(String label, String texto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF7D86A7)),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF24293D),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            texto,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
