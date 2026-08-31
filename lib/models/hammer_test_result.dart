import 'dart:math';


class HammerTestResult {
  static const int DECIMAL_DISPLAY = 2;
  static const int DECIMAL_INTERNAL = 4;

  final String testId;
  final DateTime testDate;
  final String testedBy; 
  final String location;
  final String standard; 
  final String hammerType; 
  final String
      orientation; 
  final String position; 
  final List<int> reboundValues;
  final int age; 
  final double calibrationFactor; 
  final List<String> photoPaths; 

  HammerTestResult({
    required this.testId,
    required this.testDate,
    this.testedBy = '', 
    required this.location,
    required this.standard,
    this.hammerType = 'N-Type',
    this.orientation = 'horizontal',
    this.position = 'A',
    required this.reboundValues,
    required this.age,
    this.calibrationFactor = 1.0,
    this.photoPaths = const [],
  });

 
  bool get hasDokumentasiFoto => photoPaths.isNotEmpty;

  
  int get jumlahFoto => photoPaths.length;

  
  Map<String, List<double>> get koefisienMPa => {
        'A': [0.011, 0.8569, -12.615],
        'B': [0.011, 0.8845, -8.1916],
        'C': [0.0156, 0.5544, -14.081],
      };

 
  Map<String, List<double>> get koefisienKgCm2 => {
        'A': [0.1152, 8.7435, -128.72],
        'B': [0.1121, 9.0253, -83.588],
        'C': [0.159, 5.657, -143.69],
      };

 

  bool get isValidReadingCount {
    return reboundValues.length >= 10;
  }

  
  double get averageRebound {
    if (reboundValues.isEmpty) return 0;
    return reboundValues.reduce((a, b) => a + b) / reboundValues.length;
  }

  
  double get rValue {
    return averageRebound;
  }

  
  double get rAfterCalibration {
    return rValue * calibrationFactor;
  }


  double get rSquared {
    double r = rAfterCalibration;
    return r * r;
  }

  
  double get standardDeviation {
    if (reboundValues.length < 2) return 0;

    double avg = averageRebound;
    double sumSquares = 0;

    for (int value in reboundValues) {
      sumSquares += pow(value - avg, 2);
    }

    double variance = sumSquares / (reboundValues.length - 1);
    double sd = sqrt(variance);

    return double.parse(sd.toStringAsFixed(DECIMAL_DISPLAY));
  }

  
  double get coefficientOfVariation {
    if (averageRebound == 0) return 0;

    double cv = (standardDeviation / averageRebound) * 100;
    return double.parse(cv.toStringAsFixed(DECIMAL_DISPLAY));
  }

  
  String get qualityStatus {
    double cv = coefficientOfVariation;
    if (cv < 3) return 'Sangat Baik';
    if (cv < 5) return 'Baik';
    if (cv < 8) return 'Cukup';
    return 'Kurang Baik';
  }

  
  double get compressiveStrengthKgCm2 {
    double r = rAfterCalibration;
    if (r <= 0) return 0;

    double fc = 0;

    if (standard == 'SNI' && hammerType == 'N-Type') {
      List<double> coef = koefisienKgCm2[position] ?? koefisienKgCm2['A']!;
      fc = coef[0] * rSquared + coef[1] * r + coef[2];
    }

    if (fc <= 0) return 0;
    return double.parse(fc.toStringAsFixed(DECIMAL_DISPLAY));
  }

  
  double get compressiveStrengthMPa {
    double r = rAfterCalibration;
    if (r <= 0) return 0;

    double fc = 0;

    if (standard == 'SNI' && hammerType == 'N-Type') {
      List<double> coef = koefisienMPa[position] ?? koefisienMPa['A']!;
      fc = coef[0] * rSquared + coef[1] * r + coef[2];
    } else if (standard == 'ASTM' && hammerType == 'N-Type') {
      fc = 1.75 * r - 32;
    }

    if (fc <= 0) return 0;
    return double.parse(fc.toStringAsFixed(DECIMAL_DISPLAY));
  }

  double get estimatedCompressiveStrength => compressiveStrengthMPa;

 
  String get positionDescription {
    switch (position) {
      case 'A':
        return 'Horizontal (Dinding/Kolom dari Samping)';
      case 'B':
        return 'Vertikal ⬆️ (Plat/Balok dari Bawah)';
      case 'C':
        return 'Vertikal ⬇️ (Lantai/Plat dari Atas)';
      default:
        return 'Posisi A (Default)';
    }
  }

  String get orientationDescription {
    switch (orientation) {
      case 'horizontal':
        return '0° (Horizontal/Samping)';
      case 'downward':
        return '-90° (Vertikal ke bawah)';
      case 'upward':
        return '+90° (Vertikal ke atas)';
      default:
        return 'Horizontal';
    }
  }

  

  Map<String, dynamic> toMap() => {
        'testId': testId,
        'testDate': testDate.toIso8601String(),
        'testedBy': testedBy, 
        'location': location,
        'standard': standard,
        'hammerType': hammerType,
        'orientation': orientation,
        'position': position,
        'reboundValues': reboundValues,
        'age': age,
        'calibrationFactor': calibrationFactor,
        'photoPaths': photoPaths,
      };

  factory HammerTestResult.fromMap(Map<String, dynamic> map) {
    return HammerTestResult(
      testId: map['testId'] as String,
      testDate: DateTime.parse(map['testDate'] as String),
      testedBy: map['testedBy'] as String? ?? '',
      location: map['location'] as String,
      standard: map['standard'] as String,
      hammerType: map['hammerType'] as String? ?? 'N-Type',
      orientation: map['orientation'] as String,
      position: map['position'] as String? ?? 'A',
      reboundValues: List<int>.from(map['reboundValues'] as List),
      age: map['age'] as int,
      calibrationFactor: map['calibrationFactor'] as double? ?? 1.0,
      photoPaths: map['photoPaths'] != null
          ? List<String>.from(map['photoPaths'])
          : const [],
    );
  }

  HammerTestResult copyWith({
    String? testId,
    DateTime? testDate,
    String? testedBy,
    String? location,
    String? standard,
    String? hammerType,
    String? orientation,
    String? position,
    List<int>? reboundValues,
    int? age,
    double? calibrationFactor,
    List<String>? photoPaths,
  }) {
    return HammerTestResult(
      testId: testId ?? this.testId,
      testDate: testDate ?? this.testDate,
      testedBy: testedBy ?? this.testedBy, 
      location: location ?? this.location,
      standard: standard ?? this.standard,
      hammerType: hammerType ?? this.hammerType,
      orientation: orientation ?? this.orientation,
      position: position ?? this.position,
      reboundValues: reboundValues ?? List.from(this.reboundValues),
      age: age ?? this.age,
      calibrationFactor: calibrationFactor ?? this.calibrationFactor,
      photoPaths: photoPaths ?? List.from(this.photoPaths),
    );
  }

  

  void printDetails() {
    print('╔════════════════════════════════════════╗');
    print('║   HASIL UJI SCHMIDT HAMMER (N-TYPE)   ║');
    print('╚════════════════════════════════════════╝');
    print('');
    print('📍 INFORMASI TEST:');
    print('   ID: $testId');
    if (testedBy.isNotEmpty) {
      print('   Pekerja: $testedBy');
    }
    print('   Lokasi: $location');
    print('   Posisi: $position ($positionDescription)');
    print('   Orientasi: $orientationDescription');
    print('   Standard: $standard');
    print('   Umur: $age hari');
    if (hasDokumentasiFoto) {
      print('   📸 Foto: $jumlahFoto foto');
    }
    print('');
    print('📊 DATA PEMBACAAN:');
    print('   Raw Data: $reboundValues');
    print('   Jumlah: ${reboundValues.length}');
    print('');
    print('📈 STATISTIK (SESUAI EXCEL):');
    print('   Rata-rata (R): ${rValue.toStringAsFixed(DECIMAL_DISPLAY)}');
    print(
        '   Standar Deviasi: ${standardDeviation.toStringAsFixed(DECIMAL_DISPLAY)}');
    print(
        '   Koefisien Variasi: ${coefficientOfVariation.toStringAsFixed(DECIMAL_DISPLAY)}%');
    print('   Status Kualitas: $qualityStatus');
    print('');
    if (calibrationFactor != 1.0) {
      print('⚙️ KALIBRASI:');
      print('   Faktor: ${calibrationFactor.toStringAsFixed(8)}');
      print(
          '   R Terkoreksi: ${rAfterCalibration.toStringAsFixed(DECIMAL_DISPLAY)}');
      print('');
    }
    print('💪 HASIL KUAT TEKAN:');
    print(
        '   kg/cm²: ${compressiveStrengthKgCm2.toStringAsFixed(DECIMAL_DISPLAY)} kg/cm²');
    print(
        '   MPa: ${compressiveStrengthMPa.toStringAsFixed(DECIMAL_DISPLAY)} MPa');
    print('');
    print('📐 FORMULA YANG DIGUNAKAN (POS $position):');
    final coef = koefisienMPa[position]!;
    print('   fc = ${coef[0]}×R² + ${coef[1]}×R + (${coef[2]})');
    print(
        '   fc = ${coef[0]}×${rAfterCalibration.toStringAsFixed(2)}² + ${coef[1]}×${rAfterCalibration.toStringAsFixed(2)} + (${coef[2]})');
    print(
        '   fc = ${compressiveStrengthMPa.toStringAsFixed(DECIMAL_DISPLAY)} MPa');
    print('');
    print('╚════════════════════════════════════════╝');
  }
}
