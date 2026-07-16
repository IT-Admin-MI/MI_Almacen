import 'package:flutter/cupertino.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
import 'package:mi_almacen/models/compra_solicitud.dart';
import 'package:mi_almacen/models/Material.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/repositories/compra_repository.dart';
import 'package:mi_almacen/repositories/material_repository.dart';
import 'package:mi_almacen/repositories/proyecto_repository.dart';
import 'package:mi_almacen/repositories/usuario_repository.dart';
import 'package:mi_almacen/services/compra_service.dart';
import 'package:mi_almacen/services/compra_solicitud_sync_service.dart';

class CompraViewModel extends ChangeNotifier {
  final CompraService compraService;
  final CompraRepository compraRepository;
  final MaterialRepository materialRepository;
  final ProyectoRepository proyectoRepository;
  final UsuarioRepository usuarioRepository;
  final CompraSolicitudSyncService solicitudSyncService;

  CompraViewModel({
    required this.compraService,
    required this.compraRepository,
    required this.materialRepository,
    required this.proyectoRepository,
    required this.usuarioRepository,
    required this.solicitudSyncService,
  });

  // ---------------- Solicitudes pendientes ----------------

  bool _cargando = false;
  bool get cargando => _cargando;

  bool _sincronizando = false;
  bool get sincronizando => _sincronizando;

  List<SolicitudCompra> _solicitudes = [];
  List<SolicitudCompra> get solicitudes => _solicitudes;

  List<Proyecto> _proyectos = [];
  List<Proyecto> get proyectos => _proyectos;

  Map<String, String> _nombresUsuarios = {};

  String nombreSolicitante(String solicitanteId) {
    return _nombresUsuarios[solicitanteId] ?? solicitanteId;
  }

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();

    _solicitudes = await compraRepository.getSolicitudesPendientes();
    _proyectos = await proyectoRepository.getAll();

    final usuarios = await usuarioRepository.getAll();
    _nombresUsuarios = {
      for (final u in usuarios) u.id!: u.nombre,
    };
    debugPrint('MAPA USUARIOS');
    debugPrint(_nombresUsuarios.toString());

    debugPrint(
      'Nombre encontrado: ${_nombresUsuarios["wpJyJLzbEJi2d6c2NiM9"]}',
    );

    _cargando = false;

    for (final s in _solicitudes) {
      debugPrint(
        'Solicitud ${s.id} -> solicitanteId="${s.solicitanteId}"',
      );
    }
    notifyListeners();
  }

  /// Sube solicitudes pendientes y descarga cambios recientes desde Firebase.
  Future<bool> sincronizar() async {
    _sincronizando = true;
    notifyListeners();

    bool exito = true;

    try {
      await solicitudSyncService.sincronizarPendientes();
      await solicitudSyncService.descargarSolicitudes();
      await cargar();
    } catch (e) {
      exito = false;
    }

    _sincronizando = false;
    notifyListeners();

    return exito;
  }

  // ---------------- Búsqueda de material (form de items) ----------------

  String _textoBusqueda = "";
  String get textoBusqueda => _textoBusqueda;

  List<Material> _resultadosBusqueda = [];
  List<Material> get resultadosBusqueda => _resultadosBusqueda;

  Future<void> buscarMaterial(String texto) async {
    _textoBusqueda = texto;

    if (texto.trim().isEmpty) {
      _resultadosBusqueda = [];
      notifyListeners();
      return;
    }

    _resultadosBusqueda = await materialRepository.buscar(texto);
    notifyListeners();
  }

  void limpiarBusquedaMaterial() {
    _textoBusqueda = "";
    _resultadosBusqueda = [];
    notifyListeners();
  }

  // ---------------- Items en construcción para la compra ----------------

  final List<CompraItem> _itemsEnConstruccion = [];
  List<CompraItem> get itemsEnConstruccion =>
      List.unmodifiable(_itemsEnConstruccion);

  void agregarItem(CompraItem item) {
    _itemsEnConstruccion.add(item);
    notifyListeners();
  }

  void editarItem(int index, CompraItem item) {
    _itemsEnConstruccion[index] = item;
    notifyListeners();
  }

  void eliminarItem(int index) {
    _itemsEnConstruccion.removeAt(index);
    notifyListeners();
  }

  void limpiarItems() {
    _itemsEnConstruccion.clear();
    notifyListeners();
  }

  // ---------------- Aprobar / Rechazar ----------------

  Future<Compra> aprobar({
    required SolicitudCompra solicitud,
    required String ordenCompra,
    required TipoCompra tipoCompra,
    required String compradorId,
  }) async {
    final compra = await compraService.aprobarSolicitud(
      solicitud: solicitud,
      ordenCompra: ordenCompra,
      tipoCompra: tipoCompra,
      compradorId: compradorId,
      items: _itemsEnConstruccion,
    );

    limpiarItems();
    await cargar();

    return compra;
  }

  Future<void> rechazar({
    required SolicitudCompra solicitud,
    required String motivo,
  }) async {
    await compraService.rechazarSolicitud(
      solicitud: solicitud,
      motivo: motivo,
    );

    await cargar();
  }
}