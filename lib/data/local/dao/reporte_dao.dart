import 'package:hive/hive.dart';
import '../../../models/reporte.dart';
import '../../../models/reporte_pregunta.dart';
import '../../../models/cliente_usuario.dart';

class ReporteDAO {
  Future<Box<Reporte>> get _box async {
    if (!Hive.isBoxOpen('reportes')) {
      await Hive.openBox<Reporte>('reportes');
    }
    return Hive.box<Reporte>('reportes');
  }

  /// Obtener todos los reportes sin filtrar
  Future<List<Reporte>> getAll() async => (await _box).values.toList();

  /// Insertar un nuevo reporte
  Future<int> insert(Reporte reporte) async {
    return await (await _box).add(reporte);
  }

  /// Obtener un reporte por su key
  Future<Reporte?> getById(int key) async {
    return (await _box).get(key);
  }

  /// Actualizar un reporte existente
  Future<void> update(int key, Reporte reporte) async {
    await (await _box).put(key, reporte);
  }

  /// Eliminar un reporte por su key
  Future<void> delete(int key) async {
    await (await _box).delete(key);
  }

  /// 🔴 Obsoleto: no usar para producción si un usuario pertenece a varios clientes
  /// Mejor usar getByClienteUsuario()
  @deprecated
  Future<List<Reporte>> getByUsuario(String numeroIdentificacion) async {
    return (await _box).values
        .where(
          (r) =>
              r.clienteUsuario.usuario.numeroIdentificacion ==
              numeroIdentificacion,
        )
        .toList();
  }

  /// Obtener todos los reportes que aún no han sido sincronizados
  Future<List<Reporte>> getNoSincronizados() async {
    return (await _box).values.where((r) => !r.sincronizado).toList();
  }

  /// Obtener todos los reportes que tienen una pregunta específica
  Future<List<Reporte>> getByPregunta(int idPregunta) async {
    final reportePreguntaBox = await Hive.openBox<ReportePregunta>(
      'reporte_pregunta',
    );
    final reporteBox = await _box;

    return reportePreguntaBox.values
        .where((rp) => rp.idPregunta == idPregunta)
        .map((rp) => reporteBox.get(rp.idReporte))
        .whereType<Reporte>()
        .toList();
  }

  /// ✅ Nuevo: obtener reportes filtrados por ClienteUsuario (cliente + usuario)
  Future<List<Reporte>> getByClienteUsuario(
    ClienteUsuario clienteUsuario,
  ) async {
    return (await _box).values
        .where((r) => r.clienteUsuario.key == clienteUsuario.key)
        .toList()
      ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
  }
}
