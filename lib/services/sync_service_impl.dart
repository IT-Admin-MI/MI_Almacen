import '../repositories/proyecto_repository.dart';
import 'sync_service.dart';

class SyncServiceImpl
    implements SyncService {

  final ProyectoRepository
  proyectoRepository;

  SyncServiceImpl({
    required this.proyectoRepository,
  });

  @override
  Future<void> sincronizarTodo() async {

    await sincronizarProyectos();
  }

  @override
  Future<void> sincronizarProyectos() async {

    await proyectoRepository
        .sincronizarFirebase();
  }
}