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

class ResultadoAvance {
  final bool success;
  final bool liberada;

  const ResultadoAvance({required this.success, required this.liberada});
}


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

  String? _usuarioActualId;

  // solicitudId -> solicitanteId, para saber quién es el dueño de cada compra
  // sin tener que agregar esa columna a Compra.
  Map<String, String> _solicitantesPorSolicitud = {};

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

  /// True si el usuario logueado es quien creó la solicitud detrás de esta compra.
  bool esSolicitanteDe(Compra compra) {
    if (_usuarioActualId == null) return false;
    final solicitanteId = _solicitantesPorSolicitud[compra.solicitudId];
    return solicitanteId != null && solicitanteId == _usuarioActualId;
  }

  /// True si la compra está detenida esperando la aprobación del solicitante.
  bool requiereAprobacionPendiente(Compra compra) {
    return compra.estado == EstadoCompra.revisionSolicitante &&
        compra.requiereRevisionSolicitante &&
        !compra.revisionSolicitanteRealizada;
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
    _usuarioActualId = sesion?.usuarioId;

    final comprasVigentes = await compraRepository.getVigentes();
    // Filtro de seguridad: aunque getVigentes() ya debería excluirlas,
    // nunca mostramos compras liberadas en esta pantalla.
    compras = comprasVigentes.where((c) => !c.liberada).toList();

    final todasLasSolicitudes = await compraRepository.getSolicitudes();

    // En SeguimientoComprasViewModel.cargar()
    solicitudes = todasLasSolicitudes
        .where((s) => s.estado == EstadoSolicitud.pendiente)
        .toList();

    _solicitantesPorSolicitud = {
      for (final s in todasLasSolicitudes) s.id: s.solicitanteId,
    };

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
      await compraSolicitudSyncService.descargarSolicitudes();
      await compraSolicitudSyncService.sincronizarPendientes();

      await compraSyncService.descargarCompras();
      await compraSyncService.sincronizarPendientes();

      await cargar();
    } catch (e) {
      exito = false;
    }

    sincronizando = false;
    notifyListeners();

    return exito;
  }

  Future<bool> crearSolicitud({
    required String descripcion,
    required bool requiereRevision,
  }) async {
    final sesion = await authService.obtenerSesion();

    if (sesion == null) {
      return false;
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
    return true;
  }

  Future<ResultadoAvance> avanzarEstado(Compra compra) async {
    final estados = EstadoCompra.values;
    final indiceActual = compra.estado.index;

    if (indiceActual >= estados.length - 1) {
      return const ResultadoAvance(success: false, liberada: false);
    }

    if (requiereAprobacionPendiente(compra)) {
      return const ResultadoAvance(success: false, liberada: false);
    }

    final siguienteEstado = estados[indiceActual + 1];
    final esLiberacion = siguienteEstado == EstadoCompra.liberada;
    final ahora = DateTime.now();

    final compraActualizada = compra.copyWith(
      estado: siguienteEstado,
      liberada: esLiberacion ? true : compra.liberada,
      fechaLiberacion: esLiberacion ? ahora : compra.fechaLiberacion,
      estatus: esLiberacion ? 0 : compra.estatus,
      syncStatus: 0,
    );

    try {
      await compraRepository.update(compraActualizada);
    } catch (e) {
      debugPrint('Error al actualizar estado de compra ${compra.id}: $e');
      return const ResultadoAvance(success: false, liberada: false);
    }

    if (esLiberacion) {
      compras = compras.where((c) => c.id != compra.id).toList();
    } else {
      final index = compras.indexWhere((c) => c.id == compra.id);
      if (index != -1) {
        compras = [...compras]..[index] = compraActualizada;
      }
    }
    notifyListeners();

    try {
      await compraSyncService.sincronizarCompra(compraActualizada);
    } catch (e) {
      debugPrint('Error al sincronizar compra ${compra.id} con Firebase: $e');
    }

    return ResultadoAvance(success: true, liberada: esLiberacion);
  }

  /// El solicitante original aprueba la compra en el paso de revisión,
  /// liberando al usuario de compras para continuar avanzando el estado.
  Future<bool> aprobarRevisionSolicitante(Compra compra) async {
    final sesion = await authService.obtenerSesion();
    if (sesion == null) return false;

    final compraActualizada = compra.copyWith(
      revisionSolicitanteRealizada: true,
      fechaRevisionSolicitante: DateTime.now(),
      usuarioRevisionId: sesion.usuarioId,
      syncStatus: 0, // <- igual aquí
    );

    try {
      await compraRepository.update(compraActualizada);
    } catch (e) {
      debugPrint('Error al aprobar revisión de compra ${compra.id}: $e');
      return false;
    }

    final index = compras.indexWhere((c) => c.id == compra.id);
    if (index != -1) {
      compras = [...compras]..[index] = compraActualizada;
    }
    notifyListeners();

    try {
      await compraSyncService.sincronizarCompra(compraActualizada);
    } catch (e) {
      debugPrint('Error al sincronizar aprobación de compra ${compra.id}: $e');
    }

    return true;
  }

}

void unawaited(Future<void> future) {}