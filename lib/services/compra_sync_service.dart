import '../models/Compra.dart';

abstract class CompraSyncService {

  /// Sincroniza una compra específica con Firebase.
  Future<bool> sincronizarCompra(Compra compra);

  /// Sincroniza todas las compras pendientes de SQLite hacia Firebase.
  Future<void> sincronizarPendientes();

  /// Descarga las compras desde Firebase hacia SQLite.
  Future<void> descargarCompras();
}