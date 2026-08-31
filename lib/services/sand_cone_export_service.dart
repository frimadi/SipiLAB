import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/sand_cone_test_result.dart';

class SandConeExportService {
 
  static Future<void> exportToExcel(
    SandConeTestResult result, {
    String? kontraktor,
    String? lokasi,
    String? pekerjaan,
    String? tanggal,
  }) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sand Cone Test'];
    
   
    CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 12,
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    
    CellStyle titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.fromHexString('#2F5496'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    
    CellStyle inputStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FFF2CC'),
      horizontalAlign: HorizontalAlign.Right,
    );
    
    CellStyle resultStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#E2EFDA'),
      horizontalAlign: HorizontalAlign.Right,
      bold: true,
    );
    
    int row = 0;
    
   
    _setCellValue(sheetObject, 'A${++row}', 'PENGUJIAN KEPADATAN DENGAN ALAT SAND CONE', titleStyle);
    _setCellValue(sheetObject, 'A${++row}', 'SNI 2828:2011', titleStyle);
    row++;
    
   
    _setCellValue(sheetObject, 'A${++row}', 'KONTRAKTOR:', headerStyle);
    _setCellValue(sheetObject, 'B$row', kontraktor ?? '');
    _setCellValue(sheetObject, 'D$row', 'TANGGAL:', headerStyle);
    _setCellValue(sheetObject, 'E$row', tanggal ?? '');
    
    _setCellValue(sheetObject, 'A${++row}', 'LOKASI:', headerStyle);
    _setCellValue(sheetObject, 'B$row', lokasi ?? '');
    
    _setCellValue(sheetObject, 'A${++row}', 'PEKERJAAN:', headerStyle);
    _setCellValue(sheetObject, 'B$row', pekerjaan ?? '');
    row++;
    
  
    _setCellValue(sheetObject, 'A${++row}', 'I. KALIBRASI ALAT SAND CONE', titleStyle);
    row++;
    
    _setCellValue(sheetObject, 'A${++row}', 'URAIAN', headerStyle);
    _setCellValue(sheetObject, 'B$row', 'RUMUS', headerStyle);
    _setCellValue(sheetObject, 'C$row', 'NILAI', headerStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Botol + Corong');
    _setCellValue(sheetObject, 'B$row', 'W1');
    _setCellValue(sheetObject, 'C$row', result.beratBotolCorong, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Botol Penuh Air + Corong');
    _setCellValue(sheetObject, 'B$row', 'W2');
    _setCellValue(sheetObject, 'C$row', result.beratBotolCorongAir, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Volume Botol (Vb)');
    _setCellValue(sheetObject, 'B$row', 'Vb = W2-W1');
    _setCellValue(sheetObject, 'C$row', result.volumeBotolCorong.toStringAsFixed(2), resultStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Botol Penuh Pasir + Corong');
    _setCellValue(sheetObject, 'B$row', 'W3');
    _setCellValue(sheetObject, 'C$row', result.beratBotolCorongPasir, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Isi Pasir (Yp)');
    _setCellValue(sheetObject, 'B$row', 'Yp = (W3-W1)/(W2-W1)');
    _setCellValue(sheetObject, 'C$row', result.beratIsiPasir.toStringAsFixed(4), resultStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Botol + Pasir Corong');
    _setCellValue(sheetObject, 'B$row', 'W4');
    _setCellValue(sheetObject, 'C$row', result.beratBotolCorongA, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Botol + Sisa Pasir + Corong');
    _setCellValue(sheetObject, 'B$row', 'W5');
    _setCellValue(sheetObject, 'C$row', result.beratBotolCorongSisaPasir, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Pasir Dalam Corong (W6)');
    _setCellValue(sheetObject, 'B$row', 'W6 = W4-W5');
    _setCellValue(sheetObject, 'C$row', result.beratPasirDalamCorong.toStringAsFixed(2), resultStyle);
    row++;
    
   
    _setCellValue(sheetObject, 'A${++row}', 'II. PENGUJIAN KEPADATAN DENGAN ALAT SAND CONE', titleStyle);
    row++;
    
    _setCellValue(sheetObject, 'A${++row}', 'URAIAN', headerStyle);
    _setCellValue(sheetObject, 'B$row', 'RUMUS', headerStyle);
    _setCellValue(sheetObject, 'C$row', 'NILAI', headerStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Cawan Kosong');
    _setCellValue(sheetObject, 'B$row', 'W7');
    _setCellValue(sheetObject, 'C$row', result.beratWadah, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Cawan + Agregat/Tanah');
    _setCellValue(sheetObject, 'B$row', 'W8');
    _setCellValue(sheetObject, 'C$row', result.beratTanahWadah, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Agregat Basah (W9)');
    _setCellValue(sheetObject, 'B$row', 'W9 = W8-W7');
    _setCellValue(sheetObject, 'C$row', result.beratTanah.toStringAsFixed(2), resultStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Botol + Pasir + Corong');
    _setCellValue(sheetObject, 'B$row', 'W10');
    _setCellValue(sheetObject, 'C$row', result.beratBotolCorongB, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Botol + Sisa Pasir + Corong');
    _setCellValue(sheetObject, 'B$row', 'W11');
    _setCellValue(sheetObject, 'C$row', result.beratBotolCorongSisaPasirB, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Pasir di dalam Corong + Lubang (W12)');
    _setCellValue(sheetObject, 'B$row', 'W12 = W10-W11');
    _setCellValue(sheetObject, 'C$row', result.beratPasirDalamTakaran.toStringAsFixed(2), resultStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat Pasir di dalam Lubang (W13)');
    _setCellValue(sheetObject, 'B$row', 'W13 = W12-W6');
    _setCellValue(sheetObject, 'C$row', result.beratPasirDalamLubang.toStringAsFixed(2), resultStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Volume Pasir dalam Lubang (V)');
    _setCellValue(sheetObject, 'B$row', 'V = W13/Yp');
    _setCellValue(sheetObject, 'C$row', result.vLubang.toStringAsFixed(2), resultStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat isi Tanah Basah (Yd)');
    _setCellValue(sheetObject, 'B$row', 'Yd = W9/V');
    _setCellValue(sheetObject, 'C$row', result.beratIsiTanah.toStringAsFixed(4), resultStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Kadar Air (W)');
    _setCellValue(sheetObject, 'B$row', 'W (%)');
    _setCellValue(sheetObject, 'C$row', '${result.kadarAir.toStringAsFixed(2)}%', inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Berat isi Kering (Yd Lap)');
    _setCellValue(sheetObject, 'B$row', 'Yd Lap = Yd/(1+W/100)');
    _setCellValue(sheetObject, 'C$row', result.beratIsiTanahKering.toStringAsFixed(4), resultStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Kepadatan Lab (Yd Lab)');
    _setCellValue(sheetObject, 'B$row', 'Yd Lab');
    _setCellValue(sheetObject, 'C$row', result.beratIsiPasirB, inputStyle);
    
    _setCellValue(sheetObject, 'A${++row}', 'Derajat Kepadatan');
    _setCellValue(sheetObject, 'B$row', '(Yd Lap/Yd Lab) × 100%');
    CellStyle finalResultStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#C6E0B4'),
      horizontalAlign: HorizontalAlign.Right,
      bold: true,
      fontSize: 14,
    );
    _setCellValue(sheetObject, 'C$row', '${result.persentaseKepadatan.toStringAsFixed(2)}%', finalResultStyle);
    
   
    sheetObject.setColumnWidth(0, 35);
    sheetObject.setColumnWidth(1, 30);
    sheetObject.setColumnWidth(2, 20);
    
  
    var fileBytes = excel.save();
    String fileName = 'SandConeTest_SNI2828_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes!);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Sand Cone Test Result (SNI 2828:2011)');
    } else {
      final directory = await getDownloadsDirectory();
      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(fileBytes!);
    }
  }
  
  static void _setCellValue(Sheet sheet, String cellRef, dynamic value, [CellStyle? style]) {
    var cell = sheet.cell(CellIndex.indexByString(cellRef));
    if (value is double) {
      cell.value = DoubleCellValue(value);
    } else if (value is int) {
      cell.value = IntCellValue(value);
    } else {
      cell.value = TextCellValue(value.toString());
    }
    if (style != null) {
      cell.cellStyle = style;
    }
  }

 
  static Future<void> exportToPdf(
    SandConeTestResult result, {
    String? kontraktor,
    String? lokasi,
    String? pekerjaan,
    String? tanggal,
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
         
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue700,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PENGUJIAN KEPADATAN DENGAN ALAT SAND CONE',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'SNI 2828:2011',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
       
            _buildPdfTable([
              ['KONTRAKTOR', kontraktor ?? '', 'TANGGAL', tanggal ?? ''],
              ['LOKASI', lokasi ?? '', '', ''],
              ['PEKERJAAN', pekerjaan ?? '', '', ''],
            ], columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(2)
            }),
            pw.SizedBox(height: 20),
            
  
            _buildPdfSectionTitle('I. KALIBRASI ALAT SAND CONE'),
            pw.SizedBox(height: 10),
            _buildPdfTable([
              ['URAIAN', 'RUMUS', 'NILAI'],
              ['Berat Botol + Corong', 'W1', '${result.beratBotolCorong}'],
              ['Berat Botol Penuh Air + Corong', 'W2', '${result.beratBotolCorongAir}'],
              ['Volume Botol (Vb)', 'Vb = W2-W1', '${result.volumeBotolCorong.toStringAsFixed(2)}'],
              ['Berat Botol Penuh Pasir + Corong', 'W3', '${result.beratBotolCorongPasir}'],
              ['Berat Isi Pasir (Yp)', 'Yp = (W3-W1)/(W2-W1)', '${result.beratIsiPasir.toStringAsFixed(4)}'],
              ['Berat Botol + Pasir Corong', 'W4', '${result.beratBotolCorongA}'],
              ['Berat Botol + Sisa Pasir + Corong', 'W5', '${result.beratBotolCorongSisaPasir}'],
              ['Berat Pasir Dalam Corong (W6)', 'W6 = W4-W5', '${result.beratPasirDalamCorong.toStringAsFixed(2)}'],
            ]),
            pw.SizedBox(height: 20),
            
            _buildPdfSectionTitle('II. PENGUJIAN KEPADATAN DENGAN ALAT SAND CONE'),
            pw.SizedBox(height: 10),
            _buildPdfTable([
              ['URAIAN', 'RUMUS', 'NILAI'],
              ['Berat Cawan Kosong', 'W7', '${result.beratWadah}'],
              ['Berat Cawan + Agregat/Tanah', 'W8', '${result.beratTanahWadah}'],
              ['Berat Agregat Basah (W9)', 'W9 = W8-W7', '${result.beratTanah.toStringAsFixed(2)}'],
              ['Berat Botol + Pasir + Corong', 'W10', '${result.beratBotolCorongB}'],
              ['Berat Botol + Sisa Pasir + Corong', 'W11', '${result.beratBotolCorongSisaPasirB}'],
              ['Berat Pasir Corong+Lubang (W12)', 'W12 = W10-W11', '${result.beratPasirDalamTakaran.toStringAsFixed(2)}'],
              ['Berat Pasir dalam Lubang (W13)', 'W13 = W12-W6', '${result.beratPasirDalamLubang.toStringAsFixed(2)}'],
              ['Volume Pasir dalam Lubang (V)', 'V = W13/Yp', '${result.vLubang.toStringAsFixed(2)}'],
              ['Berat isi Tanah Basah (Yd)', 'Yd = W9/V', '${result.beratIsiTanah.toStringAsFixed(4)}'],
              ['Kadar Air (W)', 'W (%)', '${result.kadarAir.toStringAsFixed(2)}%'],
              ['Berat isi Kering (Yd Lap)', 'Yd Lap = Yd/(1+W/100)', '${result.beratIsiTanahKering.toStringAsFixed(4)}'],
              ['Kepadatan Lab (Yd Lab)', 'Yd Lab', '${result.beratIsiPasirB}'],
            ]),
            pw.SizedBox(height: 20),
            
          
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                border: pw.Border.all(color: PdfColors.green700, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'DERAJAT KEPADATAN',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${result.persentaseKepadatan.toStringAsFixed(2)}%',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    
   
    String fileName = 'SandConeTest_SNI2828_${DateTime.now().millisecondsSinceEpoch}.pdf';
    
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      await Share.shareXFiles([XFile(file.path)], text: 'Sand Cone Test Result PDF (SNI 2828:2011)');
    } else {
      final directory = await getDownloadsDirectory();
      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
    }
  }
  
  static pw.Widget _buildPdfSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue700,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }
  
  static pw.Widget _buildPdfTable(List<List<String>> data, {Map<int, pw.TableColumnWidth>? columnWidths}) {
    final List<String> headers = data.first;
    final List<List<String>> tableData = data.sublist(1);

    return pw.Table.fromTextArray(
      headers: headers,
      data: tableData,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(5),
      columnWidths: columnWidths,
    );
  }
}