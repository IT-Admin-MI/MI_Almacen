import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../models/Material.dart';
import 'excel_service.dart';
class ExcelServiceImpl implements ExcelService {

  static const String excelUrl =
      'https://drive.google.com/uc?export=download&id=1dzVB5Wagj0_JXqptDM2oEU11O71DayU5';

  @override
  Future<List<Material>> descargarEImportarMateriales() async {

    final response =
    await http.get(
      Uri.parse(excelUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo descargar el Excel',
      );
    }

    final tempDir =
    await getTemporaryDirectory();

    final file = File(
      '${tempDir.path}/materiales.xlsx',
    );

    await file.writeAsBytes(
      response.bodyBytes,
    );

    return importarMateriales(
      file.path,
    );
  }

  @override
  Future<List<Material>> importarMateriales(
      String filePath,
      ) async {

    final bytes =
    File(filePath).readAsBytesSync();

    final decoder =
    SpreadsheetDecoder.decodeBytes(
      bytes,
      update: true,
    );

    final materiales = <Material>[];

    final sheet =
        decoder.tables.values.first;

    bool encabezado = true;

    for (final row in sheet.rows) {

      if (encabezado) {
        encabezado = false;
        continue;
      }

      if (row.isEmpty) continue;

      final codigo =
          row[0]?.toString().trim() ?? '';

      if (codigo.isEmpty) continue;

      final descripcion =
          row[1]?.toString().trim() ?? '';

      final tipo =
          row[2]?.toString().trim() ?? '';

      final existencia =
      _toDouble(row[4]);

      materiales.add(
        Material(
          codigo: codigo,
          descripcion: descripcion,
          tipo: tipo,
          existencia: existencia,
          updatedAt: DateTime.now(),
          syncStatus: 0,
        ),
      );
    }

    return materiales;
  }

  double _toDouble(
      dynamic value,
      ) {

    if (value == null) {
      return 0;
    }

    return double.tryParse(
      value.toString()
          .replaceAll(',', '.'),
    ) ??
        0;
  }
}