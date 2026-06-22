

import 'package:mi_almacen/database/database_helper.dart';
import 'package:mi_almacen/models/Material.dart';
import 'package:mi_almacen/repositories/material_repository.dart';
import 'package:mi_almacen/services/excel_service_impl.dart';
import 'package:sqflite/sqflite.dart';

class MaterialRepositoryImpl
    implements MaterialRepository {

  final DatabaseHelper databaseHelper;

  final ExcelServiceImpl excelService;

  MaterialRepositoryImpl({
    required this.databaseHelper,
    required this.excelService,
  });

  @override
  Future<List<Material>> getAll() async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'materiales',
      orderBy: 'descripcion',
    );

    return result
        .map(
          (e) => Material.fromMap(e),
    )
        .toList();
  }

  @override
  Future<Material?> getByCodigo(
      String codigo,
      ) async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'materiales',
      where: 'codigo = ?',
      whereArgs: [codigo],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Material.fromMap(
      result.first,
    );
  }

  @override
  Future<void> insert(
      Material material,
      ) async {

    final db =
    await databaseHelper.database;

    await db.insert(
      'materiales',
      material.toMap(),
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(
      Material material,
      ) async {

    final db =
    await databaseHelper.database;

    await db.update(
      'materiales',
      material.toMap(),
      where: 'codigo = ?',
      whereArgs: [material.codigo],
    );
  }

  @override
  Future<void> delete(
      String codigo,
      ) async {

    final db =
    await databaseHelper.database;

    await db.delete(
      'materiales',
      where: 'codigo = ?',
      whereArgs: [codigo],
    );
  }
  @override
  Future<void> importarDesdeExcel(
      String filePath,
      ) async {

    final materiales =
    await excelService
        .importarMateriales(
      filePath,
    );

    final db =
    await databaseHelper.database;

    final batch =
    db.batch();

    for (final material in materiales) {

      batch.insert(
        'materiales',
        material.toMap(),
        conflictAlgorithm:
        ConflictAlgorithm.replace,
      );
    }

    await batch.commit(
      noResult: true,
    );
  }

  @override
  Future<void> sincronizarDrive() async {

    final materiales =
    await excelService
        .descargarEImportarMateriales();

    print(
      'MATERIALES LEIDOS DEL EXCEL: ${materiales.length}',
    );

    final db =
    await databaseHelper.database;

    final batch =
    db.batch();

    await db.delete(
      'materiales',
    );

    for (final material in materiales) {

      batch.insert(
        'materiales',
        material.toMap(),
        conflictAlgorithm:
        ConflictAlgorithm.replace,
      );
    }

    await batch.commit(
      noResult: true,
    );


  }

  @override
  Future<List<Material>> buscar(
      String texto,
      ) async {

    final db =
    await databaseHelper.database;

    if (texto.trim().isEmpty) {
      return [];
    }

    final result =
    await db.query(
      'materiales',
      where:
      'codigo LIKE ? OR descripcion LIKE ?',
      whereArgs: [
        '%$texto%',
        '%$texto%',
      ],
      orderBy: 'descripcion',
      limit: 50,
    );

    return result
        .map(
          (e) => Material.fromMap(e),
    )
        .toList();
  }
}