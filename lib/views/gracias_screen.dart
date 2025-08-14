import 'package:flutter/material.dart';
import '../models/cliente_usuario.dart';
import '../core/utils/navigation_helper.dart';

class GraciasScreen extends StatelessWidget {
  final ClienteUsuario clienteUsuario;

  const GraciasScreen({super.key, required this.clienteUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Logos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LayoutBuilder(
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
            ),
            const SizedBox(height: 8),

            // Contenido enmarcado con degradado y borde
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFF5F00),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF363C53), Color(0xFF0B0C11)],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFFFF5F00),
                        size: 120,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        '¡Gracias por tu observación!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Tus datos han sido registrados exitosamente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed:
                            () => NavigationHelper.volverAlMenu(
                              context,
                              clienteUsuario,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5F00),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Text(
                          'Volver',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
