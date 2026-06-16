import 'dart:io';

import 'package:mi_almacen/models/Material.dart';
import 'package:mi_almacen/services/excel_service.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';


class ExcelServiceImpl implements ExcelService {

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

      final clave =
          row[0]?.toString().trim() ?? '';

      if (clave.isEmpty) continue;

      final descripcion =
          row[1]?.toString().trim() ?? '';

      final tipo =
          row[2]?.toString().trim() ?? '';

      final existencia =
      _toDouble(row[4]);

      materiales.add(
        Material(
          codigo: clave,
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

  double _toDouble(dynamic value) {

    if (value == null) {
      return 0;
    }

    return double.tryParse(
      value.toString().replaceAll(',', '.'),
    ) ??
        0;
  }


}