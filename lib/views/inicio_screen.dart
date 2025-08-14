import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          final backgroundWidth = screenWidth * (1714 / 1920);
          final backgroundHeight = screenHeight * (1732 / 1366);
          final backgroundDx = screenWidth * (724 / 1920);
          final backgroundDy = screenHeight * (-234.99 / 1366);

          final rectLeft = screenWidth * (102 / 1920);
          final rectTop = screenHeight * (117 / 1366);
          final rectWidth = screenWidth * (1716 / 1920);
          final rectHeight = screenHeight * (1132 / 1366);

          return Stack(
            children: [
              // Fondo degradado
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF22273A), Color(0xFF191C25)],
                    transform: GradientRotation(130 * 3.1416 / 180),
                  ),
                ),
                child: SizedBox.expand(),
              ),

              // Imagen de fondo (Grupo 2)
              ClipRect(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Transform.translate(
                    offset: Offset(backgroundDx, backgroundDy),
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.asset(
                        'assets/Grupo 2.png',
                        width: backgroundWidth,
                        height: backgroundHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Rectángulo externo (relleno, sombra y borde)
              Positioned(
                left: rectLeft,
                top: rectTop,
                width: rectWidth,
                height: rectHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                      20,
                      117,
                      117,
                      117,
                    ), // 87 es hexadecimal 0x57
                    borderRadius: BorderRadius.circular(90),
                    border: Border.all(
                      color: const Color(0xFFFF5F00),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(44, 16, 0, 0.012),
                        offset: Offset(20, 20),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido central
              Center(
                child: Container(
                  width: 480,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 48,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D29),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFF5F00),
                      width: 1.8,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icono.png',
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/texto.png',
                        width: 260,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5F00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(47),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'INICIAR SESIÓN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Versión Alfa Beta Vr:01',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
