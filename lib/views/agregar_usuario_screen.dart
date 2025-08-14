import 'package:flutter/material.dart';
import '../models/cliente_usuario.dart';

class AgregarUsuarioScreen extends StatelessWidget {
  final ClienteUsuario clienteUsuario;

  const AgregarUsuarioScreen({super.key, required this.clienteUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFCCB2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFFF5F00),
                      ),
                      label: const Text(
                        'VOLVER AL MENÚ',
                        style: TextStyle(
                          color: Color(0xFFFF5F00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Agregar Usuario',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCD5D1B),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Pantalla para agregar un nuevo usuario',
                      style: TextStyle(fontSize: 18, color: Color(0xFFCD5D1B)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón Agregar Usuario
                  ElevatedButton.icon(
                    onPressed: () {
                      // Acción para agregar usuario
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCD5D1B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text(
                      'Agregar Usuario',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Botón Cancelar
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Color(0xFFCD5D1B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
