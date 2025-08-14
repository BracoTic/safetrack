import 'package:hive/hive.dart';
import '/models/reporte.dart';
import '/models/ranking.dart';
import '/models/cliente_usuario.dart';
import '/core/entities/usuario_detalle.dart';

class RankingService {
  final Box<Reporte> _reportesBox;
  final Box<Ranking> _rankingsBox;

  RankingService._(this._reportesBox, this._rankingsBox);

  static Future<RankingService> create() async {
    final reportes = await Hive.openBox<Reporte>('reportes');
    final rankings = await Hive.openBox<Ranking>('rankings');
    return RankingService._(reportes, rankings);
  }

  String currentPeriod([DateTime? when]) {
    final d = when ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  // Regla de puntos (cámbiala aquí y TODO se actualiza):
  // +10 por aprobado, -8 por rechazado, 0 por pendiente u otros
  int _pointsFor(Reporte r) {
    final s = r.aprobacion.toLowerCase();
    if (s == 'aprobado') return 10;
    if (s == 'rechazado') return -8;
    return 0;
  }

  bool _isSamePeriod(DateTime dt, String periodo) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    return '$y-$m' == periodo;
  }

  Iterable<Reporte> _reportsOf(ClienteUsuario cu) {
    final doc = cu.usuario.numeroIdentificacion;
    final cli = cu.cliente.nombre;
    return _reportesBox.values.where(
      (r) =>
          r.clienteUsuario.usuario.numeroIdentificacion == doc &&
          r.clienteUsuario.cliente.nombre == cli,
    );
  }

  Future<int> computeMonthlyPoints(ClienteUsuario cu, String periodo) async {
    final reports = _reportsOf(
      cu,
    ).where((r) => _isSamePeriod(r.fechaHora, periodo));
    var total = 0;
    for (final r in reports) {
      total += _pointsFor(r);
    }
    return total;
  }

  Future<int> computeAccumulatedPoints(ClienteUsuario cu) async {
    final reports = _reportsOf(cu);
    var total = 0;
    for (final r in reports) {
      total += _pointsFor(r);
    }
    return total;
  }

  String badgeForPoints(int pts) {
    // Ajusta umbrales a tu gusto
    if (pts >= 100) return 'Oro';
    if (pts >= 50) return 'Plata';
    if (pts >= 20) return 'Bronce';
    return 'Sin medalla';
  }

  Future<Ranking> upsertMonthlyRanking(
    ClienteUsuario cu,
    String periodo,
  ) async {
    final pts = await computeMonthlyPoints(cu, periodo);

    Ranking? existing = _rankingsBox.values.firstWhere(
      (rk) =>
          rk.usuario.usuario.numeroIdentificacion ==
              cu.usuario.numeroIdentificacion &&
          rk.cliente.nombre == cu.cliente.nombre &&
          rk.periodo == periodo,
    );

    final medalla = badgeForPoints(pts);

    if (existing != null) {
      existing.puntuacion = pts;
      existing.medalla = medalla;
      existing.sincronizado = false;
      await existing.save();
      return existing;
    } else {
      final rk = Ranking(
        cliente: cu.cliente,
        usuario: cu,
        periodo: periodo,
        puntuacion: pts,
        medalla: medalla,
      );
      await _rankingsBox.add(rk);
      return rk;
    }
  }

  Future<UsuarioDetalle> buildUsuarioDetalle(ClienteUsuario cu) async {
    // Conteos por estado (histórico completo)
    final all = _reportsOf(cu).toList();
    final total = all.length;
    final aprobados =
        all.where((r) => r.aprobacion.toLowerCase() == 'aprobado').length;
    final rechazados =
        all.where((r) => r.aprobacion.toLowerCase() == 'rechazado').length;
    final pendientes =
        all.where((r) => r.aprobacion.toLowerCase() == 'pendiente').length;

    // Mensual: recalcula y persiste (para reflejar siempre la regla actual)
    final periodo = currentPeriod();
    final mensual = await upsertMonthlyRanking(cu, periodo);

    // Acumulado: se calcula sobre TODO el histórico (no persiste en Ranking)
    final ptsAcumulado = await computeAccumulatedPoints(cu);
    final medallaAcumulada = badgeForPoints(ptsAcumulado);

    return UsuarioDetalle(
      usuario: cu.usuario,
      totalReportes: total,
      pendientes: pendientes,
      aprobados: aprobados,
      rechazados: rechazados,
      medallaMensual: mensual.medalla,
      puntajeMensual: mensual.puntuacion,
      medallaAcumulada: medallaAcumulada,
      puntajeAcumulado: ptsAcumulado,
    );
  }

  /// Llama esto cada vez que cambies `aprobacion` de un reporte para refrescar ranking mensual.
  Future<void> refreshAfterReportChange(Reporte reporte) async {
    final cu = reporte.clienteUsuario;
    final periodo = currentPeriod(reporte.fechaHora);
    await upsertMonthlyRanking(cu, periodo);
  }
}
