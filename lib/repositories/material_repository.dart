import '../models/Material.dart';

abstract class MaterialRepository {

  Future<List<Material>> getAll();

  Future<Material?> getByCodigo(
      String codigo,
      );

  Future<void> insert(
      Material material,
      );

  Future<void> update(
      Material material,
      );

  Future<void> delete(
      String codigo,
      );

  Future<void> importarDesdeExcel(
      String filePath,
      );

}