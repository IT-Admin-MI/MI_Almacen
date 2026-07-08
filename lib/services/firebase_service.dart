import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/Vale.dart';

import '../models/Proyecto.dart';
import '../models/Usuario.dart';

abstract class FirebaseService {

  Future<Usuario?> login(
      String nombre,
      String password,
      );

  Future<List<Proyecto>> obtenerProyectos();

  Future<void> guardarVale(
      Vale vale,
      );

  Future<List<Vale>> obtenerVales();

  Future<List<Vale>> obtenerValesPendientes();

  Future<void> actualizarProyecto(Proyecto proyecto);

  Future<void> actualizarLiberacionVale({
    required String id,
    required int liberado,
  });

  Future<void> guardarCompra(Compra compra);

  Future<List<Compra>> obtenerCompras();

}