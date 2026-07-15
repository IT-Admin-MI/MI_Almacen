import 'package:mi_almacen/models/compra_solicitud.dart';

abstract class CompraSolicitudSyncService {

  Future<bool> sincronizarSolicitud(
      SolicitudCompra solicitud,
      );

  Future<void> sincronizarPendientes();

  Future<void> descargarSolicitudes();
}