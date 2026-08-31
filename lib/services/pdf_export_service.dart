import '../models/sand_cone_test_result.dart';

class PdfExportService {
   static Future<void> generatePdf(
    SandConeTestResult result,
    Map<String, double> calculatedResults, {
    String? kontraktor,
    String? lokasi,
    String? pekerjaan,
    String? tanggal,
  }) async {
   
    print('PDF Export tidak diimplementasikan. Gunakan package pdf dan printing.');
  }
  
  static dynamic _buildTable(List<List<String>> data) {
   
    return null;
  }
}