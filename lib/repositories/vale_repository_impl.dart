import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/Material.dart';
import '../models/Proyecto.dart';
import '../models/Vale.dart';
import '../models/Vale_Item.dart';
import 'vale_repository.dart';

class ValeRepositoryImpl
    implements ValeRepository {

  final DatabaseHelper databaseHelper;


  ValeRepositoryImpl({
    required this.databaseHelper,
  });

  @override
  Future<void> insert(
      Vale vale,
      ) async {

    final db =
    await databaseHelper.database;

    await db.transaction((txn) async {

      await txn.insert(
        'vales',
        vale.toMap(),
      );

      for (final item in vale.items) {

        await txn.insert(
          'vale_items',
          {
            'vale_id': vale.id,
            'material_codigo':
            item.material.codigo,
            'material_descripcion':
            item.material.descripcion,
            'proyecto_clave':
            item.proyecto?.clave,
            'proyecto_nombre':
            item.proyecto?.nombre,
            'cantidad':
            item.cantidad,
            'unidad':
            item.unidad,
          },
        );
      }

    });
  }

  @override
  Future<void> update(
      Vale vale,
      ) async {

    final db =
    await databaseHelper.database;

    await db.transaction((txn) async {

      await txn.update(
        'vales',
        vale.toMap(),
        where: 'id = ?',
        whereArgs: [vale.id],
      );

      await txn.delete(
        'vale_items',
        where: 'vale_id = ?',
        whereArgs: [vale.id],
      );

      for (final item in vale.items) {

        await txn.insert(
          'vale_items',
          {
            'vale_id': vale.id,
            'material_codigo':
            item.material.codigo,
            'material_descripcion':
            item.material.descripcion,
            'proyecto_clave':
            item.proyecto?.clave,
            'proyecto_nombre':
            item.proyecto?.nombre,
            'cantidad':
            item.cantidad,
            'unidad':
            item.unidad,
          },
        );
      }
    });
  }

  @override
  Future<void> delete(
      String valeId,
      ) async {

    final db =
    await databaseHelper.database;

    await db.transaction((txn) async {

      await txn.delete(
        'vale_items',
        where: 'vale_id = ?',
        whereArgs: [valeId],
      );

      await txn.delete(
        'vales',
        where: 'id = ?',
        whereArgs: [valeId],
      );
    });
  }

  @override
  Future<Vale?> getById(
      String valeId,
      ) async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'vales',
      where: 'id = ?',
      whereArgs: [valeId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return await _mapVale(
      db,
      result.first,
    );
  }

  @override
  Future<List<Vale>> getAll() async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'vales',
      orderBy:
      'fecha_creacion DESC',
    );

    final lista =
    <Vale>[];

    for (final row in result) {

      lista.add(
        await _mapVale(
          db,
          row,
        ),
      );
    }

    return lista;
  }

  Future<void> updateEstado(String valeId, int estado) async {

    final db = await databaseHelper.database;

    await db.update(
      'vales',
      {
        'estado': estado,
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [valeId],
    );
  }

  Future<List<Vale>> getPendientesFirebase() {
    // TODO: implement getPendientesFirebase
    throw UnimplementedError();
  }

  @override
  Future<List<Vale>>
  getPendientesSincronizacion()
  async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'vales',
      where:
      'sync_status = ?',
      whereArgs: [0],
    );

    final lista =
    <Vale>[];

    for (final row in result) {

      lista.add(
        await _mapVale(
          db,
          row,
        ),
      );
    }

    return lista;
  }

  @override
  Future<List<Vale>>
  getPendientesValidacion()
  async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'vales',
      where:
      'estado = ?',
      whereArgs: [0],
      orderBy:
      'fecha_creacion DESC',
    );

    final lista =
    <Vale>[];

    for (final row in result) {

      lista.add(
        await _mapVale(
          db,
          row,
        ),
      );
    }

    return lista;
  }

  @override
  Future<List<Vale>>
  getPorUsuario(
      String usuarioNombre,
      ) async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'vales',
      where:
      'usuario_nombre = ?',
      whereArgs: [usuarioNombre],
    );

    final lista =
    <Vale>[];

    for (final row in result) {

      lista.add(
        await _mapVale(
          db,
          row,
        ),
      );
    }

    return lista;
  }

  @override
  Future<void>
  marcarSincronizado(
      String valeId,
      ) async {

    final db =
    await databaseHelper.database;

    await db.update(
      'vales',
      {
        'sync_status': 1,
      },
      where: 'id = ?',
      whereArgs: [valeId],
    );
  }

  Future<Vale> _mapVale(
      Database db,
      Map<String, dynamic> valeMap,
      ) async {

    final itemsResult =
    await db.query(
      'vale_items',
      where: 'vale_id = ?',
      whereArgs: [valeMap['id']],
    );

    print('VALE ID: ${valeMap['id']}');
    print('ITEMS EN BD: $itemsResult');
    final items =
    itemsResult.map((item) {

      return ValeItem(
        material: Material(
          codigo:
          item['material_codigo']
          as String,
          descripcion:
          item['material_descripcion']
          as String,
          existencia: 0,
          tipo: '', updatedAt: null, syncStatus: null,
        ),
        proyecto:
        item['proyecto_clave'] ==
            null
            ? null
            : Proyecto(
          clave:
          item['proyecto_clave']
          as String,
          nombre:
          item['proyecto_nombre']
          as String,
          orden: 0,
        ),
        cantidad:
        (item['cantidad']
        as num)
            .toDouble(),
        unidad:
        item['unidad']
        as String,
      );
    }).toList();

    return Vale.fromMap(
      valeMap,
      items,
    );
  }

  @override
  Future<List<Vale>> getPendientes() async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'vales',
      where: 'estado = ?',
      whereArgs: [0],
      orderBy: 'fecha_creacion DESC',
    );

    final lista = <Vale>[];

    for (final row in result) {

      lista.add(
        await _mapVale(
          db,
          row,
        ),
      );
    }

    return lista;
  }
}