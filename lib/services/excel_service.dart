

import 'package:mi_almacen/models/Material.dart';

abstract class ExcelService {

  Future<List<Material>> importarMateriales(
      String filePath,
      );

}