import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
import 'package:mi_almacen/models/compra_solicitud.dart';
import 'package:mi_almacen/repositories/compra_repository.dart';
import 'package:mi_almacen/services/compra_service.dart';
import 'package:mi_almacen/services/compra_sync_service.dart';

class CompraServiceImpl implements CompraService {

  final CompraRepository compraRepository;
  final CompraSyncService compraSyncService;

  CompraServiceImpl({
    required this.compraRepository,
    required this.compraSyncService,
  });

  @override
  Future<void> crearCompra(Compra compra) async {

    await compraRepository.insert(compra);

  }

  @override
  Future<void> actualizarCompra(Compra compra) async {

    await compraRepository.update(compra);

  }

  @override
  Future<void> eliminarCompra(String compraId) async {

    await compraRepository.delete(compraId);

  }

  @override
  Future<List<Compra>> obtenerCompras() {

    return compraRepository.getAll();

  }

  @override
  Future<Compra?> obtenerCompra(String compraId) {

    return compraRepository.getById(compraId);

  }

  @override
  Future<void> cambiarEstado(
      String compraId,
      EstadoCompra estado,
      ) async {

    await compraRepository.updateEstado(
      compraId,
      estado,
    );

  }

  @override
  Future<Compra> aprobarSolicitud({
    required SolicitudCompra solicitud,
    required String ordenCompra,
    required TipoCompra tipoCompra,
    required String compradorId,
    required List<CompraItem> items,
  }) async {
    final compraId = solicitud.id; // o tu generador de UUID si prefieres uno nuevo

    final compra = Compra(
      id: compraId,
      nombre: solicitud.descripcion,
      solicitudId: solicitud.id,
      ordenCompra: ordenCompra,
      tipoCompra: tipoCompra,
      compradorId: compradorId,
      fechaSolicitud: solicitud.fechaSolicitud,
      estado: EstadoCompra.solicitado,
      requiereRevisionSolicitante: solicitud.requiereRevisionSolicitante,
      revisionSolicitanteRealizada: false,
      liberada: false,
      estatus: 1,
      items: items
          .map((i) => i.copyWith(compraId: compraId))
          .toList(),
      syncStatus: 0,
    );

    await compraRepository.insert(compra);

    final solicitudActualizada = solicitud.copyWith(
      estado: EstadoSolicitud.aprobada,
      compraId: compra.id,
      compradorId: compradorId,
      syncStatus: 0,
    );

    await compraRepository.updateSolicitud(solicitudActualizada);

    return compra;
  }

  @override
  Future<void> rechazarSolicitud({
    required SolicitudCompra solicitud,
    required String motivo,
  }) async {
    await compraRepository.updateEstadoSolicitud(
      solicitud.id,
      EstadoSolicitud.rechazada,
      motivoRechazo: motivo,
    );
}
}