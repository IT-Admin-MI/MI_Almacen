
import 'package:mi_almacen/models/herramienta_prestamo.dart';

abstract class HerramientaSyncService {
  Future<bool> sincronizarHerramienta(HerramientaPrestamo herramienta);

  Future<void> sincronizarPendientes();

  Future<void> descargarHerramientas();
}