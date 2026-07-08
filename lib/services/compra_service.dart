import 'package:mi_almacen/models/Compra.dart';

abstract class CompraService {

  Future<void> crearCompra(Compra compra);

  Future<void> actualizarCompra(Compra compra);

  Future<void> eliminarCompra(String compraId);

  Future<List<Compra>> obtenerCompras();

  Future<Compra?> obtenerCompra(String compraId);

  Future<void> cambiarEstado(
      String compraId,
      EstadoCompra estado,
      );

}