import '../models/compra_solicitud.dart';
import '../repositories/compra_repository.dart';
import 'compra_solicitud_sync_service.dart';
import 'firebase_service.dart';

class CompraSolicitudSyncServiceImpl
    implements CompraSolicitudSyncService {

  final FirebaseService firebaseService;
  final CompraRepository compraRepository;

  CompraSolicitudSyncServiceImpl({
    required this.firebaseService,
    required this.compraRepository,
  });

  @override
  Future<bool> sincronizarSolicitud(
      SolicitudCompra solicitud,
      ) async {

    try {

      await firebaseService.guardarSolicitudCompra(
        solicitud,
      );

      await compraRepository
          .marcarSolicitudSincronizada(
        solicitud.id!,
      );

      return true;

    }  catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }

  @override
  Future<void> sincronizarPendientes() async {

    final pendientes =
    await compraRepository
        .getSolicitudesPendientesSincronizacion();

    for (final solicitud in pendientes) {

      await sincronizarSolicitud(
        solicitud,
      );

    }
  }

  @override
  Future<void> descargarSolicitudes() async {

    final solicitudes =
    await firebaseService
        .obtenerSolicitudesCompra();

    for (final solicitud in solicitudes) {

      final existente =
      await compraRepository
          .getSolicitudById(
        solicitud.id!,
      );

      if (existente == null) {

        await compraRepository
            .insertSolicitud(
          solicitud,
        );

      } else {

        await compraRepository
            .updateSolicitud(
          solicitud,
        );

      }
    }
  }
}