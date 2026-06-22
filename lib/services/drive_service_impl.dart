import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mi_almacen/services/drive_service.dart';
import 'package:path_provider/path_provider.dart';

class DriveServiceImpl
    implements DriveService {

  static const fileId =
      'TU_FILE_ID';

  @override
  Future<String> descargarExcelMateriales() async {

    final url =
        'https://drive.google.com/uc?export=download&id=1dzVB5Wagj0_JXqptDM2oEU11O71DayU5';

    final response =
    await http.get(
      Uri.parse(url),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo descargar el Excel',
      );
    }

    final dir =
    await getTemporaryDirectory();

    final file = File(
      '${dir.path}/materiales.xlsx',
    );

    await file.writeAsBytes(
      response.bodyBytes,
    );

    return file.path;
  }
}