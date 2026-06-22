import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_almacen/models/Material.dart';
import 'package:mi_almacen/models/Vale.dart';
import 'package:mi_almacen/models/Vale_Item.dart';

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
      id: null,
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

  @override
  Future<void> guardarVale(
      Vale vale,
      ) async {

    final docRef =
    firestore
        .collection('vales')
        .doc(vale.id);

    await docRef.set(
      vale.toMap(),
    );

    final batch =
    firestore.batch();

    for (final item in vale.items) {

      final itemRef =
      docRef
          .collection('items')
          .doc();

      batch.set(
        itemRef,
        {
          'material_codigo':
          item.material.codigo,

          'material_descripcion':
          item.material.descripcion,

          'proyecto_clave':
          item.proyecto?.clave,

          'proyecto_nombre':
          item.proyecto?.nombre,

          'cantidad':
          item.cantidad,

          'unidad':
          item.unidad,
        },
      );
    }

    await batch.commit();
  }

  @override
  Future<List<Vale>> obtenerVales() {
    // TODO: implement obtenerVales
    throw UnimplementedError();
  }

  Future<List<Vale>> obtenerValesPendientes() async {

    final snapshot =
    await FirebaseFirestore.instance
        .collection('vales')
        .where('estado', isEqualTo: 0)
        .get();

    final lista = <Vale>[];

    for (final doc in snapshot.docs) {

      final data = doc.data();

      print('VALE FIREBASE: $data');

      final items = <ValeItem>[];

      if (data['items'] != null) {

        for (final item in data['items']) {

          items.add(

            ValeItem(

              material: Material(
                codigo:
                item['materialCodigo'] ?? '',
                descripcion:
                item['materialDescripcion'] ?? '',
                existencia: 0,
                tipo: '',
                updatedAt: null,
                syncStatus: 0,
              ),

              proyecto:
              item['proyectoClave'] != null

                  ? Proyecto(
                clave:
                item['proyectoClave'],
                nombre:
                item['proyectoNombre'] ?? '',
                orden: 0,
              )

                  : null,

              cantidad:
              (item['cantidad'] as num)
                  .toDouble(),

              unidad:
              item['unidad'] ?? '',
            ),
          );
        }
      }

      lista.add(

        Vale(
          id:
          data['id'] ?? '',

          fechaCreacion:
          DateTime.parse(
            data['fecha_creacion'],
          ),

          usuarioNombre:
          data['usuario_nombre'] ?? '',

          usuarioRol:
          data['usuario_rol'] ?? 0,

          estado:
          data['estado'] ?? 0,

          fechaValidacion:
          data['fecha_validacion'] != null
              ? DateTime.parse(
            data['fecha_validacion'],
          )
              : null,

          validadoPor:
          data['validado_por'],

          comentarioValidacion:
          data['comentario_validacion'],

          syncStatus:
          data['sync_status'] ?? 0,

          items: items,
        ),
      );
    }

    return lista;
  }
}