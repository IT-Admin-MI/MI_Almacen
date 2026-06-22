import 'package:flutter/material.dart';
import 'package:mi_almacen/repositories/proyecto_repository.dart';
import 'package:mi_almacen/viewmodels/login_viewmodel.dart';
import 'package:mi_almacen/viewmodels/vale_viewmodel.dart';

import '../services/auth_service.dart';
import 'home/home_page.dart';
import 'login/login_page.dart';

class SessionGate extends StatefulWidget {

  final AuthService authService;
  final LoginViewModel loginViewModel;
  final ProyectoRepository proyectoRepository;
  final ValeViewModel valeViewModel;

  const SessionGate({
    super.key,
    required this.authService,
    required this.loginViewModel,
    required this.proyectoRepository,
    required this.valeViewModel,
  });

  @override
  State<SessionGate> createState() =>
      _SessionGateState();
}
class _SessionGateState
    extends State<SessionGate> {

  bool? autorizado;

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {

    final existe =
    await widget.authService
        .haySesionActiva();

    if (!existe) {

      setState(() {
        autorizado = false;
      });

      return;
    }

    final valida =
    await widget.authService
        .validarSesion();

    setState(() {
      autorizado = valida;
    });


  }
  @override
  Widget build(BuildContext context) {

    if (autorizado == null) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (autorizado!) {

      return HomePage(
        authService: widget.authService,
        proyectoRepository: widget.proyectoRepository,
        valeViewModel: widget.valeViewModel,
      );

    }

    return LoginPage(
      viewModel: widget.loginViewModel,
    );
  }
}