class SandConeTestService {
  static const double PERCENT_DIVIDER = 100.0;
  static const double MIN_VALID_VALUE = 0.001;
  static const double STANDARD_KEPADATAN_MIN = 95.0;

  
  static CalculationResult hitungVolumeBotol({
    required double w1,
    required double w2,
  }) {
    if (!_validatePositive(w1, 'W1')) {
      return CalculationResult.error('W1 harus bernilai positif');
    }
    if (!_validatePositive(w2, 'W2')) {
      return CalculationResult.error('W2 harus bernilai positif');
    }
    
    final vb = w2 - w1;
    
    if (vb < MIN_VALID_VALUE) {
      return CalculationResult.error('W2 harus lebih besar dari W1');
    }
    
    return CalculationResult.success(vb);
  }

  
  static CalculationResult hitungBeratIsiPasir({
    required double w1,
    required double w2,
    required double w3,
  }) {
    if (!_validatePositive(w1, 'W1')) {
      return CalculationResult.error('W1 harus bernilai positif');
    }
    if (!_validatePositive(w2, 'W2')) {
      return CalculationResult.error('W2 harus bernilai positif');
    }
    if (!_validatePositive(w3, 'W3')) {
      return CalculationResult.error('W3 harus bernilai positif');
    }
    
    final vb = w2 - w1;
    
    if (vb < MIN_VALID_VALUE) {
      return CalculationResult.error('Volume botol terlalu kecil');
    }
    
    final yp = (w3 - w1) / vb;
    
    if (yp < MIN_VALID_VALUE) {
      return CalculationResult.error('Hasil perhitungan tidak valid');
    }
    
    return CalculationResult.success(yp);
  }

  
  static CalculationResult hitungBeratPasirDalamCorong({
    required double w4,
    required double w5,
  }) {
    if (!_validatePositive(w4, 'W4')) {
      return CalculationResult.error('W4 harus bernilai positif');
    }
    if (!_validatePositive(w5, 'W5')) {
      return CalculationResult.error('W5 harus bernilai positif');
    }
    
    final w6 = w4 - w5;
    
    if (w6 < MIN_VALID_VALUE) {
      return CalculationResult.error('W4 harus lebih besar dari W5');
    }
    
    return CalculationResult.success(w6);
  }

  
  static CalculationResult hitungBeratAgregatBasah({
    required double w7, 
    required double w8,  
  }) {
    if (!_validatePositive(w7, 'W7')) {
      return CalculationResult.error('W7 harus bernilai positif');
    }
    if (!_validatePositive(w8, 'W8')) {
      return CalculationResult.error('W8 harus bernilai positif');
    }
    
    final w9 = w8 - w7;
    
    if (w9 < MIN_VALID_VALUE) {
      return CalculationResult.error('W8 harus lebih besar dari W7');
    }
    
    return CalculationResult.success(w9);
  }

 
  static CalculationResult hitungBeratPasirCorongLubang({
    required double w10,  
    required double w11, 
  }) {
    if (!_validatePositive(w10, 'W10')) {
      return CalculationResult.error('W10 harus bernilai positif');
    }
    if (!_validatePositive(w11, 'W11')) {
      return CalculationResult.error('W11 harus bernilai positif');
    }
    
    final w12 = w10 - w11;
    
    if (w12 < MIN_VALID_VALUE) {
      return CalculationResult.error('W10 harus lebih besar dari W11');
    }
    
    return CalculationResult.success(w12);
  }

  
  static CalculationResult hitungBeratPasirDalamLubang({
    required double w12,  
    required double w6,   
  }) {
    if (!_validatePositive(w12, 'W12')) {
      return CalculationResult.error('W12 harus bernilai positif');
    }
    if (!_validatePositive(w6, 'W6')) {
      return CalculationResult.error('W6 harus bernilai positif');
    }
    
    final w13 = w12 - w6;
    
    if (w13 < MIN_VALID_VALUE) {
      return CalculationResult.error('W12 harus lebih besar dari W6');
    }
    
    return CalculationResult.success(w13);
  }

  
  static CalculationResult hitungVolumeLubang({
    required double w13,  
    required double yp,   
  }) {
    if (!_validatePositive(w13, 'W13')) {
      return CalculationResult.error('W13 harus bernilai positif');
    }
    if (!_validatePositive(yp, 'Yp')) {
      return CalculationResult.error('Yp harus bernilai positif');
    }
    
    if (yp < MIN_VALID_VALUE) {
      return CalculationResult.error('Berat isi pasir terlalu kecil');
    }
    
    final v = w13 / yp;
    
    return CalculationResult.success(v);
  }

 
  static CalculationResult hitungBeratIsiTanahBasah({
    required double w9, 
    required double v,   
  }) {
    if (!_validatePositive(w9, 'W9')) {
      return CalculationResult.error('W9 harus bernilai positif');
    }
    if (!_validatePositive(v, 'V')) {
      return CalculationResult.error('V harus bernilai positif');
    }
    
    if (v < MIN_VALID_VALUE) {
      return CalculationResult.error('Volume lubang terlalu kecil');
    }
    
    final yd = w9 / v;
    
    return CalculationResult.success(yd);
  }

  
  static CalculationResult hitungBeratIsiTanahKering({
    required double yd,       
    required double kadarAir, 
  }) {
    if (!_validatePositive(yd, 'Yd')) {
      return CalculationResult.error('Yd harus bernilai positif');
    }
    if (kadarAir < 0) {
      return CalculationResult.error('Kadar air tidak boleh negatif');
    }
    
    
    if (kadarAir.abs() < MIN_VALID_VALUE) {
      return CalculationResult.success(yd);
    }
    
    final ydLap = yd / (1 + kadarAir / PERCENT_DIVIDER);
    
    return CalculationResult.success(ydLap);
  }

  
  static CalculationResult hitungDerajatKepadatan({
    required double ydLap,  
    required double ydLab, 
  }) {
    if (!_validatePositive(ydLap, 'Yd Lap')) {
      return CalculationResult.error('Yd Lap harus positif');
    }
    if (!_validatePositive(ydLab, 'Yd Lab')) {
      return CalculationResult.error('Yd Lab harus positif');
    }
    
    if (ydLab < MIN_VALID_VALUE) {
      return CalculationResult.error('Yd Lab terlalu kecil');
    }
    
    final derajat = (ydLap / ydLab) * PERCENT_DIVIDER;
    
    return CalculationResult.success(derajat);
  }

 
  
  static ComprehensiveResult hitungSemuaHasil({
    required double w1,
    required double w2,
    required double w3,
    required double w4,
    required double w5,
    required double w7,
    required double w8,
    required double w10,
    required double w11,
    required double kadarAir,
    required double ydLab,
  }) {
    final results = <String, CalculationResult>{};
    
   
    final vb = hitungVolumeBotol(w1: w1, w2: w2);
    results['volumeBotol'] = vb;
    if (!vb.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: vb.errorMessage!,
      );
    }
    
    final yp = hitungBeratIsiPasir(w1: w1, w2: w2, w3: w3);
    results['beratIsiPasir'] = yp;
    if (!yp.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: yp.errorMessage!,
      );
    }
    
    final w6 = hitungBeratPasirDalamCorong(w4: w4, w5: w5);
    results['beratPasirDalamCorong'] = w6;
    if (!w6.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: w6.errorMessage!,
      );
    }
    
   
    final w9 = hitungBeratAgregatBasah(w7: w7, w8: w8);
    results['beratAgregatBasah'] = w9;
    if (!w9.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: w9.errorMessage!,
      );
    }
    
    final w12 = hitungBeratPasirCorongLubang(w10: w10, w11: w11);
    results['beratPasirCorongLubang'] = w12;
    if (!w12.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: w12.errorMessage!,
      );
    }
    
    final w13 = hitungBeratPasirDalamLubang(w12: w12.value, w6: w6.value);
    results['beratPasirDalamLubang'] = w13;
    if (!w13.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: w13.errorMessage!,
      );
    }
    
    final v = hitungVolumeLubang(w13: w13.value, yp: yp.value);
    results['volumeLubang'] = v;
    if (!v.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: v.errorMessage!,
      );
    }
    
    final yd = hitungBeratIsiTanahBasah(w9: w9.value, v: v.value);
    results['beratIsiTanahBasah'] = yd;
    if (!yd.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: yd.errorMessage!,
      );
    }
    
    final ydLap = hitungBeratIsiTanahKering(yd: yd.value, kadarAir: kadarAir);
    results['beratIsiTanahKering'] = ydLap;
    if (!ydLap.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: ydLap.errorMessage!,
      );
    }
    
    final derajat = hitungDerajatKepadatan(ydLap: ydLap.value, ydLab: ydLab);
    results['derajatKepadatan'] = derajat;
    if (!derajat.isValid) {
      return ComprehensiveResult(
        results: results,
        isAllValid: false,
        firstError: derajat.errorMessage!,
      );
    }
    
    return ComprehensiveResult(
      results: results,
      isAllValid: true,
      firstError: null,
    );
  }

 
  
  static bool _validatePositive(double value, String fieldName) {
    return value > 0;
  }

  static String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  static bool isKepadatanMemenuhiStandar(double derajatKepadatan) {
    return derajatKepadatan >= STANDARD_KEPADATAN_MIN;
  }

  static String getStatusKepadatan(double derajatKepadatan) {
    if (derajatKepadatan >= 100) return 'Sangat Padat';
    if (derajatKepadatan >= 95) return 'Memenuhi Standar';
    if (derajatKepadatan >= 90) return 'Cukup Padat';
    return 'Kurang Padat';
  }
}



class CalculationResult {
  final double value;
  final bool isValid;
  final String? errorMessage;

  CalculationResult.success(this.value)
      : isValid = true,
        errorMessage = null;

  CalculationResult.error(this.errorMessage)
      : value = 0.0,
        isValid = false;

  @override
  String toString() {
    if (isValid) {
      return 'Success: $value';
    } else {
      return 'Error: $errorMessage';
    }
  }
}

class ComprehensiveResult {
  final Map<String, CalculationResult> results;
  final bool isAllValid;
  final String? firstError;

  ComprehensiveResult({
    required this.results,
    required this.isAllValid,
    this.firstError,
  });

  double? getValue(String key) {
    final result = results[key];
    return result?.isValid == true ? result!.value : null;
  }

  Map<String, double> getValidValues() {
    final validValues = <String, double>{};
    results.forEach((key, result) {
      if (result.isValid) {
        validValues[key] = result.value;
      }
    });
    return validValues;
  }

  String getSummary() {
    if (isAllValid) {
      final kepadatan = getValue('derajatKepadatan') ?? 0;
      final status = SandConeTestService.getStatusKepadatan(kepadatan);
      return 'Perhitungan berhasil! Kepadatan: ${SandConeTestService.formatNumber(kepadatan)}% - $status';
    } else {
      return 'Error: $firstError';
    }
  }

  @override
  String toString() {
    return getSummary();
  }
}