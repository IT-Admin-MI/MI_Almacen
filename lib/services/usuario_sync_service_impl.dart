import 'package:mi_almacen/repositories/usuario_repository.dart';

import 'firebase_service.dart';
import 'usuario_sync_service.dart';

class UsuarioSyncServiceImpl implements UsuarioSyncService {
  final FirebaseService firebaseService;
  final UsuarioRepository usuarioRepository;

  UsuarioSyncServiceImpl({
    required this.firebaseService,
    required this.usuarioRepository,
  });

  @override
  Future<void> descargarUsuarios() async {
    final usuarios = await firebaseService.obtenerUsuarios();
    await usuarioRepository.reemplazarUsuarios(usuarios);
  }
}