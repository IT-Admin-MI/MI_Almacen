abstract class SyncService {

  Future<void> sincronizarTodo();

  Future<void> sincronizarProyectos();

  Future<void> sincronizarVales();

  Future<void> sincronizarCompras();

  Future<void> sincronizarMateriales();

  Future<void> sincronizarUsuarios();
}