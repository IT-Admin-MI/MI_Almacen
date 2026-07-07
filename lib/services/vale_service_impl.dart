import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_almacen/database/database_helper.dart';
import 'package:mi_almacen/models/Vale.dart';
import 'package:mi_almacen/services/auth_service.dart';
import 'package:mi_almacen/services/firebase_service_impl.dart';
import 'package:mi_almacen/services/vale_service.dart';
import 'package:mi_almacen/repositories/vale_repository.dart';
import '../models/Vale_estado.dart';

class ValeServiceImpl implements ValeService {

  final ValeRepository valeRepository;
  final DatabaseHelper databaseHelper;
  final FirebaseServiceImpl firebaseService;
  final AuthService authService;

  ValeServiceImpl({
    required this.valeRepository,
    required this.databaseHelper,
    required this.firebaseService,
    required this.authService,
  });

  @override
  Future<void> aprobarVale(
      String valeId,
      int usuarioId,
      String usuarioNombre,
      String comentario,
      ) async {

    await firebaseService.actualizarEstadoVale(
      id: valeId,
      estado: 1,
      comentario: comentario,
      validadoPor: usuarioNombre,
    );

    await valeRepository.updateEstado(valeId, 1);
  }
  @override
  Future<void> rechazarVale(
      String valeId,
      int usuarioId,
      String usuarioNombre,
      String comentario,
      ) async {

    await firebaseService.actualizarEstadoVale(
      id: valeId,
      estado: 2,
      comentario: comentario,
      validadoPor: usuarioNombre,
    );

    await valeRepository.updateEstado(valeId, 2);
  }
  Future<void> _actualizarEstado({
    required String valeId,
    required int estado,
    required String usuarioNombre,
    required String comentario,
  }) async {

    final db = await databaseHelper.database;

    await db.update(

      'vales',
      {
        'estado': estado,
        'validado_por': usuarioNombre,
        'comentario_validacion': comentario,
        'fecha_validacion': DateTime.now().toIso8601String(),
        'sync_status': 0, // pendiente de sincronizar
      },
      where: 'id = ?',
      whereArgs: [valeId],
    );

    // opcional: marcar sync o disparar sync service aquí
  }

  @override
  Future<void> actualizarVale(Vale vale) async {
    await valeRepository.update(vale);

    await firebaseService.firestore
        .collection('vales')
        .doc(vale.id)
        .set(vale.toMap(), SetOptions(merge: true));

    await firebaseService.firestore
        .collection('vales')
        .doc(vale.id)
        .update(vale.toMap());

    final ref = firebaseService.firestore
        .collection('vales')
        .doc(vale.id)
        .collection('items');

    final batch = firebaseService.firestore.batch();

    final oldItems = await ref.get();

    for (final doc in oldItems.docs) {
      batch.delete(doc.reference);
    }

    for (final item in vale.items) {
      final doc = ref.doc();

      batch.set(doc, {
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
  Future<List<Vale>> obtenerHistorial() async {

    final usuario = await authService.usuarioActual();

    print('===== OBTENER HISTORIAL =====');
    print(usuario?.nombre);
    print(usuario?.rol);
    print(usuario?.departamento);

    if (usuario == null) {
      return [];
    }

    return valeRepository.obtenerHistorial(
      rol: usuario.rol,
      usuario: usuario.nombre,
      departamento: usuario.departamento,
    );
  }

  @override
  Future<void> descargarVales() {
    // TODO: implement descargarVales
    throw UnimplementedError();
  }
}