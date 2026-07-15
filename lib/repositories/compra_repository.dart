import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
import 'package:mi_almacen/models/compra_solicitud.dart';

abstract class CompraRepository {

  //================ COMPRAS ===================

  Future<List<Compra>> getAll();

  Future<List<Compra>> getVigentes();

  Future<Compra?> getById(String id);

  Future<void> insert(Compra compra);

  Future<void> update(Compra compra);

  Future<void> delete(String id);

  Future<List<CompraItem>> getItems(String compraId);

  Future<void> insertItems(List<CompraItem> items);

  Future<void> deleteItems(String compraId);

  Future<void> updateEstado(
      String compraId,
      EstadoCompra estado,
      );

  Future<List<Compra>> getPendientesSincronizacion();

  Future<void> marcarSincronizado(String compraId);

  //================ SOLICITUDES ===================

  Future<List<SolicitudCompra>> getSolicitudes();

  Future<SolicitudCompra?> getSolicitudById(
      String id,
      );

  Future<void> insertSolicitud(
      SolicitudCompra solicitud,
      );

  Future<void> updateSolicitud(
      SolicitudCompra solicitud,
      );

  Future<void> deleteSolicitud(
      String id,
      );

  Future<void> updateEstadoSolicitud(
      String solicitudId,
      EstadoSolicitud estado, {
        String? motivoRechazo,
        String? compradorId,
      });

  Future<void> asociarCompra(
      String solicitudId,
      String compraId,
      );

  Future<List<SolicitudCompra>>
  getSolicitudesPendientes();

  Future<List<SolicitudCompra>>
  getSolicitudesPendientesSincronizacion();

  Future<void> marcarSolicitudSincronizada(
      String solicitudId,
      );
}