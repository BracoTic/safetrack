import '/models/usuario.dart';
import '/models/rol.dart';

enum LoginStatus { success, invalidCredentials, noRelation }

class LoginResponse {
  final LoginStatus status;
  final Usuario? usuario;
  final Rol? rol;
  final String? message;

  LoginResponse({required this.status, this.usuario, this.rol, this.message});

  bool get isSuccess => status == LoginStatus.success;
}
