import '../models/Usuario.dart';

abstract class UsuarioRepository {

  Future<List<Usuario>> getAll();

  Future<Usuario?> getById(
      int id,
      );

  Future<Usuario?> getByNombre(
      String nombre,
      );

  Future<void> insert(
      Usuario usuario,
      );

  Future<void> update(
      Usuario usuario,
      );

  Future<void> delete(
      int id,
      );

}