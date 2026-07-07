import '../database/database_helper.dart';

class AdminRepository {
  final DatabaseHelper databaseHelper;

  AdminRepository({required this.databaseHelper});

  Future<List<Map<String, dynamic>>> obtenerFilas(
      String tabla, {
        String? orderBy,
      }) async {
    final db = await databaseHelper.database;
    return await db.query(tabla, orderBy: orderBy);
  }

  Future<void> actualizarFila({
    required String tabla,
    required String columnaId,
    required dynamic valorId,
    required Map<String, dynamic> valores,
  }) async {
    final db = await databaseHelper.database;
    await db.update(
      tabla,
      valores,
      where: '$columnaId = ?',
      whereArgs: [valorId],
    );
  }

  Future<void> eliminarFila({
    required String tabla,
    required String columnaId,
    required dynamic valorId,
  }) async {
    final db = await databaseHelper.database;
    await db.delete(
      tabla,
      where: '$columnaId = ?',
      whereArgs: [valorId],
    );
  }
}