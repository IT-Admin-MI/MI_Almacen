import 'package:flutter/foundation.dart';
import 'package:mi_almacen/models/Usuario.dart';
import 'package:mi_almacen/services/vate_sync_service.dart';
import '../models/Material.dart';
import '../models/Proyecto.dart';
import '../models/Vale_Item.dart';
import '../repositories/material_repository.dart';
import '../repositories/proyecto_repository.dart';
import '../models/Historial_Vale.dart';
import '../models/Vale.dart';
import '../models/vale_estado.dart';

import '../repositories/historial_vale_repository.dart';
import '../repositories/vale_repository.dart';

import '../services/auth_service.dart';
import '../utils/id_generator.dart';

class ValeViewModel extends ChangeNotifier {

  final MaterialRepository materialRepository;
  final ProyectoRepository proyectoRepository;

  final ValeRepository valeRepository;
  final HistorialValeRepository historialValeRepository;

  final ValeSyncService valeSyncService;

  final AuthService authService;

  List<Vale> _valesPendientes = [];

  List<Vale> get valesPendientes =>
      List.unmodifiable(
        _valesPendientes,
      );

  bool _creandoVale = false;

  bool get creandoVale =>
      _creandoVale;


  ValeViewModel({
    required this.materialRepository,
    required this.proyectoRepository,
    required this.valeRepository,
    required this.historialValeRepository,
    required this.valeSyncService,
    required this.authService,
  });

  // ==========================
  // ESTADO
  // ==========================

  bool _cargandoMateriales = false;
  bool _cargandoProyectos = false;

  List<Material> _resultadosBusqueda = [];

  List<Proyecto> _proyectos = [];

  List<ValeItem> _items = [];

  String _textoBusqueda = '';

  // ==========================
  // GETTERS
  // ==========================

  bool get cargandoMateriales =>
      _cargandoMateriales;

  bool get cargandoProyectos =>
      _cargandoProyectos;

  List<Material> get resultadosBusqueda =>
      List.unmodifiable(
        _resultadosBusqueda,
      );

  List<Proyecto> get proyectos =>
      List.unmodifiable(
        _proyectos,
      );

  List<ValeItem> get items =>
      List.unmodifiable(
        _items,
      );

  String get textoBusqueda =>
      _textoBusqueda;

  bool get tieneMateriales =>
      _items.isNotEmpty;

  // ==========================
  // INICIALIZACIÓN
  // ==========================

  Future<void> inicializar() async {

    await cargarProyectos();
  }

  Future<void> cargarPendientes() async {

    _valesPendientes =
    await valeRepository
        .getPendientes();

    notifyListeners();
  }




  // ==========================
  // PROYECTOS
  // ==========================

  Future<void> cargarProyectos() async {

    try {

      _cargandoProyectos = true;

      notifyListeners();

      _proyectos =
      await proyectoRepository.getAll();

    } finally {

      _cargandoProyectos = false;

      notifyListeners();
    }
  }

  // ==========================
  // BÚSQUEDA
  // ==========================

  Future<void> buscarMaterial(
      String texto,
      ) async {

    _textoBusqueda = texto;

    if (texto.trim().isEmpty) {

      _resultadosBusqueda = [];

      notifyListeners();

      return;
    }

    _resultadosBusqueda =
    await materialRepository.buscar(
      texto,
    );

    notifyListeners();
  }

  Future<void> aprobarVale(
      Vale vale,
      ) async {

    final actualizado = Vale(
      id: vale.id,
      fechaCreacion:
      vale.fechaCreacion,
      usuarioNombre:
      vale.usuarioNombre,
      usuarioRol:
      vale.usuarioRol,
      departamento:
      vale.departamento,
      estado: 1,
      items: vale.items,
      fechaValidacion:
      DateTime.now(),
      syncStatus:
      vale.syncStatus,
      liberado: 0,
    );

    await valeRepository.update(
      actualizado,
    );

    await cargarPendientes();
  }

  Future<void> rechazarVale(
      Vale vale,
      ) async {

    final actualizado = Vale(
      id: vale.id,
      fechaCreacion:
      vale.fechaCreacion,
      usuarioNombre:
      vale.usuarioNombre,
      departamento:
      vale.departamento,
      usuarioRol:
      vale.usuarioRol,
      estado: 2,
      items: vale.items,
      fechaValidacion:
      DateTime.now(),
      syncStatus:
      vale.syncStatus,
      liberado: 0,
    );

    await valeRepository.update(
      actualizado,
    );

    await cargarPendientes();
  }

  void limpiarBusqueda() {

    _textoBusqueda = '';

    _resultadosBusqueda = [];

    notifyListeners();
  }

  // ==========================
  // ITEMS DEL VALE
  // ==========================

  void agregarMaterial(
      Material material,
      ) {

    final existe = _items.any(
          (item) =>
      item.material.codigo ==
          material.codigo,
    );

    if (existe) {
      return;
    }

    _items.add(

      ValeItem(
        material: material,
      ),
    );

    _resultadosBusqueda = [];

    notifyListeners();
  }

  void eliminarMaterial(
      ValeItem item,
      ) {

    _items.remove(item);

    notifyListeners();
  }

  void actualizarCantidad(
      ValeItem item,
      double cantidad,
      ) {

    if (cantidad <= 0) {
      return;
    }

    item.cantidad = cantidad;

    notifyListeners();
  }

  void actualizarUnidad(
      ValeItem item,
      String unidad,
      ) {

    item.unidad = unidad;

    notifyListeners();
  }

  void actualizarProyecto(
      ValeItem item,
      Proyecto? proyecto,
      ) {

    item.proyecto = proyecto;

    notifyListeners();
  }

  // ==========================
  // VALIDACIONES
  // ==========================

  bool get puedeCrearVale {

    if (_items.isEmpty) {
      return false;
    }

    for (final item in _items) {

      if (item.proyecto == null) {
        return false;
      }

      if (item.cantidad <= 0) {
        return false;
      }
    }

    return true;
  }

  // ==========================
  // LIMPIAR VALE
  // ==========================

  void limpiarVale() {

    _items.clear();

    _resultadosBusqueda.clear();

    _textoBusqueda = '';

    notifyListeners();
  }
  // ==========================
  // SINCRONIZACIONES
  // ==========================

  Future<void> sincronizarMateriales() async {

    _cargandoMateriales = true;

    notifyListeners();

    try {

      await materialRepository
          .sincronizarDrive();

    } finally {

      _cargandoMateriales = false;

      notifyListeners();
    }
  }



  Future<void> sincronizarProyectos() async {

    _cargandoProyectos = true;

    notifyListeners();

    try {

      await proyectoRepository
          .sincronizarFirebase();

      _proyectos =
      await proyectoRepository.getAll();

    } finally {

      _cargandoProyectos = false;

      notifyListeners();
    }
  }

  Future<bool> crearVale() async {

    if (!puedeCrearVale) {
      return false;
    }

    try {



      _creandoVale = true;

      notifyListeners();

      final sesion =
      await authService
          .obtenerSesion();


      print('===== SESION =====');
      print('Nombre: ${sesion?.nombre}');
      print('Rol: ${sesion?.rol}');
      print('Departamento: "${sesion?.departamento}"');

      if (sesion == null) {
        throw Exception(
          'No existe sesión activa',
        );
      }

      final vale = Vale(
        id: IdGenerator.generarValeId(nombre: '${sesion.nombre}', departamento: '${sesion.departamento}'),

        usuarioNombre:
        sesion.nombre,

        usuarioRol:
        sesion.rol,

        departamento:
        sesion.departamento,
        fechaCreacion:
        DateTime.now(),

        estado:
        ValeEstado.pendiente,

        liberado: 0,

        syncStatus: 0,

        items:
        List<ValeItem>.from(
          _items,
        ),
      );

      await valeRepository.insert(
        vale,
      );

      await historialValeRepository.insert(

          HistorialVale(
            valeId: vale.id,
            fecha: DateTime.now(),
            usuarioNombre: sesion.nombre,
            accion: 'CREACION',
            estadoAnterior: '',
            estadoNuevo: 'PENDIENTE',
            comentario: '',
          )
      );

      await valeSyncService
          .sincronizarVale(
        vale,
      );

      limpiarVale();

      return true;

    } catch (e) {

      debugPrint(
        'ERROR CREANDO VALE: $e',
      );

      return false;

    } finally {

      _creandoVale = false;

      notifyListeners();
    }
  }
  void actualizarComentario(
      ValeItem item,
      String comentario,
      ) {
    item.comentarioVale = comentario;
    notifyListeners();
  }

}