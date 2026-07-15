import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/compra_solicitud.dart';
import 'package:mi_almacen/repositories/compra_repository.dart';
import 'package:mi_almacen/services/auth_service.dart';
import 'package:mi_almacen/services/compra_solicitud_sync_service.dart';
import 'package:mi_almacen/services/compra_solicitud_sync_service_impl.dart';
import 'package:mi_almacen/services/compra_sync_service.dart';
import 'package:mi_almacen/utils/id_generator.dart';

class SeguimientoComprasViewModel extends ChangeNotifier {
  final CompraRepository compraRepository;
  final AuthService authService;
  final CompraSolicitudSyncService compraSolicitudSyncService;

  SeguimientoComprasViewModel({
    required this.compraRepository,
    required this.authService,
    required this.compraSolicitudSyncService,
  });

  bool cargando = false;

  IdGenerator idGenerator = IdGenerator();

  List<Compra> compras = [];

  List<SolicitudCompra> solicitudes = [];

  Future<void> cargar() async {
    await compraSolicitudSyncService.descargarSolicitudes();

    cargando = true;
    notifyListeners();

    compras = await compraRepository.getVigentes();

    solicitudes =
    await compraRepository.getSolicitudes();

    cargando = false;
    notifyListeners();
  }

  Future<void> crearSolicitud({
    required String descripcion,
    required bool requiereRevision,
  }) async {

    final sesion =
    await authService.obtenerSesion();

    if (sesion == null) {
      return;
    }

    final solicitud = SolicitudCompra(
      id: IdGenerator.generarSolicitudCompraId(nombre: sesion.usuarioId),
      solicitanteId: sesion.usuarioId,
      fechaSolicitud: DateTime.now(),
      descripcion: descripcion,
      requiereRevisionSolicitante:
      requiereRevision,
      estado: EstadoSolicitud.pendiente,
      syncStatus: 0,
    );

    await compraRepository.insertSolicitud(
      solicitud,
    );

    await compraSolicitudSyncService.sincronizarSolicitud(solicitud);

    await cargar();
  }

}