import 'package:flutter/material.dart';
import 'dart:io';

import '../models/cliente_usuario.dart';
import '../models/pregunta.dart';
import '../models/opcion_multiple.dart';
import '../controllers/editar_variables_controller.dart';
import '../views/editar_pregunta_screen.dart';
import '../views/agregar_pregunta_screen.dart';
import '../core/utils/navigation_helper.dart';

// 👇 flecha naranja reutilizable
import '/core/ui/app_chrome.dart';

class EditarVariablesScreen extends StatelessWidget {
  final ClienteUsuario clienteUsuario;
  final EditarVariablesController controller = EditarVariablesController();

  EditarVariablesScreen({super.key, required this.clienteUsuario});

  @override
  Widget build(BuildContext context) {
    final preguntasAbiertas = controller.filtrarPorTipo(false);
    final preguntasMultiples = controller.filtrarPorTipo(true);

    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: Stack(
        children: [
          // Fondo con degradado
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
                  const Text(
                    'Editar Preguntas',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCD5D1B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Preguntas Abiertas:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCD5D1B),
                    ),
                  ),
                  const Divider(color: Color(0xFFCD5D1B)),
                  Expanded(
                    child: ListView(
                      children: [
                        ...preguntasAbiertas.map((p) => _buildCard(context, p)),
                        const SizedBox(height: 20),
                        const Text(
                          'Preguntas de Selección Múltiple:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCD5D1B),
                          ),
                        ),
                        const Divider(color: Color(0xFFCD5D1B)),
                        ...preguntasMultiples.map(
                          (p) => _buildCard(context, p),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ← Flecha naranja reutilizable (misma acción que antes)
          AppBackButton(
            onTap: () => NavigationHelper.volverAlMenu(context, clienteUsuario),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF5F00),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Pregunta',
          style: TextStyle(color: Colors.white),
        ),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        AgregarPreguntaScreen(clienteUsuario: clienteUsuario),
              ),
            ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Pregunta pregunta) {
    final opciones = controller.getOpcionesPara(pregunta);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1E2231),
      child: ListTile(
        title: Text(
          pregunta.referencia ?? 'Sin Referencia',
          style: const TextStyle(
            color: Color(0xFFCD5D1B),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          pregunta.texto,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () => _mostrarDetalle(context, pregunta, opciones),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFCD5D1B)),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EditarPreguntaScreen(
                        pregunta: pregunta,
                        clienteUsuario: clienteUsuario,
                      ),
                ),
              ),
        ),
      ),
    );
  }

  void _mostrarDetalle(
    BuildContext context,
    Pregunta p,
    List<OpcionMultiple> opciones,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Detalle de la Pregunta'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.referencia ?? 'Sin Referencia',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCD5D1B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Orden: ${p.numeroOrden > 0 ? p.numeroOrden : 'No aplica'}',
                  ),
                  const SizedBox(height: 10),
                  Text(p.texto),
                  const SizedBox(height: 10),
                  Text('Tipo: ${p.tipoPregunta.name.toUpperCase()}'),
                  Text('Obligatoria: ${p.obligatoria ? "Sí" : "No"}'),
                  const SizedBox(height: 10),
                  if (p.imagenApoyo != null && p.imagenApoyo!.isNotEmpty)
                    Image.file(File(p.imagenApoyo!), height: 120),
                  if (opciones.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Opciones:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...opciones.map((o) => Text('- ${o.textoOpcion}')),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}
