import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:mi_almacen/models/Vale.dart';
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






  @override
  Future<Uint8List> exportarVales(List<Vale> vales) async {
    final excel = Excel.createExcel();
    final nombreHoja = 'Vales liberados';

    excel.rename(excel.getDefaultSheet()!, nombreHoja);
    final sheet = excel[nombreHoja];

    final encabezados = [
      'Vale', 'Fecha creación', 'Usuario', 'Departamento',
      'Fecha liberación', 'Material', 'Código',
      'Cantidad', 'Unidad', 'Proyecto', 'Comentario',
    ];

    sheet.appendRow(encabezados.map((e) => TextCellValue(e)).toList());

    for (var col = 0; col < encabezados.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .cellStyle = CellStyle(bold: true);
    }

    for (final vale in vales) {

      final items = vale.items.isEmpty ? [null] : vale.items;

      for (final item in items) {
        sheet.appendRow([
          TextCellValue(vale.id),
          TextCellValue(_fecha(vale.fechaCreacion)),
          TextCellValue(vale.usuarioNombre),
          TextCellValue(vale.departamento ?? ''),
          TextCellValue(
            vale.fechaValidacion != null ? _fecha(vale.fechaValidacion!) : '',
          ),
          TextCellValue(item?.material.descripcion ?? ''),
          TextCellValue(item?.material.codigo ?? ''),
          item != null ? DoubleCellValue(item.cantidad) : TextCellValue(''),
          TextCellValue(item?.unidad ?? ''),
          TextCellValue(item?.proyecto?.clave ?? ''),
          TextCellValue(item?.comentarioVale ?? ''),
        ]);
      }
    }

    for (var col = 0; col < encabezados.length; col++) {
      sheet.setColumnAutoFit(col);
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('No se pudo generar el archivo Excel');

    return Uint8List.fromList(bytes);
  }

  String _fecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
}
