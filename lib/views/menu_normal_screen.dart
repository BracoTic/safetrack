// views/menu_normal_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ⬅️ para .listenable()

import '../models/cliente_usuario.dart';
import '../models/reporte.dart'; // ⬅️ escuchar cambios de reportes
import '../models/ranking.dart'; // ⬅️ escuchar cambios de rankings

import '../controllers/menu_normal_controller.dart';
import '../controllers/usuario_detail_controller.dart';
import '../widgets/detalle_usuario_popup.dart';

class MenuNormalScreen extends StatelessWidget {
  final ClienteUsuario clienteUsuario;

  const MenuNormalScreen({Key? key, required this.clienteUsuario})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = MenuNormalController(clienteUsuario);
    final options = controller.getMenuOptions();

    // Paleta de colores por título
    const optionColors = <String, Color>{
      'Iniciar Reporte': Color(0xFF4F7BFE),
      'Actualizar mis Datos': Color(0xFF7133FE),
      'Mis Reportes': Color(0xFFF75263),
      'Cerrar Sesión': Colors.redAccent,
    };

    // Ocultar "Cerrar Sesión" del grid (queda el botón grande de abajo)
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

                // PANEL INFO USUARIO
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

                // GRID DE OPCIONES
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

  // ====== Widgets privados ======

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
              );
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

  /// Puntos en vivo (Mensual / Acumulado) escuchando Hive
  Widget _buildRangoYMedalla({required bool isMobile}) {
    final reportesListenable = Hive.box<Reporte>('reportes').listenable();
    final rankingsListenable = Hive.box<Ranking>('rankings').listenable();

    return ValueListenableBuilder(
      valueListenable: reportesListenable,
      builder: (_, __, ___) {
        return ValueListenableBuilder(
          valueListenable: rankingsListenable,
          builder: (_, __, ___) {
            return FutureBuilder(
              future: UsuarioDetailController().fetchDetalle(
                clienteUsuario.usuario,
              ),
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
