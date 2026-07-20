import 'package:flutter/material.dart';
import 'package:mi_almacen/repositories/compra_repository.dart';
import 'package:mi_almacen/repositories/proyecto_repository.dart';
import 'package:mi_almacen/repositories/usuario_repository.dart';
import 'package:mi_almacen/services/compra_service.dart';
import 'package:mi_almacen/services/compra_solicitud_sync_service.dart';
import 'package:mi_almacen/services/compra_sync_service.dart';
import 'package:mi_almacen/viewmodels/LiberacionValesViewModel.dart';
import 'package:mi_almacen/viewmodels/admin_db_viewmodel.dart';
import 'package:mi_almacen/viewmodels/aprobacion_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/herramientas_viewmodel.dart';
import 'package:mi_almacen/viewmodels/historial_compras_viewmodel.dart';
import 'package:mi_almacen/viewmodels/historial_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/home_viewmodel.dart';
import 'package:mi_almacen/viewmodels/login_viewmodel.dart';
import 'package:mi_almacen/viewmodels/vale_viewmodel.dart';
import 'package:mi_almacen/viewmodels/compra_viewmodel.dart';
import '../services/auth_service.dart';
import 'home/home_page.dart';
import 'login/login_page.dart';

class SessionGate extends StatefulWidget {

  final AuthService authService;
  final LoginViewModel loginViewModel;
  final ProyectoRepository proyectoRepository;
  final ValeViewModel valeViewModel;
  final AprobacionValesViewModel aprobacionValesViewModel;
  final HomeViewModel homeViewModel;
  final HistorialValesViewModel historialValesViewModel;
  final LiberacionValesViewModel liberacionValesViewModel;
  final AdminDbViewModel adminDbViewModel;
  final CompraViewModel compraViewModel;
  final CompraRepository compraRepository;
  final CompraSyncService compraSyncService;
  final CompraSolicitudSyncService compraSolicitudSyncService;
  final HerramientasViewModel herramientasViewModel;
  final HistorialComprasViewModel historialComprasViewModel;
  final CompraService compraService;


  final UsuarioRepository usuarioRepository;
  const SessionGate({
    super.key,
    required this.authService,
    required this.loginViewModel,
    required this.proyectoRepository,
    required this.valeViewModel,
    required this.aprobacionValesViewModel,
    required this.homeViewModel,
    required this.historialValesViewModel,
    required this.liberacionValesViewModel,
    required this.adminDbViewModel,
    required this.compraViewModel,
    required this.compraRepository,
    required this.compraSyncService,
    required this.compraSolicitudSyncService,
    required this.herramientasViewModel,
    required this.usuarioRepository,
    required this.historialComprasViewModel,
    required this.compraService,
  });

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {

  bool? autorizado;

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {

    final existe = await widget.authService.haySesionActiva();

    if (!existe) {
      setState(() => autorizado = false);
      return;
    }

    final valida = await widget.authService.validarSesion();

    setState(() => autorizado = valida);

    // Opción A: sin sync aquí. Si la sesión se revalida silenciosamente
    // (dentro de la ventana de 3 días de AuthServiceImpl.validarSesion()),
    // no se sincroniza — solo ocurre en un login explícito vía LoginViewModel.
  }

  @override
  Widget build(BuildContext context) {

    if (autorizado == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (autorizado!) {
      return HomePage(
        authService: widget.authService,
        proyectoRepository: widget.proyectoRepository,
        valeViewModel: widget.valeViewModel,
        aprobacionValesViewModel: widget.aprobacionValesViewModel,
        homeViewModel: widget.homeViewModel,
        historialValesViewModel: widget.historialValesViewModel,
        liberacionValesViewModel: widget.liberacionValesViewModel,
        adminDbViewModel: widget.adminDbViewModel,
        compraViewModel: widget.compraViewModel,
        compraRepository: widget.compraRepository,
        compraSyncService: widget.compraSyncService,
        compraSolicitudSyncService: widget.compraSolicitudSyncService,
        herramientasViewModel: widget.herramientasViewModel,
        usuarioRepository: widget.usuarioRepository,
        historialComprasViewModel: widget.historialComprasViewModel,
        compraService: widget.compraService,
      );
    }

    return LoginPage(viewModel: widget.loginViewModel);
  }
}