import 'package:mi_almacen/models/herramienta_prestamo.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import 'herramienta_repository.dart';

class HerramientaRepositoryImpl implements HerramientaRepository {
  final DatabaseHelper databaseHelper;

  HerramientaRepositoryImpl({required this.databaseHelper});

  @override
  Future<List<HerramientaPrestamo>> getAll() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'herramientas_prestamo',
      orderBy: 'fecha_prestamo DESC',
    );

    return result.map((e) => HerramientaPrestamo.fromMap(e)).toList();
  }

  @override
  Future<HerramientaPrestamo?> getById(String id) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'herramientas_prestamo',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return HerramientaPrestamo.fromMap(result.first);
  }

  @override
  Future<void> insert(HerramientaPrestamo herramienta) async {
    final db = await databaseHelper.database;

    await db.insert(
      'herramientas_prestamo',
      herramienta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(HerramientaPrestamo herramienta) async {
    final db = await databaseHelper.database;

    await db.update(
      'herramientas_prestamo',
      herramienta.toMap(),
      where: 'id = ?',
      whereArgs: [herramienta.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await databaseHelper.database;

    await db.delete(
      'herramientas_prestamo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<HerramientaPrestamo>> getPrestadas() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'herramientas_prestamo',
      where: 'estado = ?',
      whereArgs: [0],
      orderBy: 'fecha_prestamo DESC',
    );

    return result.map((e) => HerramientaPrestamo.fromMap(e)).toList();
  }

  @override
  Future<List<HerramientaPrestamo>> getPorUsuario(String usuarioId) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'herramientas_prestamo',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha_prestamo DESC',
    );

    return result.map((e) => HerramientaPrestamo.fromMap(e)).toList();
  }

  @override
  Future<List<HerramientaPrestamo>> getPendientesSincronizacion() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'herramientas_prestamo',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    return result.map((e) => HerramientaPrestamo.fromMap(e)).toList();
  }

  @override
  Future<void> marcarSincronizado(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'herramientas_prestamo',
      {'sync_status': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}