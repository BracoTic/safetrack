import 'package:hive/hive.dart';

part 'rol.g.dart';

@HiveType(typeId: 2)
enum Rol {
  @HiveField(0)
  normal,

  @HiveField(1)
  especial,

  @HiveField(2)
  admin,
}
