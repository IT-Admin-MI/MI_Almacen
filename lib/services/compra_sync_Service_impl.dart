import '../models/Compra.dart';
import '../repositories/compra_repository.dart';
import 'compra_sync_service.dart';
import 'firebase_service.dart';

class CompraSyncServiceImpl implements CompraSyncService {

  final FirebaseService firebaseService;
  final CompraRepository compraRepository;

  CompraSyncServiceImpl({
    required this.firebaseService,
    required this.compraRepository,
  });

  @override
  Future<bool> sincronizarCompra(Compra compra) async {
    try {
      await firebaseService.guardarCompra(compra);
      await compraRepository.marcarSincronizado(compra.id!);
      return true;
    } catch (e) {
      print('ERROR SINCRONIZANDO COMPRA: $e');
      return false;
    }
  }

  @override
  Future<void> sincronizarPendientes() async {
    final pendientes = await compraRepository.getPendientesSincronizacion();

    for (final compra in pendientes) {
      await sincronizarCompra(compra);
    }
  }

  @override
  Future<void> descargarCompras() async {
    final compras = await firebaseService.obtenerCompras();

    for (final compra in compras) {
      // Lo que viene de Firebase es la fuente de verdad para ESTE dispositivo:
      // se guarda localmente como ya sincronizado, sin importar qué traiga
      // el campo sync_status del documento remoto (ese campo es solo control
      // local de cada dispositivo, nunca debe viajar de vuelta como si fuera dato real).
      final compraSincronizada = compra.copyWith(syncStatus: 1);

      final existente = await compraRepository.getById(compraSincronizada.id!);

      if (existente == null) {
        await compraRepository.insert(compraSincronizada);
      } else {
        await compraRepository.update(compraSincronizada);
      }
    }
  }
}