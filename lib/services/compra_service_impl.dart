import 'package:mi_almacen/models/Compra.dart';
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
}