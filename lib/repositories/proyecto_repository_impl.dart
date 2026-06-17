import 'package:mi_almacen/services/firebase_service.dart';

import '../database/database_helper.dart';
import '../models/Proyecto.dart';
import 'proyecto_repository.dart';

class ProyectoRepositoryImpl
    implements ProyectoRepository {

  final DatabaseHelper databaseHelper;
  final FirebaseService firebaseService;


  ProyectoRepositoryImpl({
    required this.databaseHelper,
    required this.firebaseService,
  });



  @override
  Future<List<Proyecto>> getAll() async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'proyectos',
      orderBy: 'orden',
    );

    return result
        .map(
          (e) => Proyecto.fromMap(e),
    )
        .toList();
  }

  @override
  Future<Proyecto?> getByClave(
      String clave,
      ) async {

    final db =
    await databaseHelper.database;

    final result =
    await db.query(
      'proyectos',
      where: 'clave = ?',
      whereArgs: [clave],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Proyecto.fromMap(
      result.first,
    );
  }

  @override
  Future<void> insert(
      Proyecto proyecto,
      ) async {

    final db =
    await databaseHelper.database;

    await db.insert(
      'proyectos',
      proyecto.toMap(),
    );
  }

  @override
  Future<void> update(
      Proyecto proyecto,
      ) async {

    final db =
    await databaseHelper.database;

    await db.update(
      'proyectos',
      proyecto.toMap(),
      where: 'clave = ?',
      whereArgs: [proyecto.clave],
    );
  }

  @override
  Future<void> delete(
      String clave,
      ) async {

    final db =
    await databaseHelper.database;

    await db.delete(
      'proyectos',
      where: 'clave = ?',
      whereArgs: [clave],
    );
  }

  @override
  Future<void> sincronizarFirebase() async {

    print('SINCRONIZANDO FIREBASE');
    final proyectos =
    await firebaseService
        .obtenerProyectos();

    print(
      'PROYECTOS RECIBIDOS: ${proyectos.length}',
    );
    for (final proyecto in proyectos) {

      final existente =
      await getByClave(
        proyecto.clave,
      );

      if (existente == null) {

        await insert(
          proyecto,
        );

      } else {

        await update(
          proyecto,
        );
      }
    }
  }

}