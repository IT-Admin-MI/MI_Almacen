import 'package:flutter/src/material/material.dart';
import 'package:mi_almacen/database/database_helper.dart';
import 'package:mi_almacen/repositories/material_repository.dart';
import 'package:mi_almacen/services/excel_service.dart';

class MaterialRepositoryImpl
implements MaterialRepository {

  final DatabaseHelper databaseHelper;

  final ExcelService excelService;

  MaterialRepositoryImpl({
    required this.databaseHelper,
    required this.excelService,
  });

  @override
  Future<void> delete(String clave) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<Material>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Material?> getByClave(String clave) {
    // TODO: implement getByClave
    throw UnimplementedError();
  }

  @override
  Future<void> importarDesdeExcel(String filePath) {
    // TODO: implement importarDesdeExcel
    throw UnimplementedError();
  }

  @override
  Future<void> insert(Material material) {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future<void> sincronizarFirebase() {
    // TODO: implement sincronizarFirebase
    throw UnimplementedError();
  }

  @override
  Future<void> update(Material material) {
    // TODO: implement update
    throw UnimplementedError();
  }

}