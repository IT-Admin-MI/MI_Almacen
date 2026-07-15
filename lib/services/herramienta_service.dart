import 'package:mi_almacen/models/herramienta_prestamo.dart';

abstract class HerramientaService {
  Future<void> registrarPrestamo(HerramientaPrestamo herramienta);

  Future<void> registrarDevolucion({
    required String id,
    required String recibidoPorId,
    required String recibidoPorNombre,
  });

  Future<void> actualizarHerramienta(HerramientaPrestamo herramienta);

  Future<void> eliminarHerramienta(String id);

  Future<List<HerramientaPrestamo>> obtenerTodas();

  Future<List<HerramientaPrestamo>> obtenerPrestadas();
}