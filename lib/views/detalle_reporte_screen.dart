import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:safetrack/core/utils/navigation_helper.dart';
import '../models/reporte.dart';
import '../models/cliente_usuario.dart';
import '../controllers/detalle_reporte_controller.dart';
// 👇 flecha naranja reutilizable
import '/core/ui/app_chrome.dart';

class DetalleReporteScreen extends StatelessWidget {
  final Reporte reporte;
  final ClienteUsuario clienteUsuario;

  const DetalleReporteScreen({
    super.key,
    required this.reporte,
    required this.clienteUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final controller = DetalleReporteController();

    // Obtener datos sincronizados
    final evidencias = controller.obtenerEvidenciasPorReporte(
      reporte.key as int,
    );
    final preguntas = controller.obtenerPreguntasPorReporte(reporte.key as int);
    final preguntasAbiertas = controller.obtenerPreguntasAbiertas(preguntas);
    final preguntasMultiples = controller.obtenerPreguntasMultiples(preguntas);

    // Respuestas por pregunta
    final Map<int, String> respuestas = controller.obtenerRespuestasPorReporte(
      reporte.key as int,
    );

    // —— Helpers para evidencias (bytes/file) ——
    bool hasBytes(e) => (e.imgBytes != null && e.imgBytes!.isNotEmpty);
    bool hasPath(e) => (e.imgInseguro != null && e.imgInseguro!.isNotEmpty);

    Widget thumbFor(e) {
      if (hasBytes(e)) {
        return Image.memory(e.imgBytes!, height: 200, fit: BoxFit.cover);
      }
      if (!kIsWeb && hasPath(e)) {
        return Image.file(File(e.imgInseguro!), height: 200, fit: BoxFit.cover);
      }
      return const SizedBox(
        height: 200,
        child: Center(
          child: Icon(Icons.image_not_supported, color: Colors.white54),
        ),
      );
    }

    Widget previewFor(e) {
      if (hasBytes(e)) {
        return Image.memory(e.imgBytes!, fit: BoxFit.contain);
      }
      if (!kIsWeb && hasPath(e)) {
        return Image.file(File(e.imgInseguro!), fit: BoxFit.contain);
      }
      return const SizedBox(
        width: 480,
        height: 360,
        child: Center(
          child: Text(
            'Vista previa no disponible',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    void openPreview(BuildContext ctx, e) {
      showDialog(
        context: ctx,
        builder:
            (_) => Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 1,
                      maxScale: 5,
                      child: previewFor(e),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFFF5F00)),
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
      );
    }

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
              child: ListView(
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
                  const Text(
                    'Detalle del Reporte',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFFFF5F00),
                        width: 1,
                      ),
                    ),
                    color: const Color(0xFF24293D),
                    child: ListTile(
                      title: const Text(
                        'Fecha:',
                        style: TextStyle(color: Color(0xFFFF5F00)),
                      ),
                      subtitle: Text(
                        reporte.fechaHora.toLocal().toString().split('.')[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Respuestas Abiertas:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5F00),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...preguntasAbiertas.map(
                    (p) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFFF5F00),
                          width: 1,
                        ),
                      ),
                      color: const Color(0xFF24293D),
                      child: ListTile(
                        title: Text(
                          p.texto,
                          style: const TextStyle(color: Color(0xFFFF5F00)),
                        ),
                        subtitle: Text(
                          (respuestas[p.idPregunta]?.trim().isNotEmpty ?? false)
                              ? respuestas[p.idPregunta]!
                              : 'No respondida',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Respuestas de Opción Múltiple:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5F00),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...preguntasMultiples.map(
                    (p) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFFF5F00),
                          width: 1,
                        ),
                      ),
                      color: const Color(0xFF24293D),
                      child: ListTile(
                        title: Text(
                          p.texto,
                          style: const TextStyle(color: Color(0xFFFF5F00)),
                        ),
                        subtitle: Text(
                          (respuestas[p.idPregunta]?.trim().isNotEmpty ?? false)
                              ? respuestas[p.idPregunta]!
                              : 'No respondida',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Evidencias:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5F00),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...evidencias.map((ev) {
                    final clasificacion = controller.obtenerClasificacion(
                      ev.idClasificacion,
                    );
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFFF5F00),
                          width: 1,
                        ),
                      ),
                      color: const Color(0xFF24293D),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clasificación: ${clasificacion?.nombre ?? "Sin Clasificación"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF5F00),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha: ${ev.fechaHora.toLocal().toString().split('.')[0]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            if (ev.ubicacion != null &&
                                ev.ubicacion!.isNotEmpty)
                              Text(
                                'Ubicación: ${ev.ubicacion}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            const SizedBox(height: 8),

                            // 🔥 AHORA SÍ: imagen en Web (bytes) o móvil/desktop (file)
                            GestureDetector(
                              onTap: () => openPreview(context, ev),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  color: const Color(0xFF1B1F2D),
                                  child: thumbFor(ev),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ← Flecha naranja reutilizable
          AppBackButton(
            onTap:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => NavigationHelper.buildReporteHistorial(
                          clienteUsuario,
                        ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
