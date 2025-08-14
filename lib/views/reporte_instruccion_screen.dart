import 'package:flutter/material.dart';
import '../models/cliente_usuario.dart';
import '../controllers/reporte_instruccion_controller.dart';
import '../core/utils/navigation_helper.dart';

class ReporteInstruccionScreen extends StatelessWidget {
  final ClienteUsuario clienteUsuario;

  const ReporteInstruccionScreen({Key? key, required this.clienteUsuario})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  onPressed: () {
                    NavigationHelper.volverAlMenu(context, clienteUsuario);
                  },
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFFF5F00)),
                  label: const Text(
                    'VOLVER AL MENÚ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5F00),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFF5F00),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'INICIAR REPORTE',
                      style: TextStyle(
                        color: Color(0xFF7D86A7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Instrucciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna',
                      style: TextStyle(color: Color(0xFF7D86A7), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    isMobile
                        ? Column(children: _buildPasosList(isMobile))
                        : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: _buildPasosList(isMobile)),
                        ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ReporteInstruccionController.iniciarReporte(
                            context,
                            clienteUsuario,
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'INICIAR REPORTE',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5F00),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPasosList(bool isMobile) {
    final pasos = [
      [
        '01',
        'PIENSA',
        [Color(0xFF283E7F), Color(0xFF1E2231)],
      ],
      [
        '02',
        'PARA',
        [Color(0xFFF75263), Color(0xFF7C2932)],
      ],
      [
        '03',
        'OBSERVA',
        [Color(0xFF7133FE), Color(0xFF391A7F)],
      ],
      [
        '04',
        'ACTÚA',
        [Color(0xFF52CAF7), Color(0xFF29657C)],
      ],
      [
        '05',
        'REPORTA',
        [Color(0xFF6BD563), Color(0xFF366B32)],
      ],
    ];

    final spacing =
        isMobile ? const SizedBox(height: 16) : const SizedBox(width: 12);
    final widgets = <Widget>[];

    for (var i = 0; i < pasos.length; i++) {
      widgets.add(
        _buildPaso(
          pasos[i][0] as String,
          pasos[i][1] as String,
          pasos[i][2] as List<Color>,
        ),
      );
      if (i < pasos.length - 1) widgets.add(spacing);
    }

    return widgets;
  }

  Widget _buildPaso(String numero, String titulo, List<Color> colores) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colores,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Center(
            child: Image.asset('assets/icono.png', width: 64, height: 64),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          numero,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
