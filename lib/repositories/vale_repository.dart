import '../models/Vale.dart';

abstract class ValeRepository {

  Future<void> insert(Vale vale);

  Future<void> update(Vale vale);

  Future<void> delete(String valeId);

  Future<Vale?> getById(String valeId);

  Future<List<Vale>> getAll();

  Future<List<Vale>> getPendientesSincronizacion();

  Future<List<Vale>> getPendientesValidacion();

  Future<List<Vale>> getPendientes();



  Future<List<Vale>> getPorUsuario(
      String usuarioNombre,
      );

  Future<void> marcarSincronizado(
      String valeId,
      );

  Future<void> updateEstado(String valeId, int i) async {}

  Future<List<Vale>> obtenerHistorial({required int rol, required String usuario, required String departamento,
  });

  Future<List<Vale>> getPendientesLiberacion();

  Future<void> actualizarLiberacionVale({
    required String valeId,
    required int liberado,
  });

  Future<List<Vale>> getHistorialLiberados();

}