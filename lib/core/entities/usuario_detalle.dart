import '/models/usuario.dart';

class UsuarioDetalle {
  final Usuario usuario;
  final int puntajeMensual;
  final String medallaMensual;
  final int puntajeAcumulado;
  final String medallaAcumulada;
  final int totalReportes;
  final int aprobados;
  final int pendientes;
  final int rechazados;

  UsuarioDetalle({
    required this.usuario,
    required this.puntajeMensual,
    required this.medallaMensual,
    required this.puntajeAcumulado,
    required this.medallaAcumulada,
    required this.totalReportes,
    required this.aprobados,
    required this.pendientes,
    required this.rechazados,
  });
}
