import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/sync_service.dart'; // ← NUEVO
import '../services/notification_service.dart';

class LoginViewModel extends ChangeNotifier {

  final AuthService authService;

  final SyncService syncService; // ← NUEVO
  final NotificationService notificationService;

  LoginViewModel({
    required this.authService,
    required this.syncService,
    required this.notificationService, // ← NUEVO
  });

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // ← NUEVO: para poder mostrar un texto distinto mientras sincroniza
  bool _sincronizando = false;
  bool get sincronizando => _sincronizando;

  Future<bool> login(String usuario, String password) async {

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final ok = await authService.login(usuario, password);

      if (!ok) {
        _error = 'Usuario o contraseña incorrectos';
        return false;
      }

      // Login correcto: ahora sincronizamos antes de dar por terminado
      // el proceso, para que HomePage ya encuentre datos frescos.
      _sincronizando = true;
      notifyListeners();

      try {
        final usuarioActual = await authService.usuarioActual(); // o el getter que ya uses
        if (usuarioActual != null) {
          await notificationService.saveTokenForUser(usuarioActual.id??'');
        }
      } catch (e) {
        print('ERROR GUARDANDO TOKEN FCM: $e');
      }

      try {
        await syncService.sincronizarTodo().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('SYNC POST-LOGIN: tiempo límite alcanzado, continuando');
          },
        );
      } catch (e) {
        // No bloqueamos el login si falla el sync: el usuario ya quedó
        // autenticado y puede seguir usando la app con datos locales;
        // el próximo sincronizarTodo() (o pull-to-refresh) reintentará.
        print('ERROR SINCRONIZANDO TRAS LOGIN: $e');
      } finally {
        _sincronizando = false;
      }

      return true;

    } catch (e, stack) {
      print('ERROR LOGIN');
      print(e);
      print(stack);

      _error = e.toString();
      return false;

    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}