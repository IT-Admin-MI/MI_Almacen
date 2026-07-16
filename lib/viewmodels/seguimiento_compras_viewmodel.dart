import 'package:flutter/material.dart';
import 'package:mi_almacen/constants/roles.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/compra_solicitud.dart';
import 'package:mi_almacen/repositories/compra_repository.dart';
import 'package:mi_almacen/repositories/usuario_repository.dart';
import 'package:mi_almacen/services/auth_service.dart';
import 'package:mi_almacen/services/compra_solicitud_sync_service.dart';
import 'package:mi_almacen/services/compra_sync_service.dart';
import 'package:mi_almacen/utils/id_generator.dart';

class SeguimientoComprasViewModel extends ChangeNotifier {
  final CompraRepository compraRepository;
  final AuthService authService;
  final CompraSolicitudSyncService compraSolicitudSyncService;
  final CompraSyncService compraSyncService;
  final UsuarioRepository usuarioRepository;

  SeguimientoComprasViewModel({
    required this.compraRepository,
    required this.authService,
    required this.compraSolicitudSyncService,
    required this.compraSyncService,
    required this.usuarioRepository,
  });

  bool cargando = false;
  bool sincronizando = false;

  IdGenerator idGenerator = IdGenerator();

  List<Compra> compras = [];
  List<SolicitudCompra> solicitudes = [];

  int? _rolUsuario;
  bool get esUsuarioCompras => _rolUsuario == Roles.compras;

  Map<String, String> _nombresUsuarios = {};
  String nombreSolicitante(String solicitanteId) {
    return _nombresUsuarios[solicitanteId] ?? solicitanteId;
  }

  final Set<String> _expandidos = {};
  bool estaExpandido(String compraId) => _expandidos.contains(compraId);

  void toggleExpandido(String compraId) {
    if (_expandidos.contains(compraId)) {
      _expandidos.remove(compraId);
    } else {
      _expandidos.add(compraId);
    }
    notifyListeners();
  }

  /// Carga SOLO datos locales (SQLite). Rápido, sin red.
  /// Se llama al entrar a la página y después de cada acción local.
  Future<void> cargar() async {
    final soloVacio = compras.isEmpty && solicitudes.isEmpty;

    if (soloVacio) {
      cargando = true;
      notifyListeners();
    }

    final sesion = await authService.obtenerSesion();
    _rolUsuario = sesion?.rol;

    compras = await compraRepository.getVigentes();

    final todasLasSolicitudes = await compraRepository.getSolicitudes();

    solicitudes = todasLasSolicitudes
        .where((s) => s.estado != EstadoSolicitud.rechazada)
        .toList();

    final usuarios = await usuarioRepository.getAll();
    _nombresUsuarios = {
      for (final u in usuarios)
        if (u.id != null) u.id!: u.nombre,
    };

    cargando = false;
    notifyListeners();
  }

  /// Sincroniza con Firebase (sube pendientes + descarga cambios).
  /// Se llama explícitamente desde el gesto de swipe.
  Future<bool> sincronizar() async {
    sincronizando = true;
    notifyListeners();

    bool exito = true;

    try {
      await compraSolicitudSyncService.sincronizarPendientes();
      await compraSolicitudSyncService.descargarSolicitudes();

      await compraSyncService.sincronizarPendientes();
      await compraSyncService.descargarCompras();

      await cargar();
    } catch (e) {
      exito = false;
    }

    sincronizando = false;
    notifyListeners();

    return exito;
  }

  Future<void> crearSolicitud({
    required String descripcion,
    required bool requiereRevision,
  }) async {
    final sesion = await authService.obtenerSesion();

    if (sesion == null) {
      return;
    }

    final solicitud = SolicitudCompra(
      id: IdGenerator.generarSolicitudCompraId(nombre: sesion.usuarioId),
      solicitanteId: sesion.usuarioId,
      fechaSolicitud: DateTime.now(),
      descripcion: descripcion,
      requiereRevisionSolicitante: requiereRevision,
      estado: EstadoSolicitud.pendiente,
      syncStatus: 0,
    );

    await compraRepository.insertSolicitud(solicitud);

    solicitudes = [...solicitudes, solicitud];
    notifyListeners();

    // Sync de esta solicitud en particular, sin bloquear ni recargar todo.
    unawaited(compraSolicitudSyncService.sincronizarSolicitud(solicitud));
  }

  /// Avanza la compra al siguiente estado. Solo actualiza local + sube
  /// ese cambio puntual, sin disparar una descarga completa de red
  /// (eso evita el parpadeo/colapso del contenedor).
  Future<void> avanzarEstado(Compra compra) async {
    final estados = EstadoCompra.values;
    final indiceActual = compra.estado.index;

    if (indiceActual >= estados.length - 1) {
      return;
    }

    final siguienteEstado = estados[indiceActual + 1];

    await compraRepository.updateEstado(compra.id!, siguienteEstado);

    final compraActualizada = compra.copyWith(estado: siguienteEstado);

    final index = compras.indexWhere((c) => c.id == compra.id);
    if (index != -1) {
      compras = [...compras]..[index] = compraActualizada;
    }
    notifyListeners();

    // Sube el cambio en segundo plano, sin bloquear la UI ni recargar todo.
    unawaited(compraSyncService.sincronizarCompra(compraActualizada));
  }
}

void unawaited(Future<void> future) {}