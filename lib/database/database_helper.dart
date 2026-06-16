import 'package:mi_almacen/database/table_indexes.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';
import 'migrations.dart';
import 'table_scripts.dart';

class DatabaseHelper {

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
  DatabaseHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {

    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {

    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      DatabaseConstants.dbName,
    );

    return await openDatabase(
      path,
      version: DatabaseConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: Migrations.migrate,
    );
  }

  Future<void> _onCreate(
      Database db,
      int version,
      ) async {

    await db.execute(createUsuariosTable);
    await db.execute(createProyectosTable);
    await db.execute(createMaterialesTable);

    await db.execute(createValesTable);
    await db.execute(createValeItemsTable);
    await db.execute(createHistorialValesTable);

    await db.execute(createComprasTable);
    await db.execute(createCompraItemsTable);
    await db.execute(createHistorialComprasTable);

    await db.execute(createAppConfigTable);

    await db.execute(createMaterialesDescripcionIndex);
    await db.execute(createProyectosDescripcionIndex);

    await db.execute(createValesFechaIndex);
    await db.execute(createValesEstatusIndex);

    await db.execute(createComprasEstadoIndex);
    await db.execute(createComprasFechaSolicitudIndex);

    await db.execute(createHistorialValeFechaIndex);
    await db.execute(createHistorialCompraFechaIndex);

    await db.execute(createMaterialSyncIndex);
    await db.execute(createProyectoSyncIndex);
    await db.execute(createValeSyncIndex);
    await db.execute(createCompraSyncIndex);
  }
}