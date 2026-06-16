import '../database/database_helper.dart';
import '../models/Usuario.dart';
import 'usuario_repository.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {

  final DatabaseHelper databaseHelper;

  UsuarioRepositoryImpl({
    required this.databaseHelper,
  });

  @override
  Future<List<Usuario>> getAll() async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'usuarios',
      orderBy: 'nombre',
    );

    return result
        .map((e) => Usuario.fromMap(e))
        .toList();
  }

  @override
  Future<Usuario?> getById(int id) async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Usuario.fromMap(result.first);
  }

  @override
  Future<Usuario?> getByNombre(
      String nombre,
      ) async {

    final db = await databaseHelper.database;

    final result = await db.query(
      'usuarios',
      where: 'nombre = ?',
      whereArgs: [nombre],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Usuario.fromMap(result.first);
  }

  @override
  Future<void> insert(
      Usuario usuario,
      ) async {

    final db = await databaseHelper.database;

    await db.insert(
      'usuarios',
      usuario.toMap(),
    );
  }

  @override
  Future<void> update(
      Usuario usuario,
      ) async {

    final db = await databaseHelper.database;

    await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  @override
  Future<void> delete(
      int id,
      ) async {

    final db = await databaseHelper.database;

    await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}