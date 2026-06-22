abstract class ValeService {

  Future<void> aprobarVale(
      String valeId,
      int usuarioId,
      String usuarioNombre,
      String comentario,
      );

  Future<void> rechazarVale(
      String valeId,
      int usuarioId,
      String usuarioNombre,
      String comentario,
      );

}