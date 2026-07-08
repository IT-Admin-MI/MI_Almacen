import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
import 'package:mi_almacen/repositories/compra_repository.dart';
import 'package:mi_almacen/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CompraRepositoryImpl implements CompraRepository {
  final DatabaseHelper databaseHelper;

  CompraRepositoryImpl({
    required this.databaseHelper,
  });
  @override
  Future<void> delete(String compraId) async {

    final db = await databaseHelper.database;

    await db.transaction((txn) async {

      await txn.delete(
        'compra_items',
        where: 'compra_id = ?',
        whereArgs: [compraId],
      );

      await txn.delete(
        'compras',
        where: 'id = ?',
        whereArgs: [compraId],
      );

    });

  }

  @override
  Future<void> deleteItems(String compraId) {
    // TODO: implement deleteItems
    throw UnimplementedError();
  }

  @override
  Future<List<Compra>> getAll() async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'compras',
      orderBy: 'fecha_solicitud DESC',
    );

    final lista = <Compra>[];

    for (final row in result) {

      lista.add(
        await _mapCompra(
          db,
          row,
        ),
      );

    }

    return lista;

  }

  @override
  Future<Compra?> getById(String compraId) async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'compras',
      where: 'id = ?',
      whereArgs: [compraId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return await _mapCompra(
      db,
      result.first,
    );

  }

  @override
  Future<List<CompraItem>> getItems(String compraId) {
    // TODO: implement getItems
    throw UnimplementedError();
  }

  @override
  Future<void> insert(Compra compra) async {

    final db = await databaseHelper.database;

    await db.transaction((txn) async {

      await txn.insert(
        'compras',
        compra.toMap(),
      );

      for (final item in compra.items) {

        await txn.insert(
          'compra_items',
          item.toMap(),
        );

      }

    });

  }

  @override
  Future<void> insertItems(List<CompraItem> items) {
    // TODO: implement insertItems
    throw UnimplementedError();
  }

  @override
  Future<void> update(Compra compra) async {

    final db = await databaseHelper.database;

    await db.transaction((txn) async {

      await txn.update(
        'compras',
        compra.toMap(),
        where: 'id = ?',
        whereArgs: [compra.id],
      );

      await txn.delete(
        'compra_items',
        where: 'compra_id = ?',
        whereArgs: [compra.id],
      );

      for (final item in compra.items) {

        await txn.insert(
          'compra_items',
          item.toMap(),
        );

      }

    });

  }

  @override
  Future<void> updateEstado(
      String compraId,
      EstadoCompra estado,
      ) async {

    final db = await databaseHelper.database;

    await db.update(
      'compras',
      {
        'estado': estado.index,
      },
      where: 'id = ?',
      whereArgs: [compraId],
    );

  }

  @override
  Future<List<Compra>> getPendientesSincronizacion() async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'compras',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    final lista = <Compra>[];

    for (final row in result) {
      lista.add(await _mapCompra(db, row));
    }

    return lista;
  }

  @override
  Future<void> marcarSincronizado(String compraId) async {

    final db = await databaseHelper.database;

    await db.update(
      'compras',
      {
        'sync_status': 1,
      },
      where: 'id = ?',
      whereArgs: [compraId],
    );
  }
}

Future<Compra> _mapCompra(
    Database db,
    Map<String,dynamic> compraMap,
    ) async {

  final itemsResult = await db.query(
    'compra_items',
    where: 'compra_id = ?',
    whereArgs: [compraMap['id']],
  );

  final items = itemsResult
      .map(
        (e) => CompraItem.fromMap(e),
  )
      .toList();

  return Compra.fromMap(
    compraMap,
    items: items,
  );

}