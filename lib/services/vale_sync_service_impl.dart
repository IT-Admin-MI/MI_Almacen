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

  @override
  Future<void> descargarVales() async {
    final valesFirebase = await firebaseService.obtenerVales();

    for (final v in valesFirebase) {
      print(
          'Firebase -> ${v.id} estado=${v.estado} liberado=${v.liberado}');
    }
    final idsFirebase = valesFirebase.map((v) => v.id).toSet();

    // 1. Upsert: insertar nuevos, actualizar existentes
    for (final vale in valesFirebase) {
      final existente = await valeRepository.getById(vale.id);
      if (existente == null) {
        await valeRepository.insert(vale);
      } else {
        await valeRepository.update(vale);
      }
    }

    // 2. Espejo: borrar localmente lo que ya no existe en Firebase.
    //    Solo se borran vales YA sincronizados (sync_status == 1) para no
    //    perder vales creados/editados offline que aún no se han subido.
    final valesLocales = await valeRepository.getAll();

    for (final local in valesLocales) {
      if (!idsFirebase.contains(local.id) && local.syncStatus == 1) {
        await valeRepository.delete(local.id);
      }
    }
  }
}