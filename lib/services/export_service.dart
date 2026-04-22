import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../data/questions.dart';
import '../models/question.dart';
import '../models/survey_response.dart';

class ExportService {
  static const List<String> _columns = [
    'ID',
    'Fecha',
    'q1 - Frecuencia Free Fire',
    'q2 - Primera activación',
    'q3 - Sentimiento (1-5)',
    'q4 - Emociones',
    'q5 - Magia (1-5)',
    'q6 - Ganas de jugar',
    'q7 - NPS (0-10)',
    'q8 - Comentario abierto',
  ];

  static const _questionIds = [
    'q1',
    'q2',
    'q3',
    'q4',
    'q5',
    'q6',
    'q7',
    'q8',
  ];

  Future<File> buildXlsx(List<SurveyResponse> responses) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != 'Respuestas') {
      excel.rename(defaultSheet, 'Respuestas');
    }
    final sheet = excel['Respuestas'];

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#FF6B00'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    for (var i = 0; i < _columns.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(_columns[i]);
      cell.cellStyle = headerStyle;
    }

    final dateFmt = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (var r = 0; r < responses.length; r++) {
      final resp = responses[r];
      final row = r + 1;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(resp.id);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(dateFmt.format(resp.createdAt));

      for (var q = 0; q < _questionIds.length; q++) {
        final qid = _questionIds[q];
        final raw = resp.answers[qid];
        final question = questions.firstWhere(
          (x) => x.id == qid,
          orElse: () => const Question(
            id: '',
            section: '',
            text: '',
            type: QuestionType.openText,
          ),
        );
        final cellIndex = CellIndex.indexByColumnRow(
          columnIndex: q + 2,
          rowIndex: row,
        );
        if (raw == null) {
          sheet.cell(cellIndex).value = TextCellValue('');
          continue;
        }
        switch (question.type) {
          case QuestionType.multiChoice:
            final list = (raw as List).cast<String>();
            sheet.cell(cellIndex).value = TextCellValue(list.join('; '));
            break;
          case QuestionType.scale1to5:
          case QuestionType.nps0to10:
            final n = (raw as num).toInt();
            sheet.cell(cellIndex).value = IntCellValue(n);
            break;
          case QuestionType.singleChoice:
          case QuestionType.openText:
            sheet.cell(cellIndex).value = TextCellValue(raw.toString());
            break;
        }
      }
    }

    // Reasonable column widths.
    sheet.setColumnWidth(0, 38);
    sheet.setColumnWidth(1, 22);
    for (var c = 2; c < _columns.length; c++) {
      sheet.setColumnWidth(c, 28);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('No se pudo codificar el XLSX');
    }

    final tempDir = await getTemporaryDirectory();
    final name = 'encuestas_yeti_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
