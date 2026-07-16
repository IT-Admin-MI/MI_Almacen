import 'package:mi_almacen/database/table_indexes.dart';
import 'package:sqflite/sqflite.dart';
import 'table_scripts.dart';

class Migrations {

  static Future<void> migrate(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {

    if (oldVersion < 2) {
      await _migrarCompraItemsAIdTexto(db);
    }
  }

  static Future<void> _migrarCompraItemsAIdTexto(Database db) async {

    await db.execute(
      'ALTER TABLE compra_items RENAME TO compra_items_old',
    );

    await db.execute(createCompraItemsTable);

    await db.execute('''
      INSERT INTO compra_items (id, compra_id, material_clave, nombre, proyecto_clave, cantidad, unidad, observaciones, numero_parte)
      SELECT CAST(id AS TEXT), compra_id, material_clave, nombre, proyecto_clave, cantidad, unidad, observaciones, numero_parte
      FROM compra_items_old
    ''');

    await db.execute('DROP TABLE compra_items_old');

    // El índice apuntaba a la tabla vieja; se recrea sobre la nueva.
    await db.execute('DROP INDEX IF EXISTS idx_compra_items_compra_id');
    await db.execute(createCompraItemsCompraIdIndex);
  }
}