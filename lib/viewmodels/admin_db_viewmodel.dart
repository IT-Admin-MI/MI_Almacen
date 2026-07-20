import 'package:flutter/foundation.dart';
import 'package:mi_almacen/repositories/compra_repository.dart';
import 'package:mi_almacen/services/compra_sync_service.dart';

import '../models/Material.dart';
import '../models/Proyecto.dart';
import '../repositories/admin_repository.dart';
import '../repositories/vale_repository.dart';
import '../repositories/proyecto_repository.dart';
import '../repositories/material_repository.dart';
import '../services/vate_sync_service.dart';

class AdminDbViewModel extends ChangeNotifier {
  final AdminRepository adminRepository;
  final ValeRepository valeRepository;
  final ProyectoRepository proyectoRepository;
  final MaterialRepository materialRepository;
  final ValeSyncService valeSyncService;
  final CompraRepository compraRepository;
  final CompraSyncService compraSyncService;

  AdminDbViewModel({
    required this.adminRepository,
    required this.valeRepository,
    required this.proyectoRepository,
    required this.materialRepository,
    required this.valeSyncService,
    required this.compraRepository,
    required this.compraSyncService,
  });

  List<Map<String, dynamic>> vales = [];
  List<Map<String, dynamic>> valeItems = [];
  List<Map<String, dynamic>> proyectos = [];

  // Catálogos como objetos, para alimentar los Dropdown
  List<Material> materiales = [];
  List<Proyecto> proyectosCatalogo = [];

  List<Map<String, dynamic>> compras = [];
  List<Map<String, dynamic>> compraItems = [];

  bool cargando = false;
  String? error;

  Future<void> cargarTodo() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      vales = await adminRepository.obtenerFilas(
        'vales',
        orderBy: 'fecha_creacion DESC',
      );
      valeItems = await adminRepository.obtenerFilas(
        'vale_items',
        orderBy: 'vale_id',
      );
      proyectos = await adminRepository.obtenerFilas(
        'proyectos',
        orderBy: 'orden',
      );

      materiales = await materialRepository.getAll();
      proyectosCatalogo =
          proyectos.map((p) => Proyecto.fromMap(p)).toList();

      compras = await adminRepository.obtenerFilas(
        'compras',
        orderBy: 'fecha_solicitud DESC',
      );

      compraItems = await adminRepository.obtenerFilas(
        'compra_items',
        orderBy: 'compra_id',
      );
    } catch (e) {
      error = 'Error cargando datos: $e';
    }

    cargando = false;
    notifyListeners();
  }

  Future<void> guardarVale(Map<String, dynamic> fila) async {
    await adminRepository.actualizarFila(
      tabla: 'vales',
      columnaId: 'id',
      valorId: fila['id'],
      valores: {
        ...fila,
        'sync_status': 0,
      },
    );

    final vale = await valeRepository.getById(fila['id'] as String);
    if (vale != null) {
      await valeSyncService.sincronizarVale(vale);
    }

    await cargarTodo();
  }

  Future<void> guardarValeItem(Map<String, dynamic> fila) async {
    await adminRepository.actualizarFila(
      tabla: 'vale_items',
      columnaId: 'id',
      valorId: fila['id'],
      valores: fila,
    );

    await adminRepository.actualizarFila(
      tabla: 'vales',
      columnaId: 'id',
      valorId: fila['vale_id'],
      valores: {'sync_status': 0},
    );

    final vale = await valeRepository.getById(fila['vale_id'] as String);
    if (vale != null) {
      await valeSyncService.sincronizarVale(vale);
    }

    await cargarTodo();
  }

  Future<void> eliminarValeItem(Map<String, dynamic> fila) async {
    await adminRepository.eliminarFila(
      tabla: 'vale_items',
      columnaId: 'id',
      valorId: fila['id'],
    );

    final vale = await valeRepository.getById(fila['vale_id'] as String);
    if (vale != null) {
      await valeSyncService.sincronizarVale(vale);
    }

    await cargarTodo();
  }

  Future<void> guardarProyecto(Map<String, dynamic> fila) async {
    await adminRepository.actualizarFila(
      tabla: 'proyectos',
      columnaId: 'clave',
      valorId: fila['clave'],
      valores: fila,
    );

    final proyecto =
    await proyectoRepository.getByClave(fila['clave'] as String);
    if (proyecto != null) {
      await proyectoRepository.sincronizarProyectoFirebase(proyecto);
    }

    await cargarTodo();
  }
  Future<void> sincronizarVales() async {
    try {
      for (final valeMap in vales) {
        final vale = await valeRepository.getById(valeMap['id'] as String);
        if (vale != null) {
          await valeSyncService.sincronizarVale(vale);
        }
      }
    } catch (e) {
      error = 'Error sincronizando vales: $e';
    }

    await cargarTodo();
  }
  Future<void> sincronizarProyectos() async {

    await proyectoRepository
        .sincronizarFirebase();
  }

  Future<void> guardarCompra(Map<String, dynamic> fila) async {
    await adminRepository.actualizarFila(
      tabla: 'compras',
      columnaId: 'id',
      valorId: fila['id'],
      valores: {
        ...fila,
        'sync_status': 0,
      },
    );

    final compra = await compraRepository.getById(fila['id'] as String);

    if (compra != null) {
      await compraSyncService.sincronizarCompra(compra);
    }

    await cargarTodo();
  }

  Future<void> guardarCompraItem(Map<String, dynamic> fila) async {
    await adminRepository.actualizarFila(
      tabla: 'compra_items',
      columnaId: 'id',
      valorId: fila['id'],
      valores: fila,
    );

    await adminRepository.actualizarFila(
      tabla: 'compras',
      columnaId: 'id',
      valorId: fila['compra_id'],
      valores: {
        'sync_status': 0,
      },
    );

    final compra = await compraRepository.getById(
      fila['compra_id'] as String,
    );

    if (compra != null) {
      await compraSyncService.sincronizarCompra(compra);
    }

    await cargarTodo();
  }

  Future<void> sincronizarCompras() async {
    try {
      for (final compraMap in compras) {
        final compra = await compraRepository.getById(
          compraMap['id'] as String,
        );

        if (compra != null) {
          await compraSyncService.sincronizarCompra(compra);
        }
      }
    } catch (e) {
      error = 'Error sincronizando compras: $e';
    }

    await cargarTodo();
  }
}