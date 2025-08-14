import 'package:hive/hive.dart';
import '../../models/reporte.dart';
import '../../models/cliente_usuario.dart';

class ReportesHistorialController {
  final Box<Reporte> _reporteBox;

  ReportesHistorialController() : _reporteBox = Hive.box<Reporte>('reportes');

  /// Obtiene todos los reportes asociados al ClienteUsuario específico.
  Future<List<Reporte>> obtenerReportesPorClienteUsuario(
    ClienteUsuario clienteUsuario,
  ) async {
    final todos = _reporteBox.values.toList();

    final reportesClienteUsuario =
        todos
            .where(
              (reporte) => reporte.clienteUsuario.key == clienteUsuario.key,
            )
            .toList()
          ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    return reportesClienteUsuario;
  }

  /// (Opcional) Obtener solo los reportes sincronizados de un ClienteUsuario
  Future<List<Reporte>> obtenerReportesSincronizados(
    ClienteUsuario clienteUsuario,
  ) async {
    final sincronizados =
        _reporteBox.values
            .where(
              (reporte) =>
                  reporte.clienteUsuario.key == clienteUsuario.key &&
                  reporte.sincronizado == true,
            )
            .toList()
          ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    return sincronizados;
  }

  /// (Opcional) Obtener solo los reportes pendientes de sincronizar
  Future<List<Reporte>> obtenerReportesPendientes(
    ClienteUsuario clienteUsuario,
  ) async {
    final pendientes =
        _reporteBox.values
            .where(
              (reporte) =>
                  reporte.clienteUsuario.key == clienteUsuario.key &&
                  reporte.sincronizado == false,
            )
            .toList()
          ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    return pendientes;
  }
}
