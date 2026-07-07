import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/models/Vale_Item.dart';
import 'package:mi_almacen/repositories/proyecto_repository.dart';
import 'package:mi_almacen/services/sync_service.dart';

import '../models/Vale.dart';
import '../services/firebase_service.dart';
import '../services/vale_service.dart';
import '../services/auth_service.dart';

class AprobacionValesViewModel
    extends ChangeNotifier {

  final FirebaseService firebaseService;
  final ProyectoRepository proyectoRepository;
  final AuthService authService;
  final SyncService syncService;


  AprobacionValesViewModel({
    required this.firebaseService,
    required this.valeService,
    required this.proyectoRepository,
    required this.authService,
    required this.syncService,

  });

  bool _cargando = false;

  List<Vale> _vales = [];

  List<Proyecto> _proyectos = [];

  List<Proyecto> get proyectos => List.unmodifiable(_proyectos);

  final ValeService valeService;

  bool get cargando =>
      _cargando;

  List<Vale> get vales =>
      List.unmodifiable(
        _vales,
      );

  Future<void> cargarVales() async {

    _cargando = true;
    notifyListeners();

    try {

      final usuario = await authService.usuarioActual();

      final todosLosVales =
      await firebaseService.obtenerValesPendientes();

      if (usuario == null) {

        _vales = [];

      } else if (usuario.rol == 1) {

        // Supervisor: únicamente su departamento
        _vales = todosLosVales.where((vale) {

          return vale.departamento == usuario.departamento;

        }).toList();

      } else {

        // Admin, Compras y Almacenista
        _vales = todosLosVales;

      }

      await cargarProyectos();

    } finally {

      _cargando = false;
      notifyListeners();

    }
  }

  Future<void> cargarProyectos() async {
    _proyectos = await proyectoRepository.getAll();
    notifyListeners();
  }

  Future<void> aprobarVale(
      String valeId,
      String comentario,
      ) async {

    final sesion =
    await authService.obtenerSesion();

    await valeService.aprobarVale(
      valeId,
      sesion?.usuarioId ?? 0,
      sesion?.nombre ?? '',
      comentario,
    );

    _vales.removeWhere(
          (v) => v.id == valeId,
    );

    notifyListeners();
  }
  Future<void> actualizarVale(Vale vale) async {
    await valeService.actualizarVale(vale);
  }

  Future<void> guardarCambiosVale(Vale vale) async {
    await valeService.actualizarVale(vale);
  }

  Future<void> rechazarVale(
      String valeId,
      String comentario,
      ) async {

    final sesion =
    await authService.obtenerSesion();

    await valeService.rechazarVale(
      valeId,
      sesion?.usuarioId ?? 0,
      sesion?.nombre ?? '',
      comentario,
    );

    _vales.removeWhere(
          (v) => v.id == valeId,
    );

    notifyListeners();
  }
  void actualizarItemVale(
      String valeId,
      int index,
      ValeItem nuevoItem,
      ) {
    final valeIndex =
    _vales.indexWhere((v) => v.id == valeId);

    if (valeIndex == -1) return;

    final vale = _vales[valeIndex];

    final nuevosItems = List<ValeItem>.from(vale.items);

    nuevosItems[index] = nuevoItem;

    _vales[valeIndex] = Vale(
      id: vale.id,
      fechaCreacion: vale.fechaCreacion,
      usuarioNombre: vale.usuarioNombre,
      usuarioRol: vale.usuarioRol,
      estado: vale.estado,
      departamento: vale.departamento,
      items: nuevosItems,
      fechaValidacion: vale.fechaValidacion,
      validadoPor: vale.validadoPor,
      comentarioValidacion: vale.comentarioValidacion,
      syncStatus: vale.syncStatus,
      liberado: vale.liberado,
    );

    notifyListeners();
  }

  Future<void> actualizar() async {
    _cargando = true;
    notifyListeners();

    try {
      await syncService.sincronizarVales();
      await cargarVales();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

}