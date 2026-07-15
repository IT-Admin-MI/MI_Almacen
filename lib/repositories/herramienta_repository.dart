import 'package:mi_almacen/models/herramienta_prestamo.dart';

abstract class HerramientaRepository {
  Future<List<HerramientaPrestamo>> getAll();

  Future<HerramientaPrestamo?> getById(String id);

  Future<void> insert(HerramientaPrestamo herramienta);

  Future<void> update(HerramientaPrestamo herramienta);

  Future<void> delete(String id);

  Future<List<HerramientaPrestamo>> getPrestadas();

  Future<List<HerramientaPrestamo>> getPorUsuario(String usuarioId);

  Future<List<HerramientaPrestamo>> getPendientesSincronizacion();

  Future<void> marcarSincronizado(String id);
}