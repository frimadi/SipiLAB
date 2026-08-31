import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hammer_test_result.dart';

class HammerTestService {
  static const String _storageKey = 'hammer_test_history';
  final List<HammerTestResult> _testHistory = [];

  List<HammerTestResult> get testHistory => List.unmodifiable(_testHistory);

  

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _testHistory.clear();
        _testHistory.addAll(
          jsonList.map((json) => HammerTestResult.fromMap(json)).toList()
        );
      }
    } catch (e) {
      print('Error loading history: $e');
      rethrow;
    }
  }

  Future<bool> saveTestResult(HammerTestResult result) async {
    try {
      _testHistory.add(result);
      await _saveHistory();
      return true;
    } catch (e) {
      print('Error saving test result: $e');
      return false;
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = 
          _testHistory.map((test) => test.toMap()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving history: $e');
      rethrow;
    }
  }

  Future<void> deleteTestResult(String testId) async {
    _testHistory.removeWhere((test) => test.testId == testId);
    await _saveHistory();
  }

  Future<void> clearAllHistory() async {
    _testHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  HammerTestResult? getTestResult(String testId) {
    try {
      return _testHistory.firstWhere((test) => test.testId == testId);
    } catch (e) {
      return null;
    }
  }

  

  ValidationResult validateReboundValue(int value, String hammerType) {
    Map<String, Map<String, int>> ranges = {
      'N-Type': {'min': 10, 'max': 70},
    };

    int min = ranges[hammerType]?['min'] ?? 0;
    int max = ranges[hammerType]?['max'] ?? 100;

    if (value < min || value > max) {
      return ValidationResult(
        isValid: false,
        message: 'Nilai harus antara $min - $max untuk $hammerType',
      );
    }

    return ValidationResult(isValid: true);
  }

  ValidationResult validateTestConfiguration({
    required String standard,
    required String hammerType,
    required String orientation,
    required int age,
  }) {
    if (age < 3) {
      return ValidationResult(
        isValid: false,
        message: 'Umur beton minimal 3 hari untuk hammer test',
      );
    }

    if (!['SNI', 'ASTM'].contains(standard)) {
      return ValidationResult(
        isValid: false,
        message: 'Standar harus SNI atau ASTM',
      );
    }

    if (!['N-Type'].contains(hammerType)) {
      return ValidationResult(
        isValid: false,
        message: 'Tipe hammer tidak valid',
      );
    }

    if (!['horizontal', 'upward', 'downward'].contains(orientation)) {
      return ValidationResult(
        isValid: false,
        message: 'Orientasi harus horizontal, upward, atau downward',
      );
    }

    return ValidationResult(isValid: true);
  }

 

  String generateReport(HammerTestResult result) {
    StringBuffer report = StringBuffer();

    report.writeln('╔════════════════════════════════════════════════╗');
    report.writeln('║      LAPORAN HAMMER TEST N-34 (KUBUS)         ║');
    report.writeln('╚════════════════════════════════════════════════╝');
    report.writeln('');
    report.writeln('📍 INFORMASI TEST');
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    report.writeln('ID Test        : ${result.testId}');
    report.writeln('Tanggal        : ${_formatDate(result.testDate)}');
     if (result.testedBy.isNotEmpty) {
    report.writeln('Pekerja        : ${result.testedBy}');
  }
    report.writeln('Lokasi         : ${result.location}');
    report.writeln('Standar        : ${result.standard}');
    report.writeln('Tipe Hammer    : ${result.hammerType}');
    report.writeln('Sudut Pukulan  : ${result.orientationDescription}');
    report.writeln('Posisi         : ${result.position} - ${result.positionDescription}');
    report.writeln('Umur Beton     : ${result.age} hari');
    report.writeln('');

    report.writeln('📊 DATA PEMBACAAN (R) Ke-');
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    for (int i = 0; i < result.reboundValues.length; i++) {
      report.write('${(i + 1).toString().padLeft(2)}: ${result.reboundValues[i].toString().padLeft(2)}    ');
      if ((i + 1) % 4 == 0) report.writeln();
    }
    if (result.reboundValues.length % 4 != 0) report.writeln();
    report.writeln('');

    report.writeln('📈 ANALISIS STATISTIK');
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    report.writeln('Jumlah Data            : ${result.reboundValues.length}');
    report.writeln('Rata-rata (R)          : ${result.rValue.toStringAsFixed(2)}');
    report.writeln('Standar Deviasi        : ${result.standardDeviation.toStringAsFixed(2)}');
    report.writeln('Koefisien Variasi (CV) : ${result.coefficientOfVariation.toStringAsFixed(2)}%');
    report.writeln('Status Kualitas        : ${result.qualityStatus}');
    report.writeln('');

    if (result.calibrationFactor != 1.0) {
      report.writeln('⚙️ KOREKSI KALIBRASI ALAT');
      report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      report.writeln('Rata-rata sebelum kalibrasi : ${result.rValue.toStringAsFixed(2)}');
      report.writeln('Faktor Kalibrasi            : ${result.calibrationFactor.toStringAsFixed(8)}');
      report.writeln('R setelah kalibrasi         : ${result.rAfterCalibration.toStringAsFixed(2)}');
      report.writeln('');
    }

    report.writeln('💪 HASIL KUAT TEKAN (σb)');
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    report.writeln('Kuat Tekan (kg/cm²)    : ${result.compressiveStrengthKgCm2.toStringAsFixed(2)} kg/cm²');
    report.writeln('Kuat Tekan (MPa)       : ${result.compressiveStrengthMPa.toStringAsFixed(2)} MPa');
    report.writeln('Spesifikasi            : ${_getConcreteGrade(result.compressiveStrengthMPa)}');
    report.writeln('');

    report.writeln('📐 RUMUS YANG DIGUNAKAN (POSISI ${result.position})');
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    final coefMPa = result.koefisienMPa[result.position]!;
    final coefKg = result.koefisienKgCm2[result.position]!;
    final r = result.rAfterCalibration;
    
    report.writeln('Formula MPa:');
    report.writeln('  fc = ${coefMPa[0]}×R² + ${coefMPa[1]}×R + (${coefMPa[2]})');
    report.writeln('  fc = ${coefMPa[0]}×${r.toStringAsFixed(2)}² + ${coefMPa[1]}×${r.toStringAsFixed(2)} + (${coefMPa[2]})');
    report.writeln('  fc = ${result.compressiveStrengthMPa.toStringAsFixed(2)} MPa');
    report.writeln('');
    report.writeln('Formula kg/cm²:');
    report.writeln('  fc = ${coefKg[0]}×R² + ${coefKg[1]}×R + (${coefKg[2]})');
    report.writeln('  fc = ${coefKg[0]}×${r.toStringAsFixed(2)}² + ${coefKg[1]}×${r.toStringAsFixed(2)} + (${coefKg[2]})');
    report.writeln('  fc = ${result.compressiveStrengthKgCm2.toStringAsFixed(2)} kg/cm²');
    report.writeln('');

    report.writeln('📋 CATATAN PENTING');
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    report.writeln('1. Hasil ini adalah ESTIMASI berdasarkan korelasi empiris');
    report.writeln('2. Sesuai SNI 03-4430-1997');
    report.writeln('3. Untuk hasil definitif, lakukan uji tekan silinder');
    report.writeln('4. Konversi: 1 MPa = 10.197 kg/cm²');
    report.writeln('5. Faktor yang mempengaruhi: kelembaban, carbonasi, tekstur');
    report.writeln('');
    
    report.writeln(getRecommendation(result));

    return report.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _getConcreteGrade(double mpa) {
    if (mpa < 15) return 'Di bawah K-150';
    if (mpa < 20) return 'K-150 sampai K-200';
    if (mpa < 25) return 'K-200 sampai K-250';
    if (mpa < 30) return 'K-250 sampai K-300';
    if (mpa < 35) return 'K-300 sampai K-350';
    return 'K-350 ke atas';
  }

  
  TestStatistics getOverallStatistics() {
    if (_testHistory.isEmpty) {
      return TestStatistics(
        totalTests: 0,
        averageStrength: 0,
        minStrength: 0,
        maxStrength: 0,
      );
    }

    List<double> strengths = _testHistory
        .map((test) => test.estimatedCompressiveStrength)
        .toList();

    return TestStatistics(
      totalTests: _testHistory.length,
      averageStrength: strengths.reduce((a, b) => a + b) / strengths.length,
      minStrength: strengths.reduce((a, b) => a < b ? a : b),
      maxStrength: strengths.reduce((a, b) => a > b ? a : b),
    );
  }

 

  String getRecommendation(HammerTestResult result) {
    double strength = result.estimatedCompressiveStrength;
    double cov = result.coefficientOfVariation;

    StringBuffer rec = StringBuffer();
    rec.writeln('💡 REKOMENDASI');
    rec.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    
    if (cov > 8) {
      rec.writeln('⚠️  Koefisien Variasi tinggi (${cov.toStringAsFixed(1)}%)');
      rec.writeln('    → Permukaan beton mungkin tidak homogen');
      rec.writeln('    → Disarankan mengulang test di area lain');
      rec.writeln('');
    }

    
    if (strength < 15) {
      rec.writeln('❌ Kuat tekan RENDAH (<15 MPa)');
      rec.writeln('   WAJIB core drill test untuk investigasi');
      rec.writeln('   Tidak disarankan untuk struktur beban');
    } else if (strength >= 15 && strength < 20) {
      rec.writeln('⚠️  Kuat tekan CUKUP RENDAH (15-20 MPa)');
      rec.writeln('   Sesuai untuk struktur non-struktural');
      rec.writeln('   Pertimbangkan verifikasi core drill');
    } else if (strength >= 20 && strength < 25) {
      rec.writeln('✓ Kuat tekan CUKUP (20-25 MPa)');
      rec.writeln('  Sesuai untuk bangunan 1-2 lantai');
      rec.writeln('  Mutu beton setara K-200 hingga K-250');
    } else if (strength >= 25 && strength < 35) {
      rec.writeln('✓✓ Kuat tekan BAIK (25-35 MPa)');
      rec.writeln('   Sesuai untuk bangunan umum 2-5 lantai');
      rec.writeln('   Mutu beton setara K-250 hingga K-350');
    } else {
      rec.writeln('✓✓✓ Kuat tekan SANGAT BAIK (>35 MPa)');
      rec.writeln('    Sesuai untuk struktur dengan beban tinggi');
      rec.writeln('    Mutu beton setara K-350 ke atas');
    }

    if (result.age < 28) {
      rec.writeln('');
      rec.writeln('📅 Catatan: Beton berumur ${result.age} hari');
      rec.writeln('   Disarankan testing ulang setelah 28 hari');
    }

    return rec.toString();
  }
}



class ValidationResult {
  final bool isValid;
  final String? message;

  ValidationResult({
    required this.isValid,
    this.message,
  });
}

class TestStatistics {
  final int totalTests;
  final double averageStrength;
  final double minStrength;
  final double maxStrength;

  TestStatistics({
    required this.totalTests,
    required this.averageStrength,
    required this.minStrength,
    required this.maxStrength,
  });
}