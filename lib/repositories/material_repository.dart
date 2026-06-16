import 'package:flutter/material.dart';

abstract class MaterialRepository {

  Future<List<Material>> getAll();

  Future<Material?> getByClave(
      String clave,
      );

  Future<void> insert(
      Material material,
      );

  Future<void> update(
      Material material,
      );

  Future<void> delete(
      String clave,
      );

  Future<void> importarDesdeExcel(
      String filePath,
      );

  Future<void> sincronizarFirebase();
}