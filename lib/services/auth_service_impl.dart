import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/Sesion.dart';
import '../models/Usuario.dart';
import '../repositories/usuario_repository.dart';
import 'auth_service.dart';
import 'firebase_service.dart';

class AuthServiceImpl implements AuthService {

  static const String sessionKey =
      'user_session';

  static const String loginDateKey =
      'last_login_validation';

  final FirebaseService firebaseService;

  final UsuarioRepository usuarioRepository;

  AuthServiceImpl({
    required this.firebaseService,
    required this.usuarioRepository,
  });

  @override
  Future<bool> login(
      String nombre,
      String password,
      ) async {

    final usuario =
    await firebaseService.login(
      nombre,
      password,
    );

    if (usuario == null) {
      return false;
    }

    final existente =
    await usuarioRepository.getByNombre(
      usuario.nombre,
    );

    if (existente == null) {

      await usuarioRepository.insert(
        usuario,
      );
    }

    final sesion = SesionUsuario(
      usuarioId: usuario.id ?? 0,
      nombre: usuario.nombre,
      rol: usuario.rol,
    );

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      sessionKey,
      jsonEncode(
        sesion.toMap(),
      ),
    );

    await prefs.setString(
      loginDateKey,
      DateTime.now().toIso8601String(),
    );

    return true;
  }

  @override
  Future<void> logout() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(sessionKey);

    await prefs.remove(loginDateKey);
  }

  @override
  Future<bool> haySesionActiva() async {

    final prefs =
    await SharedPreferences.getInstance();

    return prefs.containsKey(
      sessionKey,
    );
  }

  @override
  Future<SesionUsuario?> obtenerSesion() async {

    final prefs =
    await SharedPreferences.getInstance();

    final json =
    prefs.getString(
      sessionKey,
    );

    if (json == null) {
      return null;
    }

    return SesionUsuario.fromMap(
      jsonDecode(json),
    );
  }

  @override
  Future<bool> validarSesion() async {

    final prefs =
    await SharedPreferences.getInstance();

    final fechaString =
    prefs.getString(
      loginDateKey,
    );

    if (fechaString == null) {
      return false;
    }

    final fecha =
    DateTime.parse(
      fechaString,
    );

    final diferencia =
    DateTime.now().difference(
      fecha,
    );

    if (diferencia.inDays < 3) {
      return true;
    }

    await logout();

    return false;
  }

  @override
  Future<Usuario?> usuarioActual() {
    // TODO: implement usuarioActual
    throw UnimplementedError();
  }
}