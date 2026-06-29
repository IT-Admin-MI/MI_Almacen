import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginViewModel
    extends ChangeNotifier {

  final AuthService authService;

  LoginViewModel({
    required this.authService,
  });

  bool _loading = false;

  bool get loading => _loading;

  String? _error;

  String? get error => _error;

  Future<bool> login(
      String usuario,
      String password,
      ) async {

    _loading = true;
    _error = null;

    notifyListeners();

    try {
      print("Usuario Login: "+usuario+" Contraseña Login: "+password);
      final ok =
      await authService.login(
        usuario,
        password,
      );

      if (!ok) {

        _error =
        'Usuario o contraseña incorrectos';
      }

      return ok;

    } catch (e, stack) {

      print('ERROR LOGIN');
      print(e);
      print(stack);

      _error = e.toString();

      return false;
    }finally {

      _loading = false;

      notifyListeners();
    }
  }
}