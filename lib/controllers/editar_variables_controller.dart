import 'package:hive/hive.dart';
import '../models/pregunta.dart';
import '../models/opcion_multiple.dart';

class EditarVariablesController {
  late final Box<Pregunta> preguntasBox;
  late final Box<OpcionMultiple> opcionesBox;

  EditarVariablesController() {
    preguntasBox = Hive.box<Pregunta>('preguntas');
    opcionesBox = Hive.box<OpcionMultiple>('opcionesMultiple');
  }

  List<Pregunta> getAllPreguntas() => preguntasBox.values.toList();

  List<Pregunta> filtrarPorTipo(bool esMultiple, {bool soloActivas = true}) =>
      preguntasBox.values
          .where(
            (p) =>
                (soloActivas ? p.activa : true) &&
                (esMultiple
                    ? p.tipoPregunta.name == 'multiple'
                    : p.tipoPregunta.name == 'string'),
          )
          .toList();

  List<OpcionMultiple> getOpcionesPara(Pregunta pregunta) =>
      opcionesBox.values
          .where((o) => o.idPregunta == pregunta.idPregunta)
          .toList();
}
