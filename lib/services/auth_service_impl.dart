import 'dart:convert';

import 'package:mi_almacen/services/platform_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Sesion.dart';
import '../models/Usuario.dart';
import '../repositories/usuario_repository.dart';
import 'auth_service.dart';
import 'firebase_service.dart';

class AuthServiceImpl implements AuthService {

  static const String sessionKey = 'user_session';
  static const String loginDateKey = 'last_login_validation';

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

    final usuarioFirebase =
    await firebaseService.login(
      nombre,
      password,
    );

    if (usuarioFirebase == null) {
      return false;
    }

    if (PlatformService.usaSQLite) {
      final usuarioLocal =
      await usuarioRepository.getByNombre(
        usuarioFirebase.nombre,
      );

      if (usuarioLocal == null) {

        await usuarioRepository.insert(
          usuarioFirebase,
        );

      } else {

        await usuarioRepository.update(
          Usuario(
            id: usuarioLocal.id,
            nombre: usuarioFirebase.nombre,
            password: usuarioFirebase.password,
            descripcion:
            usuarioFirebase.descripcion,
            rol: usuarioFirebase.rol,
            fcmToken: usuarioFirebase.fcmToken,
            supervisorId: usuarioFirebase.supervisorId,
            departamento: usuarioFirebase.departamento,
          ),
        );
      }
    }

    final sesion = SesionUsuario(
      nombre: usuarioFirebase.nombre,
      rol: usuarioFirebase.rol,
      usuarioId: usuarioFirebase.id ?? '',
      departamento: usuarioFirebase.departamento,
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

    if (!PlatformService.usaSQLite) {

      final sesion =
      await obtenerSesion();

      return sesion != null;
    }

    // flujo actual SQLite

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

    final sesion =
    await obtenerSesion();

    if (sesion == null) {
      return false;
    }

    final usuario =
    await usuarioRepository.getByNombre(
      sesion.nombre,
    );

    if (usuario == null) {

      await logout();

      return false;
    }

    final usuarioFirebase =
    await firebaseService.login(
      usuario.nombre,
      usuario.password,
    );

    if (usuarioFirebase == null) {

      await logout();

      return false;
    }

    await prefs.setString(
      loginDateKey,
      DateTime.now().toIso8601String(),
    );

    return true;
  }

  @override
  Future<Usuario?> usuarioActual() async {

    final sesion =
    await obtenerSesion();

    if (sesion == null) {
      return null;
    }

    if (!PlatformService.usaSQLite) {

      return Usuario(
        id: sesion.usuarioId,
        nombre: sesion.nombre,
        password: '',
        descripcion: '',
        rol: sesion.rol,
        departamento: sesion.departamento,
      );
    }

    return usuarioRepository.getByNombre(
      sesion.nombre,
    );
  }
}