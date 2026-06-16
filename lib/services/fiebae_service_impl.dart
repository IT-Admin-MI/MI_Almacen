import '../models/Proyecto.dart';
import '../models/Usuario.dart';
import 'firebase_service.dart';

class FirebaseServiceImpl implements FirebaseService {

  @override
  Future<Usuario?> login(
      String nombre,
      String password,
      ) async {

    throw UnimplementedError();
  }

  @override
  Future<List<Proyecto>> obtenerProyectos() async {

    throw UnimplementedError();
  }
}