import 'dart:typed_data';

import 'package:mi_almacen/models/Material.dart';
import 'package:mi_almacen/models/Vale.dart';

abstract class ExcelService {

  Future<List<Material>> importarMateriales(
      String filePath,
      );

  Future<List<Material>> descargarEImportarMateriales();

  Future<Uint8List> exportarVales(List<Vale> vales);


}