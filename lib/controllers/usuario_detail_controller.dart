import 'package:hive/hive.dart';
import '../models/usuario.dart';
import '../models/cliente_usuario.dart';
import '../models/reporte.dart';
import '/core/entities/usuario_detalle.dart';
import '/core/utils/ranking_service.dart';

class UsuarioDetailController {
  /// Mantiene la misma firma usada por tus menús.
  Future<UsuarioDetalle> fetchDetalle(Usuario usuario) async {
    final cu = await _resolveClienteUsuario(usuario);

    // Si encontramos ClienteUsuario -> delegamos al RankingService (fuente de verdad).
    if (cu != null) {
      final service = await RankingService.create();
      return service.buildUsuarioDetalle(cu);
    }

    // Fallback: no hay ClienteUsuario (caso raro). Calculamos directo para no romper el flujo.
    final repBox = await Hive.openBox<Reporte>('reportes');
    final reports = repBox.values.where(
      (r) =>
          r.clienteUsuario.usuario.numeroIdentificacion ==
          usuario.numeroIdentificacion,
    );

    final total = reports.length;
    final aprobados =
        reports.where((r) => r.aprobacion.toLowerCase() == 'aprobado').length;
    final rechazados =
        reports.where((r) => r.aprobacion.toLowerCase() == 'rechazado').length;
    final pendientes =
        reports.where((r) => r.aprobacion.toLowerCase() == 'pendiente').length;

    int _pointsFor(Reporte r) {
      final s = r.aprobacion.toLowerCase();
      if (s == 'aprobado') return 10;
      if (s == 'rechazado') return -8;
      return 0;
    }

    String _period(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}';
    final currentPeriod = _period(DateTime.now());

    final ptsMensual = reports
        .where((r) => _period(r.fechaHora) == currentPeriod)
        .fold<int>(0, (acc, r) => acc + _pointsFor(r));
    final ptsAcumulado = reports.fold<int>(0, (acc, r) => acc + _pointsFor(r));

    String _badge(int pts) {
      if (pts >= 100) return 'Oro';
      if (pts >= 50) return 'Plata';
      if (pts >= 20) return 'Bronce';
      return 'Sin medalla';
    }

    return UsuarioDetalle(
      usuario: usuario,
      totalReportes: total,
      pendientes: pendientes,
      aprobados: aprobados,
      rechazados: rechazados,
      medallaMensual: _badge(ptsMensual),
      puntajeMensual: ptsMensual,
      medallaAcumulada: _badge(ptsAcumulado),
      puntajeAcumulado: ptsAcumulado,
    );
  }

  /// Intenta resolver el ClienteUsuario a partir de Hive sin cambiar la firma pública.
  Future<ClienteUsuario?> _resolveClienteUsuario(Usuario usuario) async {
    final cuBox = await Hive.openBox<ClienteUsuario>('cliente_usuarios');

    ClienteUsuario? found;
    for (final cu in cuBox.values) {
      if (cu.usuario.numeroIdentificacion == usuario.numeroIdentificacion) {
        found = cu;
        break;
      }
    }
    if (found != null) return found;

    // Fallback: tomar el ClienteUsuario desde cualquier reporte del usuario.
    final repBox = await Hive.openBox<Reporte>('reportes');
    for (final r in repBox.values) {
      if (r.clienteUsuario.usuario.numeroIdentificacion ==
          usuario.numeroIdentificacion) {
        return r.clienteUsuario;
      }
    }
    return null;
  }
}
