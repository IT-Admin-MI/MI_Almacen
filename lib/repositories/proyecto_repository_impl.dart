import 'package:cloud_firestore/cloud_firestore.dart';
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

    print('TOTAL SQLITE: ${result.length}');

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
    final proyectosFirebase = await firebaseService.obtenerProyectos();
    final clavesFirebase = proyectosFirebase.map((p) => p.clave).toSet();

    for (final proyecto in proyectosFirebase) {
      final existente = await getByClave(proyecto.clave);
      if (existente == null) {
        await insert(proyecto);
      } else {
        await update(proyecto);
      }
    }

    // Espejo: borrar localmente los proyectos que ya no existen en Firebase.
    final proyectosLocales = await getAll();

    for (final local in proyectosLocales) {
      if (!clavesFirebase.contains(local.clave)) {
        await delete(local.clave);
      }
    }
  }
  @override
  Future<void> sincronizarProyectoFirebase(Proyecto proyecto) async {
    await firebaseService.actualizarProyecto(proyecto);
  }

  @override
  Future<void> sincronizarListaProyectos(List<Proyecto> proyectos) async {
    final batch = FirebaseFirestore.instance.batch();
    final ref = FirebaseFirestore.instance.collection('projects');

    for (final p in proyectos) {
      final doc = ref.doc(p.clave);

      batch.set(doc, {
        'codigo': p.clave,
        'nombre': p.nombre,
        'orden': p.orden,
        'status': p.status,
        'fechaEntrega': p.fechaEntrega != null
            ? '${p.fechaEntrega!.year}-'
            '${p.fechaEntrega!.month.toString().padLeft(2, '0')}-'
            '${p.fechaEntrega!.day.toString().padLeft(2, '0')}'
            : null,
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
