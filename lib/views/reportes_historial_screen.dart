import 'package:flutter/material.dart';
import '../models/cliente_usuario.dart';
import '../models/reporte.dart';
import '../controllers/reportes_historial_controller.dart';
import '../core/utils/navigation_helper.dart';
import 'detalle_reporte_screen.dart';

// 👇 flecha naranja reutilizable
import '/core/ui/app_chrome.dart';

class ReportesHistorialScreen extends StatelessWidget {
  final ClienteUsuario clienteUsuario;

  const ReportesHistorialScreen({super.key, required this.clienteUsuario});

  @override
  Widget build(BuildContext context) {
    final controller = ReportesHistorialController();

    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF24293D), Color(0xFF0B0C11)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Reporte>>(
                future: controller.obtenerReportesPorClienteUsuario(
                  clienteUsuario,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tienes reportes registrados.',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    );
                  }

                  final reportes = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Reportes Historial',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: reportes.length,
                          itemBuilder: (context, index) {
                            final reporte = reportes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Card(
                                color: const Color(0xFF24293D),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFFFF5F00),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12.0),
                                  title: Text(
                                    'Reporte del ${reporte.fechaHora.toLocal().toString().split(".")[0]}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Estado: ${reporte.aprobacion}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFFFF5F00),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => DetalleReporteScreen(
                                              clienteUsuario: clienteUsuario,
                                              reporte: reporte,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ← Flecha naranja reutilizable (misma acción que antes)
          AppBackButton(
            onTap: () => NavigationHelper.volverAlMenu(context, clienteUsuario),
          ),
        ],
      ),
    );
  }
}
