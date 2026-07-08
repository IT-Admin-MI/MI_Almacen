import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';

abstract class CompraRepository {

  Future<List<Compra>> getAll();

  Future<Compra?> getById(String id);

  Future<void> insert(Compra compra);

  Future<void> update(Compra compra);

  Future<void> delete(String id);

  Future<List<CompraItem>> getItems(String compraId);

  Future<void> insertItems(List<CompraItem> items);

  Future<void> deleteItems(String compraId);

  Future<void> updateEstado(String compraId, EstadoCompra estado);

}