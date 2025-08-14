import 'package:hive/hive.dart';

part 'tipo_pregunta.g.dart';

@HiveType(typeId: 11)
enum TipoPregunta {
  @HiveField(0)
  string,

  @HiveField(1)
  multiple,
}
