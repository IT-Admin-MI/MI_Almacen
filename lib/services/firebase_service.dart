import '../models/Proyecto.dart';
import '../models/Usuario.dart';

abstract class FirebaseService {

  Future<Usuario?> login(
      String nombre,
      String password,
      );

  Future<List<Proyecto>> obtenerProyectos();

}