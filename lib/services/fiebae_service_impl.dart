import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Proyecto.dart';
import '../models/Usuario.dart';
import 'firebase_service.dart';

class FirebaseServiceImpl implements FirebaseService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  @override
  Future<Usuario?> login(
      String nombre,
      String password,
      ) async {

    final result =
    await firestore
        .collection('usuarios')
        .where(
      'nombre',
      isEqualTo: nombre,
    )
        .where(
      'activo',
      isEqualTo: true,
    )
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    final data =
    result.docs.first.data();

    if (data['password'] != password) {
      return null;
    }

    return Usuario(
      nombre: data['nombre'],
      password: data['password'],
      descripcion: data['descripcion'],
      rol: data['rol'],
    );
  }

  @override
  Future<List<Proyecto>> obtenerProyectos() async {

    final result =
    await firestore
        .collection('projects')
        .get();

    return result.docs.map((doc) {

      final data = doc.data();

      return Proyecto(
        clave: data['codigo'] ?? '',
        descripcion:
        data['nombre'] ?? '',
        fecha_entrega:
        DateTime.parse(
          data['fechaEntrega'],
        ),
      );

    }).toList();
  }
}