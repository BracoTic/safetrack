import '../models/reporte.dart';
import '../models/pregunta.dart';
import '../data/local/dao/reporte_dao.dart';
import '../data/local/dao/pregunta_dao.dart';

class VisualizarCdScreenController {
  final ReporteDAO _reporteDAO = ReporteDAO();
  final PreguntaDAO _preguntaDAO = PreguntaDAO();

  Future<Map<Reporte, List<Pregunta>>> obtenerReportesConPreguntas() async {
    final reporteList = await _reporteDAO.getAll();
    final Map<Reporte, List<Pregunta>> resultado = {};

    for (final reporte in reporteList) {
      final preguntas = await _preguntaDAO.getByReporte(reporte.idReporte);
      resultado[reporte] = preguntas;
    }

    return resultado;
  }
}
