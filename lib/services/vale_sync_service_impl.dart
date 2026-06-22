import 'package:mi_almacen/services/vate_sync_service.dart';

import '../repositories/vale_repository.dart';
import '../models/Vale.dart';
import 'firebase_service.dart';

class ValeSyncServiceImpl
    implements ValeSyncService {

  final FirebaseService firebaseService;

  final ValeRepository valeRepository;

  ValeSyncServiceImpl({
    required this.firebaseService,
    required this.valeRepository,
  });

  @override
  Future<bool> sincronizarVale(
      Vale vale,
      ) async {

    try {

      await firebaseService
          .guardarVale(
        vale,
      );

      await valeRepository
          .marcarSincronizado(
        vale.id,
      );

      return true;

    } catch (e) {

      print(
        'ERROR SINCRONIZANDO VALE: $e',
      );

      return false;
    }
  }

  @override
  Future<void>
  sincronizarPendientes()
  async {

    final pendientes =
    await valeRepository
        .getPendientesSincronizacion();

    for (final vale
    in pendientes) {

      await sincronizarVale(
        vale,
      );
    }
  }
}