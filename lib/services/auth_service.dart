import '../models/Sesion.dart';
import '../models/Usuario.dart';

abstract class AuthService {

  Future<bool> login(
      String nombre,
      String password,
      );

  Future<void> logout();

  Future<bool> haySesionActiva();

  Future<SesionUsuario?> obtenerSesion();

  Future<bool> validarSesion();

  Future<Usuario?> usuarioActual();
}