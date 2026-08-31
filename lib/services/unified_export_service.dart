import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'unified_report_service.dart';
import '../models/hammer_test_result.dart';
import '../models/sand_cone_test_result.dart';
import '../models/uji_kuat_result.dart';
import '../models/konversi_result.dart';

class UnifiedExportService {
  
  
  Future<List<String>> _getValidPhotoPaths(List<String> photoPaths) async {
    List<String> validPaths = [];
    
    for (String photoPath in photoPaths) {
      try {
        final file = File(photoPath);
        if (await file.exists()) {
          validPaths.add(photoPath);
          print('✅ Foto ditemukan: $photoPath');
        } else {
          print('❌ Foto TIDAK ditemukan: $photoPath');
        }
      } catch (e) {
        print('❌ Error validasi foto: $e');
      }
    }
    
    return validPaths;
  }

  
  Future<File> exportSingleReportToPDF(UnifiedReport report) async {
    final pdf = pw.Document();

   
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildCoverPage(report),
      ),
    );

   
    await _addContentPages(pdf, report);

   
    await _addPhotoPages(pdf, report);

  
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/laporan_${report.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    print('📄 PDF disimpan di: ${file.path}');
    return file;
  }

 
  Future<File> exportMultipleReportsToPDF(List<UnifiedReport> reports) async {
    final pdf = pw.Document();

    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'LAPORAN GABUNGAN PENGUJIAN',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total: ${reports.length} Laporan', 
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('Tanggal: ${_formatDate(DateTime.now())}', 
                  style: const pw.TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );

  
    for (var i = 0; i < reports.length; i++) {
    
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            children: [
              pw.Text('Laporan ${i + 1} dari ${reports.length}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              pw.SizedBox(height: 20),
              _buildCoverPage(reports[i]),
            ],
          ),
        ),
      );
      
      await _addContentPages(pdf, reports[i]);
      await _addPhotoPages(pdf, reports[i]);
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/laporan_gabungan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

 
  Future<void> sharePDF(File file, String title) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: title,
      text: 'Laporan Pengujian',
    );
  }

 
  pw.Widget _buildCoverPage(UnifiedReport report) {
    PdfColor headerColor;
    String typeLabel;
    
    switch (report.type) {
      case 'sand_cone':
        headerColor = PdfColors.blue700;
        typeLabel = 'SAND CONE TEST';
        break;
      case 'hammer_test':
        headerColor = PdfColors.green700;
        typeLabel = 'HAMMER TEST';
        break;
      case 'uji_kuat':
        headerColor = PdfColors.red700;
        typeLabel = 'UJI KUAT TEKAN BETON';
        break;
      case 'konversi_beton':
        headerColor = PdfColors.orange700;
        typeLabel = 'KONVERSI UMUR BETON';
        break;
      default:
        headerColor = PdfColors.grey700;
        typeLabel = 'LAPORAN PENGUJIAN';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: headerColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  typeLabel,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  report.title,
                  style: const pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          _buildInfoRow('Tanggal', _formatDate(report.date)),
          pw.SizedBox(height: 8),
          _buildInfoRow('ID Laporan', report.id),
          pw.SizedBox(height: 20),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              report.summary,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Text(': ', style: const pw.TextStyle(fontSize: 12)),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  
  Future<void> _addContentPages(pw.Document pdf, UnifiedReport report) async {
    switch (report.type) {
      case 'sand_cone':
        await _addSandConePages(pdf, SandConeTestResult.fromJson(report.data));
        break;
      case 'hammer_test':
        await _addHammerTestPages(pdf, HammerTestResult.fromMap(report.data));
        break;
      case 'uji_kuat':
        await _addUjiKuatPages(pdf, report.data);
        break;
      case 'konversi_beton':
        await _addKonversiBetonPages(pdf, KonversiResult.fromJson(report.data));
        break;
    }
  }

 
  Future<void> _addPhotoPages(pw.Document pdf, UnifiedReport report) async {
    List<String> photoPaths = [];
    String testType = '';
    
    if (report.type == 'sand_cone') {
      final result = SandConeTestResult.fromJson(report.data);
      if (result.hasDokumentasiFoto) {
        photoPaths = result.photoPaths;
        testType = 'Sand Cone Test';
      }
    } else if (report.type == 'hammer_test') {
      final result = HammerTestResult.fromMap(report.data);
      if (result.hasDokumentasiFoto) {
        photoPaths = result.photoPaths;
        testType = 'Hammer Test';
      }
    } else if (report.type == 'uji_kuat') {
      final result = UjiKuatResult.fromMap(report.data['result']);
      if (result.hasPhotos()) {
        photoPaths = result.photoPaths!;
        testType = 'Uji Kuat Tekan';
      }
    }
    
    if (photoPaths.isNotEmpty) {
      final validPhotos = await _getValidPhotoPaths(photoPaths);
      if (validPhotos.isNotEmpty) {
        await _addPhotoPagesToPdf(pdf, validPhotos, testType);
      }
    }
  }
   Future<void> _addPhotoPagesToPdf(
    pw.Document pdf, 
    List<String> photoPaths, 
    String testType
  ) async {
    if (photoPaths.isEmpty) return;

   
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(30),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: testType == 'Hammer Test' 
                      ? PdfColors.green700 
                      : testType == 'Uji Kuat Tekan'
                          ? PdfColors.red700
                          : PdfColors.blue700,
                ),
                child: pw.Text(
                  'DOKUMENTASI FOTO - $testType',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Foto: ${photoPaths.length}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
    
   
    for (int i = 0; i < photoPaths.length; i += 2) {
      final photo1Path = photoPaths[i];
      final photo2Path = i + 1 < photoPaths.length ? photoPaths[i + 1] : null;
      
      pw.ImageProvider? photo1Image;
      pw.ImageProvider? photo2Image;
      
      try {
        final file1 = File(photo1Path);
        if (await file1.exists()) {
          final bytes1 = await file1.readAsBytes();
          photo1Image = pw.MemoryImage(bytes1);
        }
      } catch (e) {
        print('❌ Error foto ${i + 1}: $e');
      }
      
      if (photo2Path != null) {
        try {
          final file2 = File(photo2Path);
          if (await file2.exists()) {
            final bytes2 = await file2.readAsBytes();
            photo2Image = pw.MemoryImage(bytes2);
          }
        } catch (e) {
          print('❌ Error foto ${i + 2}: $e');
        }
      }
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Text('Foto ${i + 1}',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Expanded(
                        child: pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              top: pw.BorderSide(color: PdfColors.grey400, width: 2),
                              bottom: pw.BorderSide(color: PdfColors.grey400, width: 2),
                              left: pw.BorderSide(color: PdfColors.grey400, width: 2),
                              right: pw.BorderSide(color: PdfColors.grey400, width: 2),
                            ),
                          ),
                          child: photo1Image != null
                              ? pw.Image(photo1Image, fit: pw.BoxFit.contain)
                              : pw.Center(child: pw.Text('Foto tidak dapat dimuat',
                                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (photo2Path != null) ...[
                  pw.SizedBox(height: 20),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Text('Foto ${i + 2}',
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 10),
                        pw.Expanded(
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                top: pw.BorderSide(color: PdfColors.grey400, width: 2),
                                bottom: pw.BorderSide(color: PdfColors.grey400, width: 2),
                                left: pw.BorderSide(color: PdfColors.grey400, width: 2),
                                right: pw.BorderSide(color: PdfColors.grey400, width: 2),
                              ),
                            ),
                            child: photo2Image != null
                                ? pw.Image(photo2Image, fit: pw.BoxFit.contain)
                                : pw.Center(child: pw.Text('Foto tidak dapat dimuat',
                                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }

 
  pw.Widget _pdfSectionTitle(String title, {PdfColor? bgColor}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: bgColor ?? PdfColors.blue700,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

 
  pw.Widget _pdfDetailRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 200,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  pw.Widget _pdfInfoBox(String title, List<pw.Widget> children, {PdfColor? borderColor}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor ?? PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          ...children,
        ],
      ),
    );
  }

  
  pw.Widget _pdfHighlightBox({
    required String title,
    required String value,
    String? subtitle,
    PdfColor? bgColor,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgColor ?? PdfColors.blue50,
        border: pw.Border.all(color: bgColor ?? PdfColors.blue300, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              subtitle,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ],
      ),
    );
  }

  
  pw.Widget _pdfTable(List<List<String>> data, {List<String>? headers}) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        if (headers != null)
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: headers.map((h) => pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(h, 
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            )).toList(),
          ),
        ...data.map((row) => pw.TableRow(
          children: row.map((cell) => pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(cell, style: const pw.TextStyle(fontSize: 9)),
          )).toList(),
        )),
      ],
    );
  }
   Future<void> _addSandConePages(pw.Document pdf, SandConeTestResult result) async {
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('📊 HASIL UTAMA', bgColor: PdfColors.blue700),
            pw.SizedBox(height: 12),
            
            _pdfHighlightBox(
              title: 'Derajat Kepadatan',
              value: '${result.persentaseKepadatan.toStringAsFixed(2)}%',
              subtitle: result.statusKepadatan,
              bgColor: result.persentaseKepadatan >= 95 
                  ? PdfColors.green50 
                  : PdfColors.orange50,
            ),
            
            pw.SizedBox(height: 8),
            
            pw.Row(
              children: [
                pw.Expanded(
                  child: _pdfHighlightBox(
                    title: 'Berat Isi Kering (Yd Lap)',
                    value: '${result.beratIsiTanahKering.toStringAsFixed(4)}',
                    subtitle: 'g/cm³',
                    bgColor: PdfColors.blue50,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _pdfHighlightBox(
                    title: 'Klasifikasi',
                    value: result.persentaseKepadatan >= 95 ? 'Baik' : 
                           result.persentaseKepadatan >= 90 ? 'Sedang' : 'Kurang',
                    bgColor: PdfColors.grey100,
                  ),
                ),
              ],
            ),
            
            pw.SizedBox(height: 16),
            
           
            if (result.hasProjectInfo) ...[
              _pdfSectionTitle('📋 INFORMASI PROYEK', bgColor: PdfColors.purple700),
              pw.SizedBox(height: 8),
              _pdfInfoBox('Data Proyek', [
                if (result.kontraktor != null && result.kontraktor!.isNotEmpty)
                  _pdfDetailRow('Nama Kontraktor', result.kontraktor!),
                if (result.lokasiProyek != null && result.lokasiProyek!.isNotEmpty)
                  _pdfDetailRow('Lokasi Proyek', result.lokasiProyek!),
                if (result.jenisPekerjaan != null && result.jenisPekerjaan!.isNotEmpty)
                  _pdfDetailRow('Jenis Pekerjaan', result.jenisPekerjaan!),
                if (result.tanggalPengujian != null)
                  _pdfDetailRow('Tanggal Pengujian', _formatDate(result.tanggalPengujian!)),
              ]),
              pw.SizedBox(height: 12),
            ],
            
           
            if (result.hasDokumentasiFoto) ...[
              _pdfInfoBox('Dokumentasi', [
                _pdfDetailRow('Jumlah Foto', '${result.jumlahFoto} foto'),
              ]),
            ],
          ],
        ),
      ),
    );

    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('🔬 SECTION I: KALIBRASI ALAT', bgColor: PdfColors.blue700),
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('A. Pengukuran Volume Botol', [
              _pdfDetailRow('Berat Botol + Corong (W1)', 
                  '${result.beratBotolCorong.toStringAsFixed(2)} gram'),
              _pdfDetailRow('Berat Botol + Corong + Air (W2)', 
                  '${result.beratBotolCorongAir.toStringAsFixed(2)} gram'),
              _pdfDetailRow('Volume Botol (Vb)', 
                  '${result.volumeBotolCorong.toStringAsFixed(4)} ml', bold: true),
            ], borderColor: PdfColors.blue300),
            
            _pdfInfoBox('B. Pengukuran Berat Isi Pasir', [
              _pdfDetailRow('Berat Botol + Corong + Pasir (W3)', 
                  '${result.beratBotolCorongPasir.toStringAsFixed(2)} gram'),
              _pdfDetailRow('Berat Isi Pasir (Yρ)', 
                  '${result.beratIsiPasir.toStringAsFixed(4)} g/ml', bold: true),
            ], borderColor: PdfColors.blue300),
            
            pw.SizedBox(height: 12),
            
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Formula Perhitungan:',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text('Volume Botol (Vb) = W2 - W1',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text('Berat Isi Pasir (Yρ) = (W3 - W1) / Vb',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('📏 SECTION II: PENGUJIAN KEPADATAN', 
                bgColor: PdfColors.purple700),
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('A. Berat Pasir Dalam Corong', [
              _pdfDetailRow('W4 (Botol + Pasir + Corong)', 
                  '${result.beratBotolCorongA.toStringAsFixed(2)} gram'),
              _pdfDetailRow('W5 (Botol + Sisa Pasir + Corong)', 
                  '${result.beratBotolCorongSisaPasir.toStringAsFixed(2)} gram'),
              _pdfDetailRow('W6 (Berat Pasir Dalam Corong)', 
                  '${result.beratPasirDalamCorong.toStringAsFixed(4)} gram', bold: true),
            ], borderColor: PdfColors.purple300),
            
            _pdfInfoBox('B. Pengukuran Tanah', [
              _pdfDetailRow('Berat Wadah (W7)', 
                  '${result.beratWadah.toStringAsFixed(2)} gram'),
              _pdfDetailRow('Berat Tanah + Wadah (W8)', 
                  '${result.beratTanahWadah.toStringAsFixed(2)} gram'),
              _pdfDetailRow('Berat Tanah (W9)', 
                  '${result.beratTanah.toStringAsFixed(4)} gram', bold: true),
            ], borderColor: PdfColors.purple300),
            
            _pdfInfoBox('C. Pengukuran Volume Lubang', [
              _pdfDetailRow('W10 (Botol + Pasir + Corong)', 
                  '${result.beratBotolCorongB.toStringAsFixed(2)} gram'),
              _pdfDetailRow('W11 (Botol + Sisa Pasir + Corong)', 
                  '${result.beratBotolCorongSisaPasirB.toStringAsFixed(2)} gram'),
              _pdfDetailRow('Berat Pasir di Lubang (W13)', 
                  '${result.beratPasirDalamLubang.toStringAsFixed(4)} gram', bold: true),
              _pdfDetailRow('Volume Lubang (V)', 
                  '${result.vLubang.toStringAsFixed(4)} ml', bold: true),
            ], borderColor: PdfColors.purple300),
          ],
        ),
      ),
    );

  
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('💧 SECTION III: KADAR AIR & KEPADATAN', 
                bgColor: PdfColors.green700),
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('Perhitungan Akhir', [
              _pdfDetailRow('Berat Isi Tanah Basah (Yd)', 
                  '${result.beratIsiTanah.toStringAsFixed(4)} g/cm³'),
              _pdfDetailRow('Kadar Air (W)', 
                  '${result.kadarAir.toStringAsFixed(2)}%'),
              _pdfDetailRow('Berat Isi Tanah Kering Lab (Yd Lab)', 
                  '${result.beratIsiPasirB.toStringAsFixed(4)} g/cm³'),
              _pdfDetailRow('Berat Isi Tanah Kering Lapangan (Yd Lap)', 
                  '${result.beratIsiTanahKering.toStringAsFixed(4)} g/cm³', bold: true),
            ], borderColor: PdfColors.green300),
            
            pw.SizedBox(height: 12),
            
           
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: result.persentaseKepadatan >= 95 
                    ? PdfColors.green50 
                    : PdfColors.orange50,
                border: pw.Border.all(
                  color: result.persentaseKepadatan >= 95 
                      ? PdfColors.green300 
                      : PdfColors.orange300,
                  width: 2,
                ),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    result.persentaseKepadatan >= 95 
                        ? '✓ MEMENUHI STANDAR' 
                        : result.persentaseKepadatan >= 90
                            ? '⚠ PERLU PERHATIAN'
                            : '✗ TIDAK MEMENUHI STANDAR',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Derajat Kepadatan: ${result.persentaseKepadatan.toStringAsFixed(2)}%',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    result.persentaseKepadatan >= 95
                        ? 'Pemadatan telah mencapai standar yang disyaratkan (≥95%)'
                        : result.persentaseKepadatan >= 90
                            ? 'Pemadatan mendekati standar, perlu pemadatan tambahan'
                            : 'Pemadatan tidak memenuhi syarat, perlu pemadatan ulang',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 12),
            
          
            _pdfInfoBox('📋 CATATAN STANDAR SNI 2828:2011', [
              pw.Text(
                '• Standar kepadatan minimum: 95% dari kepadatan laboratorium\n'
                '• Formula: Derajat = (Yd Lap / Yd Lab) × 100%\n'
                '• Metode: Sand Cone Test (Uji Kerucut Pasir)\n'
                '• Kadar air dinyatakan dalam persen (%)\n'
                '• Berat isi dalam gram per mililiter (g/ml atau g/cm³)',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ], borderColor: PdfColors.blue300),
          ],
        ),
      ),
    );
  }
   Future<void> _addHammerTestPages(pw.Document pdf, HammerTestResult result) async {
  
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('📍 INFORMASI TEST', bgColor: PdfColors.green700),
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('Data Test', [
              _pdfDetailRow('ID Test', result.testId),
              _pdfDetailRow('Lokasi Test', result.location),
              _pdfDetailRow('Tanggal Test', _formatDate(result.testDate)),
              if (result.testedBy.isNotEmpty)
                _pdfDetailRow('Pekerja/Teknisi', result.testedBy),
              _pdfDetailRow('Standar', result.standard),
              _pdfDetailRow('Tipe Hammer', result.hammerType),
            ], borderColor: PdfColors.green300),
            
            _pdfInfoBox('Kondisi Pengujian', [
              _pdfDetailRow('Posisi Pengujian', 
                  '${result.position} - ${result.positionDescription}'),
              _pdfDetailRow('Orientasi Pukulan', result.orientationDescription),
              _pdfDetailRow('Umur Beton', '${result.age} hari'),
            ], borderColor: PdfColors.green300),
            
            if (result.hasDokumentasiFoto) ...[
              _pdfInfoBox('Dokumentasi', [
                _pdfDetailRow('Jumlah Foto', '${result.jumlahFoto} foto'),
              ]),
            ],
            
            pw.SizedBox(height: 16),
            
            _pdfSectionTitle('📊 DATA PEMBACAAN (${result.reboundValues.length} data)', 
                bgColor: PdfColors.blue700),
            pw.SizedBox(height: 8),
            
           
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Wrap(
                spacing: 6,
                runSpacing: 6,
                children: result.reboundValues.asMap().entries.map((entry) {
                  return pw.Container(
                    width: 50,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      border: pw.Border.all(color: PdfColors.blue300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('R${entry.key + 1}',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text('${entry.value}',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );

    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('📈 ANALISIS STATISTIK', bgColor: PdfColors.blue700),
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('Hasil Statistik', [
              _pdfDetailRow('Jumlah Pembacaan', '${result.reboundValues.length} data'),
              _pdfDetailRow('Rata-rata (R)', result.rValue.toStringAsFixed(2), bold: true),
              _pdfDetailRow('Standar Deviasi (SD)', result.standardDeviation.toStringAsFixed(2)),
              _pdfDetailRow('Koefisien Variasi (CoV)', 
                  '${result.coefficientOfVariation.toStringAsFixed(2)}%'),
              _pdfDetailRow('Status Kualitas Data', result.qualityStatus, bold: true),
            ], borderColor: PdfColors.blue300),
            
            pw.SizedBox(height: 12),
            
           
            if (result.calibrationFactor != 1.0) ...[
              _pdfSectionTitle('⚙️ KOREKSI KALIBRASI ALAT', bgColor: PdfColors.purple700),
              pw.SizedBox(height: 8),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.purple50,
                  border: pw.Border.all(color: PdfColors.purple300, width: 2),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfDetailRow('R Sebelum Kalibrasi', result.rValue.toStringAsFixed(2)),
                    pw.Divider(color: PdfColors.purple300),
                    _pdfDetailRow('Faktor Kalibrasi', 
                        result.calibrationFactor.toStringAsFixed(8)),
                    pw.Divider(color: PdfColors.purple300),
                    _pdfDetailRow('R Setelah Kalibrasi', 
                        (result.rValue * result.calibrationFactor).toStringAsFixed(2), 
                        bold: true),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
            ],
            
         
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Interpretasi Koefisien Variasi:',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '• CoV < 5%  : Data sangat konsisten (Baik Sekali)\n'
                    '• CoV 5-10% : Data konsisten (Baik)\n'
                    '• CoV > 10% : Data kurang konsisten (Perlu evaluasi)',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('💪 HASIL KUAT TEKAN', bgColor: PdfColors.green700),
            pw.SizedBox(height: 12),
            
           
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                border: pw.Border.all(color: PdfColors.green300, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  pw.Text('Kuat Tekan Estimasi',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  pw.SizedBox(height: 8),
                  pw.Text('${result.compressiveStrengthMPa.toStringAsFixed(2)} MPa',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('≈ ${result.compressiveStrengthKgCm2.toStringAsFixed(2)} kg/cm²',
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                ],
              ),
            ),
            
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('Formula Perhitungan', [
              pw.Text('Posisi ${result.position}: fc = a×R² + b×R + c',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('R = ${(result.rValue * result.calibrationFactor).toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              pw.Text('Konversi: 1 MPa ≈ 10.197 kg/cm²',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ], borderColor: PdfColors.green300),
            
            pw.SizedBox(height: 12),
            
            _pdfSectionTitle('📋 CATATAN PENTING', bgColor: PdfColors.orange700),
            pw.SizedBox(height: 8),
            
            _pdfInfoBox('Informasi', [
              pw.Text(
                '• Hasil adalah ESTIMASI berdasarkan korelasi empiris\n'
                '• Sesuai SNI 03-4430-1997\n'
                '• Menggunakan rumus korelasi Posisi ${result.position}\n'
                '• Untuk hasil definitif, lakukan uji tekan silinder\n'
                '• Faktor yang mempengaruhi: kelembaban, carbonasi, tekstur permukaan',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ], borderColor: PdfColors.orange300),
            
            if (result.age < 28) ...[
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  border: pw.Border.all(color: PdfColors.orange300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('⚠ Rekomendasi',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Beton berumur ${result.age} hari (< 28 hari)\n'
                      'Disarankan testing ulang setelah 28 hari untuk hasil yang lebih akurat',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
   Future<void> _addUjiKuatPages(pw.Document pdf, Map<String, dynamic> data) async {
    final result = UjiKuatResult.fromMap(data['result']);
    final testData = data['data'];
    
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('📊 HASIL UTAMA', bgColor: PdfColors.red700),
            pw.SizedBox(height: 12),
            
           
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: result.statusKualitas.contains('MEMENUHI') 
                    ? PdfColors.green50 
                    : PdfColors.orange50,
                border: pw.Border.all(
                  color: result.statusKualitas.contains('MEMENUHI') 
                      ? PdfColors.green300 
                      : PdfColors.orange300,
                  width: 2,
                ),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    result.statusKualitas,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text('Kuat Tekan (28 hari)',
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  pw.SizedBox(height: 6),
                  pw.Text('${result.kuatTekan.toStringAsFixed(2)} MPa',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
            
            if (result.pekerjaan != null || result.lokasi != null) ...[
              _pdfSectionTitle('📍 INFORMASI PROYEK', bgColor: PdfColors.purple700),
              pw.SizedBox(height: 8),
              _pdfInfoBox('Data Proyek', [
                if (result.pekerjaan != null)
                  _pdfDetailRow('Nama Pekerjaan', result.pekerjaan!),
                if (result.lokasi != null)
                  _pdfDetailRow('Lokasi Proyek', result.lokasi!),
              ]),
              pw.SizedBox(height: 12),
            ],
            
          
            if (result.hasPhotos()) ...[
              _pdfInfoBox('Dokumentasi', [
                _pdfDetailRow('Jumlah Foto', '${result.getPhotoCount()} foto'),
              ]),
              pw.SizedBox(height: 12),
            ],
            
            _pdfSectionTitle('📅 DATA PENGUJIAN', bgColor: PdfColors.blue700),
            pw.SizedBox(height: 8),
            
            _pdfInfoBox('Tanggal & Umur', [
              _pdfDetailRow('Tanggal Pembuatan (Casting)', 
                  _formatDate(result.tanggalPembuatan)),
              _pdfDetailRow('Tanggal Pengujian (Testing)', 
                  _formatDate(result.tanggalPengujian)),
              _pdfDetailRow('Umur Beton Saat Uji', 
                  '${result.umurBeton} hari', bold: true),
              _pdfDetailRow('Standar Acuan', result.standarAcuan),
              _pdfDetailRow('Mutu Rencana', testData['mutuBeton']),
            ], borderColor: PdfColors.blue300),
          ],
        ),
      ),
    );

   
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('🔬 DIMENSI BENDA UJI', bgColor: PdfColors.green700),
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('Geometri', [
              if (result.standarAcuan == 'SNI' && result.sisiKubus != null) ...[
                _pdfDetailRow('Bentuk', 'Kubus'),
                _pdfDetailRow('Dimensi', 
                    '${(result.panjangKubus ?? result.sisiKubus!).toStringAsFixed(0)} × '
                    '${(result.lebarKubus ?? result.sisiKubus!).toStringAsFixed(0)} × '
                    '${(result.tinggiKubus ?? result.sisiKubus!).toStringAsFixed(0)} mm'),
                _pdfDetailRow('Luas Permukaan', 
                    '${result.luasPermukaan.toStringAsFixed(2)} cm²', bold: true),
              ] else if (result.diameter != null) ...[
                _pdfDetailRow('Bentuk', 'Silinder'),
                _pdfDetailRow('Diameter', 
                    '${result.diameter!.toStringAsFixed(0)} mm (Ø${(result.diameter! / 10).toStringAsFixed(0)} cm)'),
                _pdfDetailRow('Tinggi', 
                    '${(result.diameter! * 2).toStringAsFixed(0)} mm (rasio 2:1)'),
                _pdfDetailRow('Luas Permukaan', 
                    '${result.luasPermukaan.toStringAsFixed(2)} mm²', bold: true),
              ],
              if (result.beratBendaUji != null)
                _pdfDetailRow('Berat Benda Uji', 
                    '${result.beratBendaUji!.toStringAsFixed(2)} kg'),
            ], borderColor: PdfColors.green300),
            
            pw.SizedBox(height: 16),
            
            _pdfSectionTitle('💪 HASIL PEMBEBANAN', bgColor: PdfColors.red700),
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('Data Beban', [
              _pdfDetailRow(
                result.standarAcuan == 'SNI' ? 'Beban Maksimal' : 'Gaya Tekan',
                result.standarAcuan == 'SNI' 
                    ? '${result.bebanMaksimal.toStringAsFixed(2)} ${result.satuanBebanInput ?? "kg/cm²"}'
                    : '${result.bebanMaksimal.toStringAsFixed(2)} kN',
                bold: true,
              ),
              if (result.standarAcuan == 'SNI' && result.kuatTekanUmurUjiKgCm2 != null)
                _pdfDetailRow('Kuat Tekan Umur Uji (${result.umurBeton} hari)', 
                    '${result.kuatTekanUmurUjiKgCm2!.toStringAsFixed(2)} kg/cm² (hasil aktual)'),
              if (result.standarAcuan != 'SNI' && result.kuatTekanUmurUjiMPa != null)
                _pdfDetailRow('Kuat Tekan Umur Uji (${result.umurBeton} hari)', 
                    '${result.kuatTekanUmurUjiMPa!.toStringAsFixed(2)} MPa (hasil aktual)'),
              if (result.standarAcuan != 'SNI' && result.kuatTekanEkivalenKgCm2 != null)
                _pdfDetailRow('Setara Kubus (info)', 
                    '${result.kuatTekanEkivalenKgCm2!.toStringAsFixed(2)} kg/cm²'),
            ], borderColor: PdfColors.red300),
            
            pw.SizedBox(height: 12),
            
            _pdfInfoBox(
              result.umurBeton != 28 ? 'Prediksi Kuat Tekan (Umur 28 Hari)' : 'Kuat Tekan (Umur 28 Hari)', 
              [
                if (result.umurBeton != 28)
                  _pdfDetailRow('Faktor Konversi', 'Menggunakan Tabel PBI'),
                _pdfDetailRow(
                  result.umurBeton != 28 ? 'Kuat Tekan Estimasi (28 Hari)' : 'Kuat Tekan (28 Hari)', 
                  result.standarAcuan == 'SNI'
                      ? '${(result.kuatTekanKubus ?? result.kuatTekan).toStringAsFixed(2)} kg/cm²'
                      : '${result.kuatTekan.toStringAsFixed(2)} MPa', 
                  bold: true,
                ),
                if (result.standarAcuan == 'SNI')
                  _pdfDetailRow('(setara)', '${result.kuatTekan.toStringAsFixed(2)} MPa')
                else if (result.kuatTekanEkivalenKgCm2 != null)
                  _pdfDetailRow('(setara kubus, info)', '${result.kuatTekanEkivalenKgCm2!.toStringAsFixed(2)} kg/cm²'),
              ], 
              borderColor: PdfColors.blue300,
            ),
            
            pw.SizedBox(height: 16),
            
           
            _pdfSectionTitle('📝 KETERANGAN DETAIL', bgColor: PdfColors.grey700),
            pw.SizedBox(height: 8),
            
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                result.keterangan,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
            ),
          ],
        ),
      ),
    );

   
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('📋 CATATAN STANDAR', bgColor: PdfColors.blue700),
            pw.SizedBox(height: 12),
            
            _pdfInfoBox('Informasi Standar', [
              pw.Text(
                result.standarAcuan == 'SNI'
                    ? '• Standar: SNI 03-2847-2002 (Kubus 15×15×15 cm)\n'
                      '• Beton memenuhi syarat jika fc ≥ K yang disyaratkan\n'
                      '• Input beban dalam kg/cm²\n'
                      '• Formula: fc = Beban / Luas permukaan\n'
                      '• Konversi: 1 MPa = 10.197 kg/cm²'
                    : result.standarAcuan == 'BINA MARGA'
                        ? '• Standar: Spesifikasi Bina Marga 2018 Rev 2\n'
                          '• Kriteria individu: fc ≥ 0.85 × fc\'\n'
                          '• Kriteria rata-rata: fc ≥ 1.15 × fc\'\n'
                          '• Input gaya dalam kN (kilonewton)\n'
                          '• Diameter standar: 100 mm atau 150 mm'
                        : '• Standar: ASTM C39 (Silinder)\n'
                          '• Concrete is acceptable if fc ≥ specified fc\'\n'
                          '• Input load in kN (kilonewton)\n'
                          '• Standard diameter: 100 mm or 150 mm',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ], borderColor: PdfColors.blue300),
            
            pw.SizedBox(height: 12),
            
           
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                border: pw.Border.all(color: PdfColors.purple300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Formula Perhitungan:',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  if (result.standarAcuan == 'SNI')
                    pw.Text(
                      'fc = Beban Maksimal (kg/cm²)\n'
                      'fc\'₂₈ = fc × Faktor Konversi Umur',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    )
                  else
                    pw.Text(
                      'fc = (Beban × 1000) / Luas Permukaan\n'
                      'fc\'₂₈ = fc × Faktor Konversi Umur',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                ],
              ),
            ),
            
            if (result.umurBeton < 28) ...[
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  border: pw.Border.all(color: PdfColors.orange300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('⚠ Catatan Penting:',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Beton berumur ${result.umurBeton} hari (< 28 hari)\n'
                      'Hasil telah dikonversi ke umur 28 hari menggunakan faktor PBI',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
   Future<void> _addKonversiBetonPages(pw.Document pdf, KonversiResult result) async {
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('📊 HASIL KONVERSI', bgColor: PdfColors.orange700),
            pw.SizedBox(height: 12),
            
           
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange50,
                border: pw.Border.all(color: PdfColors.orange300, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  pw.Text('Kuat Tekan Estimasi 28 Hari',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '${result.hasilKonversi.toStringAsFixed(2)} ${result.satuanDisplay}',
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Text(
                      'Perhitungan: ${result.kuatTekanBeton.toStringAsFixed(2)} ÷ ${result.faktorKonversi.toStringAsFixed(3)}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
           
            _pdfSectionTitle('📋 DATA INPUT', bgColor: PdfColors.blue700),
            pw.SizedBox(height: 8),
            
            _pdfInfoBox('Parameter Pengujian', [
              _pdfDetailRow('Jenis Benda Uji', result.jenisBendaUjiDisplay),
              _pdfDetailRow('Satuan', result.satuanDisplay),
              _pdfDetailRow('Umur Beton Saat Uji', 
                  '${result.umurBeton.toStringAsFixed(0)} Hari', bold: true),
              _pdfDetailRow('Kuat Tekan Hasil Uji', 
                  '${result.kuatTekanBeton.toStringAsFixed(2)} ${result.satuanDisplay}', 
                  bold: true),
              _pdfDetailRow('Karakteristik Beton', result.karakteristik),
            ], borderColor: PdfColors.blue300),
            
            pw.SizedBox(height: 16),
            
            
            _pdfSectionTitle('🔢 FAKTOR KONVERSI', bgColor: PdfColors.purple700),
            pw.SizedBox(height: 8),
            
            _pdfInfoBox('Faktor dari Tabel PBI', [
              _pdfDetailRow('Faktor K (Tabel PBI)', 
                  result.faktorKonversi.toStringAsFixed(4), bold: true),
              _pdfDetailRow('Referensi', 'Peraturan Beton Indonesia (PBI)'),
              _pdfDetailRow('Metode', 
                  result.umurBeton % 7 == 0 || result.umurBeton == 3 || 
                  result.umurBeton == 14 || result.umurBeton == 21 || 
                  result.umurBeton >= 28
                      ? 'Nilai Tabel Langsung'
                      : 'Interpolasi Linear'),
            ], borderColor: PdfColors.purple300),
          ],
        ),
      ),
    );

   
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfSectionTitle('📐 FORMULA KONVERSI', bgColor: PdfColors.purple700),
            pw.SizedBox(height: 12),
            
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                border: pw.Border.all(color: PdfColors.purple300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Rumus Konversi:',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'fc\'₂₈ = fc\'ᵤ / Kᵤ',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Dimana:\n'
                    'fc\'₂₈ = Kuat tekan umur 28 hari\n'
                    'fc\'ᵤ = Kuat tekan umur uji (${result.umurBeton.toStringAsFixed(0)} hari)\n'
                    'Kᵤ = Faktor konversi (${result.faktorKonversi.toStringAsFixed(4)})',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                  pw.Divider(color: PdfColors.purple300),
                  pw.Text('Contoh Perhitungan:',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${result.kuatTekanBeton.toStringAsFixed(2)} ${result.satuanDisplay} ÷ '
                    '${result.faktorKonversi.toStringAsFixed(4)} = '
                    '${result.hasilKonversi.toStringAsFixed(2)} ${result.satuanDisplay}',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
            _pdfSectionTitle('📊 TABEL FAKTOR KONVERSI PBI', bgColor: PdfColors.grey700),
            pw.SizedBox(height: 8),
            
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Faktor Konversi (Semen Portland Biasa):',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  _pdfTable(
                    [
                      ['3 hari', '0.40'],
                      ['7 hari', '0.65'],
                      ['14 hari', '0.88'],
                      ['21 hari', '0.95'],
                      ['28 hari', '1.00'],
                    ],
                    headers: ['Umur Beton', 'Faktor K'],
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
            _pdfSectionTitle('📋 CATATAN PENTING', bgColor: PdfColors.blue700),
            pw.SizedBox(height: 8),
            
            _pdfInfoBox('Informasi', [
              pw.Text(
                '• Konversi menggunakan tabel faktor PBI (Peraturan Beton Indonesia)\n'
                '• Hasil merupakan estimasi kuat tekan pada umur 28 hari\n'
                '• Jenis benda uji: ${result.jenisBendaUjiDisplay}\n'
                '• Untuk umur diantara nilai tabel dilakukan interpolasi linear\n'
                '• Faktor untuk Semen Portland Pozzolan dapat berbeda\n'
                '• Disarankan dilakukan pengujian aktual pada umur 28 hari untuk verifikasi',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ], borderColor: PdfColors.blue300),
          ],
        ),
      ),
    );
  }

}
