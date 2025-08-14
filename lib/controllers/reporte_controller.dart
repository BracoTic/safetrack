import 'dart:typed_data';
import 'package:hive/hive.dart';
import '../../models/reporte.dart';
import '../../models/pregunta.dart';
import '../../models/opcion_multiple.dart';
import '../../models/evidencia.dart';
import '../../models/clasificacion.dart';
import '../../models/respuesta.dart';
import '../../data/local/dao/reporte_dao.dart';
import '../../data/local/dao/pregunta_dao.dart';
import '../../data/local/dao/opcion_multiple_dao.dart';
import '../../data/local/dao/evidencia_dao.dart';
import '../../data/local/dao/respuesta_dao.dart';
import '../models/tipo_pregunta.dart';
import '/models/reporte_pregunta.dart';
import '/models/cliente_usuario.dart';

class ReporteController {
  final ClienteUsuario clienteUsuario;
  final ReporteDAO reporteDao;
  final PreguntaDAO preguntaDao;
  final OpcionMultipleDAO opcionMultipleDao;
  final EvidenciaDAO evidenciaDao;
  final RespuestaDAO respuestaDao = RespuestaDAO();

  ReporteController({
    required this.clienteUsuario,
    required this.reporteDao,
    required this.preguntaDao,
    required this.opcionMultipleDao,
    required this.evidenciaDao,
  });

  /// 🔹 NUEVO: Cargar preguntas activas (sin crear/vincular reporte).
  Future<List<Pregunta>> cargarPreguntasActivas() async {
    final preguntas = await preguntaDao.getAllActivas();
    preguntas.sort((a, b) => a.numeroOrden.compareTo(b.numeroOrden));
    return preguntas;
  }

  /// Mantengo por compatibilidad (otras pantallas usan reporte_pregunta).
  Future<List<Pregunta>> cargarPreguntas(int idReporte) async {
    final rpBox = await Hive.openBox<ReportePregunta>('reporte_pregunta');
    final pBox = await Hive.openBox<Pregunta>('preguntas');

    final relaciones = rpBox.values.where((rp) => rp.idReporte == idReporte);
    final preguntas = <Pregunta>[];

    for (final rp in relaciones) {
      final p = pBox.get(rp.idPregunta);
      if (p != null) preguntas.add(p);
    }

    preguntas.sort((a, b) => a.numeroOrden.compareTo(b.numeroOrden));
    return preguntas;
  }

  /// Opciones múltiples de una pregunta
  Future<List<OpcionMultiple>> obtenerOpciones(int idPregunta) async {
    return opcionMultipleDao.getByPregunta(idPregunta);
  }

  /// 🔹 AHORA: Crear reporte **sin** vincular preguntas aún.
  Future<Reporte> crearReporte() async {
    final reporte = Reporte(
      idReporte: 0,
      clienteUsuario: clienteUsuario,
      fechaHora: DateTime.now(),
      sincronizado: false,
      solucion: 'Pendiente',
      aprobacion: 'pendiente',
      fechaSubida: null,
    );

    final id = await reporteDao.insert(reporte);
    reporte.idReporte = id;
    await reporte.save();
    return reporte;
  }

  /// 🔹 NUEVO: Vincular las preguntas usadas en el formulario al reporte recién creado.
  Future<void> vincularPreguntasAReporte(
    int idReporte,
    List<Pregunta> preguntas,
  ) async {
    final rpBox = await Hive.openBox<ReportePregunta>('reporte_pregunta');
    for (final p in preguntas) {
      final pid = p.idPregunta;
      if (pid != null) {
        await rpBox.add(ReportePregunta(idReporte: idReporte, idPregunta: pid));
      }
    }
  }

  /// Inserta evidencias (normaliza ruta/bytes).
  Future<void> agregarEvidencias(
    Reporte reporte,
    List<Evidencia> evidencias,
  ) async {
    for (final e in evidencias) {
      final ev = Evidencia(
        reporte: reporte,
        clasificacion: e.clasificacion,
        fechaHora: e.fechaHora,
        imgInseguro: e.imgInseguro,
        imgBytes: e.imgBytes, // bytes (Web) si vienen
        ubicacion: e.ubicacion,
        sincronizado: e.sincronizado,
        idRemoto: e.idRemoto,
      );
      await evidenciaDao.insert(ev);
    }
  }

  /// Crea evidencias para guardar (rutas = móvil/desktop, bytes = Web)
  List<Evidencia> crearEvidencias({
    required Reporte reporte,
    required List<String> imagenesPaths,
    required List<Uint8List?> imagenesBytes,
    required List<String> clasificacionesSeleccionadas,
    required List<Clasificacion> clasificacionesDisponibles,
  }) {
    final n =
        (imagenesPaths.length > imagenesBytes.length)
            ? imagenesPaths.length
            : imagenesBytes.length;

    return List.generate(n, (i) {
      final clasif = clasificacionesDisponibles.firstWhere(
        (c) => c.nombre == clasificacionesSeleccionadas[i],
        orElse: () => clasificacionesDisponibles.first,
      );
      final path = i < imagenesPaths.length ? imagenesPaths[i] : '';
      final bytes = i < imagenesBytes.length ? imagenesBytes[i] : null;

      return Evidencia(
        reporte: reporte,
        clasificacion: clasif,
        fechaHora: DateTime.now(),
        imgInseguro: path,
        imgBytes: bytes,
        ubicacion: null,
        sincronizado: false,
      );
    });
  }

  /// Valida respuestas obligatorias
  bool validarRespuestas(
    List<Pregunta> preguntas,
    Map<int, String> respTexto,
    Map<int, String> respMultiple,
  ) {
    for (final p in preguntas.where((p) => p.obligatoria)) {
      final k = p.idPregunta;
      if (k == null) return false;

      if (p.tipoPregunta == TipoPregunta.string) {
        if (respTexto[k]?.trim().isEmpty ?? true) return false;
      } else if (p.tipoPregunta == TipoPregunta.multiple) {
        if (respMultiple[k] == null) return false;
      }
    }
    return true;
  }

  /// Guarda respuestas; usa el **reporte persistido**
  Future<void> guardarRespuestas({
    required Reporte reporte,
    required List<Pregunta> preguntas,
    required Map<int, String> respuestasTexto,
    required Map<int, String> respuestasMultiples,
  }) async {
    for (final p in preguntas) {
      final idPregunta = p.idPregunta;
      if (idPregunta == null) continue;

      String? valor;
      if (p.tipoPregunta == TipoPregunta.string) {
        valor = respuestasTexto[idPregunta]?.trim();
      } else if (p.tipoPregunta == TipoPregunta.multiple) {
        valor = respuestasMultiples[idPregunta];
      }

      if (valor != null && valor.trim().isNotEmpty) {
        await respuestaDao.insert(
          Respuesta(
            reporte: reporte,
            pregunta: p,
            respuesta: valor,
            sincronizado: false,
          ),
        );
      }
    }
  }
}
