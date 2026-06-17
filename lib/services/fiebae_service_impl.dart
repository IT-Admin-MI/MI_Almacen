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
    print('LOGIN FIREBASE INICIO');
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
    print('DOCUMENTOS ENCONTRADOS: ${result.docs.length}');
    if (result.docs.isEmpty) {
      print('USUARIO NO ENCONTRADO');
      return null;
    }

    final data =
    result.docs.first.data();
    print('DATOS FIREBASE: $data');
    if (data['password'] != password) {
      return null;
    }
    print('LOGIN CORRECTO');
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

    print(
      'PROYECTOS FIREBASE: ${result.docs.length}',
    );

    return result.docs.map((doc) {

      final data = doc.data();
      print(data);

      return Proyecto(
        clave: data['codigo'] ?? '',
        nombre:
        data['nombre'] ?? '',
        fechaEntrega:
        data['fechaEntrega'] != null
            ? DateTime.parse(
          data['fechaEntrega'],
        ) : null,
        orden: data['orden'] ?? '',
      );

    }).toList();
  }
}