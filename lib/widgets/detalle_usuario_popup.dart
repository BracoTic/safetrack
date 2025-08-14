import 'package:flutter/material.dart';
import '/core/entities/usuario_detalle.dart';

void mostrarDetalleUsuarioPopup(BuildContext context, UsuarioDetalle detalle) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF1D2136),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFF5F00), width: 1.5),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;
                      return isMobile
                          ? Column(
                            children: [
                              _userInfoSection(detalle),
                              const SizedBox(height: 20),
                              _reportesYRanking(detalle),
                            ],
                          )
                          : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _userInfoSection(detalle),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 7,
                                child: _reportesYRanking(detalle),
                              ),
                            ],
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}

// Las funciones _userInfoSection, _infoLine, _reportesYRanking, _reporteCard y _medallaWidget siguen igual como en el mensaje anterior.

Widget _userInfoSection(UsuarioDetalle detalle) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF363C53), Color(0xFF0B0C11)],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFF5F00)),
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.grey.shade700,
          child: const Icon(Icons.person, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          detalle.usuario.nombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          detalle.usuario.cargo,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 16),
        _infoLine(
          Icons.badge,
          'Documento',
          '${detalle.usuario.tipoIdentificacion} ${detalle.usuario.numeroIdentificacion}',
        ),
        _infoLine(Icons.business, 'Empresa', detalle.usuario.empresa),
        _infoLine(Icons.email, 'Correo', detalle.usuario.correo),
        _infoLine(Icons.phone, 'Teléfono', detalle.usuario.telefono),
      ],
    ),
  );
}

Widget _infoLine(IconData icon, String label, String value) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFFF5F00)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFF5F00)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _reportesYRanking(UsuarioDetalle detalle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Mis Reportes',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _reporteCard('Total de reportes', detalle.totalReportes),
          _reporteCard('Reportes pendientes', detalle.pendientes),
          _reporteCard('Reportes aprobados', detalle.aprobados),
          _reporteCard('Reportes rechazados', detalle.rechazados),
        ],
      ),
      const SizedBox(height: 32),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _medallaWidget(
            titulo: 'Mensual:',
            medalla: detalle.medallaMensual,
            puntos: detalle.puntajeMensual,
          ),
          const SizedBox(width: 32),
          _medallaWidget(
            titulo: 'Temporada Anual:',
            medalla: detalle.medallaAcumulada,
            puntos: detalle.puntajeAcumulado,
          ),
        ],
      ),
    ],
  );
}

Widget _reporteCard(String label, int cantidad) {
  return Container(
    width: 250,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFFF5F00)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.menu, color: Color(0xFFFF5F00), size: 24),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        Text(
          cantidad.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _medallaWidget({
  required String titulo,
  required String medalla,
  required int puntos,
}) {
  return Column(
    children: [
      Text(titulo, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 4),
      Text(
        medalla,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      const Icon(Icons.military_tech, color: Color(0xFFFF5F00), size: 32),
      const SizedBox(height: 4),
      Text('$puntos Pts', style: const TextStyle(color: Colors.white70)),
    ],
  );
}
