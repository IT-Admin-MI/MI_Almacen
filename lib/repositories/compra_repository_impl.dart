import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
import 'package:mi_almacen/models/compra_solicitud.dart';
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
  Future<void> deleteItems(
      String compraId) async {

    final db = await databaseHelper.database;

    await db.delete(
      'compra_items',
      where: 'compra_id = ?',
      whereArgs: [compraId],
    );
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
  Future<List<CompraItem>> getItems(
      String compraId) async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'compra_items',
      where: 'compra_id = ?',
      whereArgs: [compraId],
    );

    return result
        .map((e) => CompraItem.fromMap(e))
        .toList();
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
  Future<void> insertItems(
      List<CompraItem> items) async {

    final db = await databaseHelper.database;

    final batch = db.batch();

    for (final item in items) {
      batch.insert(
        'compra_items',
        item.toMap(),
      );
    }

    await batch.commit(
      noResult: true,
    );
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
  Future<void> updateEstado(String compraId, EstadoCompra estado) async {
    final db = await databaseHelper.database;
    await db.update(
      'compras',
      {
        'estado': estado.index,
        'sync_status': 0, // ← NUEVO: marca pendiente de subir
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

  @override
  Future<void> asociarCompra(
      String solicitudId,
      String compraId) async {

    final db = await databaseHelper.database;

    await db.update(
      'solicitudes_compra',
      {
        'compra_id': compraId,
        'estado': EstadoSolicitud.aprobada.index,
      },
      where: 'id = ?',
      whereArgs: [solicitudId],
    );
  }

  @override
  Future<void> deleteSolicitud(
      String id) async {

    final db = await databaseHelper.database;

    await db.delete(
      'solicitudes_compra',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<SolicitudCompra?>
  getSolicitudById(String id) async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'solicitudes_compra',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return SolicitudCompra.fromMap(
      result.first,
    );
  }

  @override
  Future<List<SolicitudCompra>>
  getSolicitudes() async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'solicitudes_compra',
      orderBy: 'fecha_solicitud DESC',
    );

    return result
        .map(
          (e) => SolicitudCompra.fromMap(e),
    )
        .toList();
  }

  @override
  Future<List<SolicitudCompra>>
  getSolicitudesPendientes() async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'solicitudes_compra',
      where: 'estado = ?',
      whereArgs: [
        EstadoSolicitud.pendiente.index
      ],
      orderBy: 'fecha_solicitud',
    );

    return result
        .map(
          (e) => SolicitudCompra.fromMap(e),
    )
        .toList();
  }

  @override
  Future<List<SolicitudCompra>>
  getSolicitudesPendientesSincronizacion() async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'solicitudes_compra',
      where: 'sync_status = ?',
      whereArgs: [0],
      orderBy: 'fecha_solicitud DESC',
    );

    return result
        .map((e) => SolicitudCompra.fromMap(e))
        .toList();
  }

  @override
  Future<List<Compra>> getVigentes() async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'compras',
      where: 'liberada = ?',
      whereArgs: [0],
      orderBy: 'fecha_solicitud DESC',
    );

    return Future.wait(
      result.map((e) => _mapCompra(db, e)),
    );
  }

  @override
  Future<void> insertSolicitud(
      SolicitudCompra solicitud) async {

    final db = await databaseHelper.database;

    await db.insert(
      'solicitudes_compra',
      solicitud.toMap(),
    );
  }

  @override
  Future<void> marcarSolicitudSincronizada(
      String solicitudId) async {

    final db = await databaseHelper.database;

    await db.update(
      'solicitudes_compra',
      {
        'sync_status': 1,
      },
      where: 'id = ?',
      whereArgs: [solicitudId],
    );
  }

  @override
  Future<void> updateEstadoSolicitud(
      String solicitudId,
      EstadoSolicitud estado, {
        String? motivoRechazo,
        String? compradorId,
      }) async {
    final db = await databaseHelper.database;

    await db.update(
      'solicitudes_compra',
      {
        'estado': estado.index,
        'motivo_rechazo': motivoRechazo,
        'comprador_id': compradorId,
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [solicitudId],
    );
  }
  @override
  Future<void> updateSolicitud(
      SolicitudCompra solicitud) async {

    final db = await databaseHelper.database;

    await db.update(
      'solicitudes_compra',
      solicitud.toMap(),
      where: 'id = ?',
      whereArgs: [solicitud.id],
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