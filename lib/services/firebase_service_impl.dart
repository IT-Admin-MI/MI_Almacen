import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
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
      departamento: data['departamento'],
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
        nombre: data['nombre'] ?? '',
        tipo: data['tipo'] ?? 0,
        fechaEntrega:
        data['fechaEntrega'] != null
            ? DateTime.parse(
          data['fechaEntrega'],
        ) : null,
        orden: data['orden'] ?? '',
        status: data['status']??true,
      );

    }).toList();
  }
  @override
  Future<void> guardarVale(Vale vale) async {
    final docRef = firestore.collection('vales').doc(vale.id);

    await docRef.set(vale.toMap());

    // Limpiar items anteriores para evitar duplicados al re-sincronizar
    final itemsExistentes = await docRef.collection('items').get();
    final batch = firestore.batch();

    for (final doc in itemsExistentes.docs) {
      batch.delete(doc.reference);
    }

    for (final item in vale.items) {
      final itemRef = docRef.collection('items').doc();
      batch.set(itemRef, {
        'material_codigo': item.material.codigo,
        'material_descripcion': item.material.descripcion,
        'proyecto_clave': item.proyecto?.clave,
        'proyecto_nombre': item.proyecto?.nombre,
        'cantidad': item.cantidad,
        'unidad': item.unidad,
        'comentario_vale': item.comentarioVale,
      });
    }

    await batch.commit();
  }
  @override
  Future<List<Vale>> obtenerVales() async {

    final snapshot =
    await firestore
        .collection('vales')
        .get();

    final lista = <Vale>[];

    for (final doc in snapshot.docs) {

      final data = doc.data();

      final itemsSnapshot =
      await doc.reference
          .collection('items')
          .get();

      final items = <ValeItem>[];

      for (final itemDoc in itemsSnapshot.docs) {

        final item = itemDoc.data();

        items.add(

          ValeItem(

            material: Material(
              codigo: item['material_codigo'].toString(),
              descripcion: item['material_descripcion'].toString(),
              existencia: 0,
              tipo: '',
              updatedAt: null,
              syncStatus: 0,
            ),

            proyecto: item['proyecto_clave'] != null
                ? Proyecto(
              clave: item['proyecto_clave'].toString(),
              nombre: item['proyecto_nombre'].toString(),
              orden: 0,
              status: true,
            )
                : null,

            cantidad:
            (item['cantidad'] as num).toDouble(),

            unidad:
            item['unidad'].toString(),

            comentarioVale:
            item['comentario_vale']?.toString() ?? '',
          ),
        );
      }

      lista.add(

        Vale(

          id: data['id'],

          fechaCreacion:
          DateTime.parse(
            data['fecha_creacion'],
          ),

          usuarioNombre:
          data['usuario_nombre'],

          usuarioRol:
          data['usuario_rol'],

          departamento:
          data['departamento'],

          estado:
          data['estado'],

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
          data['sync_status'] ?? 1,

          items: items,

          liberado:
          data['liberado'],
        ),
      );
    }

    return lista;
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

      final itemsSnapshot =
      await doc.reference
          .collection('items')
          .get();

      print(
        'VALE ${doc.id} -> ITEMS EN FIREBASE: ${itemsSnapshot.docs.length}',
      );

      for (final item in itemsSnapshot.docs) {
        print(item.data());
      }

      final items = <ValeItem>[];

      for (final itemDoc in itemsSnapshot.docs) {

        try {

          final item = itemDoc.data();

          final valeItem = ValeItem(

            material: Material(
              codigo: item['material_codigo'].toString(),
              descripcion: item['material_descripcion'].toString(),
              existencia: 0,
              tipo: '',
              updatedAt: null,
              syncStatus: 0,
            ),

            proyecto: item['proyecto_clave'] != null
                ? Proyecto(
              clave: item['proyecto_clave'].toString(),
              nombre: item['proyecto_nombre'].toString(),
              orden: 0,
              status: item['status'] as bool? ?? true,
            )
                : null,

            cantidad: (item['cantidad'] as num).toDouble(),

            unidad: item['unidad'].toString(),

            comentarioVale:
            item['comentario_vale']?.toString() ?? '',
          );

          items.add(valeItem);

        } catch (e) {
          print('ERROR ITEM: $e');
        }
      }
      print(
        'VALE ${data['id']} ITEMS CARGADOS: ${items.length}',
      );

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

          departamento:
          data['departamento'] ?? '',

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

          liberado:
          data['liberado'] ?? 0,
        ),
      );

      print(
        'VALE AGREGADO A LISTA: ${lista.last.items.length}',
      );
    }

    return lista;
  }

  @override
  Future<void> actualizarEstadoVale({
    required String id,
    required int estado,
    required String? comentario,
    required String? validadoPor,
  }) async {

    await firestore.collection('vales').doc(id).update({
      'estado': estado,
      'comentario_validacion': comentario,
      'validado_por': validadoPor,
      'fecha_validacion': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> actualizarProyecto(Proyecto proyecto) async {
    await firestore.collection('projects').doc(proyecto.clave).set({
      'codigo': proyecto.clave,
      'nombre': proyecto.nombre,
      'orden': proyecto.orden,
      'status': proyecto.status,
      'tipo':proyecto.tipo,
      'fechaEntrega': proyecto.fechaEntrega != null
          ? '${proyecto.fechaEntrega!.year}-'
          '${proyecto.fechaEntrega!.month.toString().padLeft(2, '0')}-'
          '${proyecto.fechaEntrega!.day.toString().padLeft(2, '0')}'
          : null,
    }, SetOptions(merge: true)); // ← set con merge, no update
  }

  @override
  Future<void> actualizarLiberacionVale({
    required String id,
    required int liberado,
  }) async {

    await firestore
        .collection('vales')
        .doc(id)
        .update({
      'liberado': liberado,
    });
  }

  @override
  Future<void> guardarCompra(Compra compra) async {

    final docRef = firestore
        .collection('compras')
        .doc(compra.id);

    await docRef.set(compra.toMap());

    // Eliminar items anteriores
    final itemsExistentes =
    await docRef.collection('items').get();

    final batch = firestore.batch();

    for (final doc in itemsExistentes.docs) {
      batch.delete(doc.reference);
    }

    // Guardar items
    for (final item in compra.items) {

      final itemRef =
      docRef.collection('items').doc();

      batch.set(itemRef, {
        'compra_id': item.compraId,
        'material_clave': item.materialClave,
        'nombre': item.nombre,
        'proyecto_clave': item.proyectoClave,
        'cantidad': item.cantidad,
        'unidad': item.unidad,
      });
    }

    await batch.commit();
  }

  @override
  Future<List<Compra>> obtenerCompras() async {
    final snapshot =
        await firestore.collection('compras').get();

    final compras = <Compra>[];

    for (final doc in snapshot.docs) {

      final data = doc.data();

      final itemsSnapshot =
          await doc.reference
          .collection('items')
          .get();

      final items = <CompraItem>[];

      for (final itemDoc in itemsSnapshot.docs) {

        final item = itemDoc.data();

        items.add(

          CompraItem(

            id: itemDoc.id,

            compraId:
            item['compra_id'] ?? '',

            materialClave:
            item['material_clave'],

            nombre:
            item['nombre'] ?? '',

            proyectoClave:
            item['proyecto_clave'],

            cantidad:
            (item['cantidad'] as num).toDouble(),

            unidad:
            item['unidad'] ?? '',
          ),
        );
      }

      compras.add(

        Compra(

          id:
          data['id'],

          nombre:
          data['nombre'] ?? '',

          descripcion:
          data['descripcion'],

          ordenCompra:
          data['orden_compra'] ?? '',

          fechaSolicitud:
          DateTime.parse(
            data['fecha_solicitud'],
          ),

          fechaEntrega:
          data['fecha_entrega'] != null
              ? DateTime.parse(
            data['fecha_entrega'],
          )
              : null,

          estado:
          EstadoCompra.values[
          data['estado']],

          estatus:
          data['estatus'] ?? 0,

          items: items,
          sync_status: data['sync_status']??0,
        ),
      );
    }

    return compras;
  }

}