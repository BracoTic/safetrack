import 'package:hive/hive.dart';

part 'reporte_pregunta.g.dart';

@HiveType(typeId: 12)
class ReportePregunta extends HiveObject {
  @HiveField(0)
  int idReporte;

  @HiveField(1)
  int idPregunta;

  ReportePregunta({required this.idReporte, required this.idPregunta});
}
