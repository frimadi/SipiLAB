import '../models/sand_cone_test_result.dart';

class CsvExportService {
  static String generateCsv(
    SandConeTestResult result,
    Map<String, double> calculatedResults, {
    String? kontraktor,
    String? lokasi,
    String? pekerjaan,
    String? tanggal,
  }) {
    StringBuffer csv = StringBuffer();
    
    
    csv.writeln('PEMERIKSAAN KEPADATAN DILAPANGAN DENGAN SAND CONE TEST');
    csv.writeln('SNI 03-2828-1992');
    csv.writeln('');
    csv.writeln('KONTRAKTOR,$kontraktor');
    csv.writeln('LOKASI,$lokasi');
    csv.writeln('PEKERJAAN,$pekerjaan');
    csv.writeln('TANGGAL,$tanggal');
    csv.writeln('');
    
    
    csv.writeln('I. KALIBRASI PASIR LABORATORIUM');
    csv.writeln('');
    csv.writeln('BERAT ISI PASIR DENGAN BOTOL ALAT');
    csv.writeln('Uraian,Rumus,Nilai (gram)');
    csv.writeln('Berat Botol + Corong,W1,${result.beratBotolCorong}');
    csv.writeln('Berat Botol + Corong + Air,W2,${result.beratBotolCorongAir}');
    csv.writeln('Volume Botol + Corong,W2-W1,${calculatedResults['volumeBotolCorong']?.toStringAsFixed(2)}');
    csv.writeln('Berat Botol + Corong + Pasir,W3,${result.beratBotolCorongPasir}');
    csv.writeln('Berat Isi Pasir,yp = (W3-W1)/(W2-W1),${calculatedResults['beratIsiPasir']?.toStringAsFixed(2)}');
    csv.writeln('');
    
    
    csv.writeln('II. BERAT ISI PASIR DENGAN TAKARAN');
    csv.writeln('');
    csv.writeln('A. BERAT PASIR DALAM CORONG');
    csv.writeln('Uraian,Rumus,Nilai (gram)');
    csv.writeln('Berat Botol + Corong + Pasir,W4,${result.beratBotolCorongA}');
    csv.writeln('Berat Botol + Corong + Sisa pasir,W5,${result.beratBotolCorongSisaPasir}');
    csv.writeln('Berat Pasir Dalam Corong,W4-W5,${calculatedResults['beratPasirDalamCorong']?.toStringAsFixed(2)}');
    csv.writeln('');
    
    csv.writeln('B. BERAT PASIR DALAM TAKARAN');
    csv.writeln('Uraian,Rumus,Nilai');
    csv.writeln('Isi Takaran,VK,${result.beratBotolCorongB}');
    csv.writeln('Berat botol + Corong + Pasir,W11,${result.beratBotolCorongSisaPasirB}');
    csv.writeln('Berat botol + Corong + Sisa Pasir,W12,${result.beratPasirDalamTakaran}');
    csv.writeln('Berat Pasir Dalam Takaran,W11-W12-(W4-W5),${calculatedResults['beratPasirDalamTakaran']?.toStringAsFixed(2)}');
    csv.writeln('Berat Isi Pasir,yp = W13/VK,${calculatedResults['beratIsiPasirTakaran']?.toStringAsFixed(2)}');
    csv.writeln('');
    
    
    csv.writeln('III. PEMERIKSAAN LAPANGAN');
    csv.writeln('KEPADATAN TANAH');
    csv.writeln('Uraian,Rumus,Nilai');
    csv.writeln('Berat Tanah + Wadah,W8,${result.beratTanahWadah}');
    csv.writeln('Berat Wadah,W9,${result.beratWadah}');
    csv.writeln('Berat Tanah,W8-W9,${calculatedResults['beratTanah']?.toStringAsFixed(2)}');
    csv.writeln('Berat + Botol + Corong + Pasir,W6,${result.beratBotolCorongPasirC}');
    csv.writeln('Berat + Botol + Sisa Pasir,W7,${result.beratBotolSisaPasir}');
    csv.writeln('Berat Pasir Dalam Lubang,W10=(W6-W7)-(W4-W5),${calculatedResults['beratPasirDalamLubang']?.toStringAsFixed(2)}');
    csv.writeln('Isi Lubang,V=W10/yp,${calculatedResults['vLubang']?.toStringAsFixed(2)}');
    csv.writeln('Kadar Air,Wc,${result.kadarAir}');
    csv.writeln('Berat isi tanah kering,yd Lab/yd Lap=yt/(1+Wc),${calculatedResults['beratIsiTanahKeringLapangan']?.toStringAsFixed(2)}');
    csv.writeln('Persentase Kepadatan,yd Lap/yd Lab x 100,${calculatedResults['persentaseKepadatan']?.toStringAsFixed(2)}');
    
    return csv.toString();
  }
  
  static void downloadCsv(String csvContent, String filename) {
  }
}