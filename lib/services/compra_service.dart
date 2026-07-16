import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
import 'package:mi_almacen/models/compra_solicitud.dart';

abstract class CompraService {
  Future<void> crearCompra(Compra compra);
  Future<void> actualizarCompra(Compra compra);
  Future<void> eliminarCompra(String compraId);
  Future<List<Compra>> obtenerCompras();
  Future<Compra?> obtenerCompra(String compraId);
  Future<void> cambiarEstado(String compraId, EstadoCompra estado);

  /// Aprueba una solicitud: crea la Compra formal y actualiza la solicitud.
  Future<Compra> aprobarSolicitud({
    required SolicitudCompra solicitud,
    required String ordenCompra,
    required TipoCompra tipoCompra,
    required String compradorId,
    required List<CompraItem> items,
  });

  /// Rechaza una solicitud sin crear Compra.
  Future<void> rechazarSolicitud({
    required SolicitudCompra solicitud,
    required String motivo,
  });
}