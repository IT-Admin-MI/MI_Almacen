import '../models/Proyecto.dart';

abstract class ProyectoRepository {

  Future<List<Proyecto>> getAll();

  Future<Proyecto?> getByClave(
      String clave,
      );

  Future<void> insert(
      Proyecto proyecto,
      );

  Future<void> update(
      Proyecto proyecto,
      );

  Future<void> delete(
      String clave,
      );

  Future<void> sincronizarFirebase();
}