import 'package:mi_almacen/models/Vale.dart';

abstract class ValeService {

  Future<void> aprobarVale(
      String valeId,
      String usuarioId,
      String usuarioNombre,
      String comentario,
      );

  Future<void> rechazarVale(
      String valeId,
      String usuarioId,
      String usuarioNombre,
      String comentario,
      );

  Future<void> actualizarVale(Vale vale);

  Future<List<Vale>> obtenerHistorial();

  Future<void> descargarVales() async {}

}