import '../database/database_helper.dart';
import '../models/Historial_Vale.dart';
import 'historial_vale_repository.dart';

class HistorialValeRepositoryImpl
    implements HistorialValeRepository {

  final DatabaseHelper databaseHelper;

  HistorialValeRepositoryImpl({
    required this.databaseHelper,
  });

  @override
  Future<void> insert(
      HistorialVale historial,
      ) async {

    final db =
    await databaseHelper.database;

    await db.insert(
      'historial_vales',
      historial.toMap(),
    );
  }

  @override
  Future<List<HistorialVale>>
  getPorVale(
      String valeId,
      ) async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'historial_vales',
      where: 'vale_id = ?',
      whereArgs: [valeId],
      orderBy: 'fecha DESC',
    );

    return result
        .map(
          (e) =>
          HistorialVale.fromMap(e),
    )
        .toList();
  }
}