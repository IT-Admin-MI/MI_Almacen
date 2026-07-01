import '../models/Vale.dart';

abstract class ValeSyncService {

  Future<bool> sincronizarVale(
      Vale vale,
      );

  Future<void> sincronizarPendientes();

  /// NUEVO
  Future<void> descargarVales();

}