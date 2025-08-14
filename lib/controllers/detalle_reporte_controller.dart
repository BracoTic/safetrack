import 'package:hive/hive.dart';
import '../../models/evidencia.dart';
import '../../models/clasificacion.dart';
import '../../models/pregunta.dart';
import '../../models/tipo_pregunta.dart';
import '../../models/reporte_pregunta.dart';
import '../../models/respuesta.dart';

class DetalleReporteController {
  final Box<Evidencia> _evidenciasBox;
  final Box<Clasificacion> _clasificacionesBox;
  final Box<Pregunta> _preguntasBox;
  final Box<ReportePregunta> _reportePreguntaBox;
  final Box<Respuesta> _respuestasBox;

  DetalleReporteController()
    : _evidenciasBox = Hive.box<Evidencia>('evidencias'),
      _clasificacionesBox = Hive.box<Clasificacion>('clasificaciones'),
      _preguntasBox = Hive.box<Pregunta>('preguntas'),
      _reportePreguntaBox = Hive.box<ReportePregunta>('reporte_pregunta'),
      _respuestasBox = Hive.box<Respuesta>('respuestas');

  List<Evidencia> obtenerEvidenciasPorReporte(int idReporte) {
    return _evidenciasBox.values
        .where((e) => e.reporte.key == idReporte)
        .toList();
  }

  Clasificacion? obtenerClasificacion(int idClasificacion) {
    return _clasificacionesBox.get(idClasificacion);
  }

  List<Pregunta> obtenerPreguntasPorReporte(int idReporte) {
    final relaciones =
        _reportePreguntaBox.values
            .where((rp) => rp.idReporte == idReporte)
            .toList();

    return relaciones
        .map((rp) => _preguntasBox.get(rp.idPregunta))
        .whereType<Pregunta>()
        .toList();
  }

  List<Pregunta> obtenerPreguntasAbiertas(List<Pregunta> preguntas) {
    return preguntas
        .where((p) => p.tipoPregunta == TipoPregunta.string)
        .toList();
  }

  List<Pregunta> obtenerPreguntasMultiples(List<Pregunta> preguntas) {
    return preguntas
        .where((p) => p.tipoPregunta == TipoPregunta.multiple)
        .toList();
  }

  /// ✅ CORREGIDO: Usamos `idPregunta` en lugar de `pregunta.key`
  Map<int, String> obtenerRespuestasPorReporte(int idReporte) {
    final respuestasReporte =
        _respuestasBox.values.where((r) => r.reporte.key == idReporte).toList();

    final Map<int, String> respuestasMap = {};

    for (var respuesta in respuestasReporte) {
      final idPregunta = respuesta.pregunta.idPregunta;
      respuestasMap[idPregunta] = respuesta.respuesta;
    }

    return respuestasMap;
  }
}
