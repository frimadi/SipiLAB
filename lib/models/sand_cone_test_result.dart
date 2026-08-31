class SandConeTestResult {
 
  
  final double beratBotolCorong;
  final double beratBotolCorongAir;
  final double volumeBotolCorong;
  final double beratBotolCorongPasir;
  final double beratIsiPasir;
  final double beratBotolCorongA;
  final double beratBotolCorongSisaPasir;
  final double beratPasirDalamCorong;

  
  
  final double beratWadah;
  final double beratTanahWadah;
  final double beratTanah;
  final double beratBotolCorongB;
  final double beratBotolCorongSisaPasirB;
  final double beratPasirDalamTakaran;
  final double beratPasirDalamLubang;
  final double vLubang;
  final double beratIsiTanah;
  final double kadarAir;
  final double beratIsiTanahKering;
  final double beratIsiPasirB;
  final double persentaseKepadatan;
  
  
  final double beratBotolCorongPasirC;
  final double beratBotolSisaPasir;

 
  final String? kontraktor;
  final String? lokasiProyek;
  final String? jenisPekerjaan;
  final DateTime? tanggalPengujian;

 
  
  final List<String> photoPaths;

  
  
  SandConeTestResult({
   
    this.beratBotolCorong = 0.0,
    this.beratBotolCorongAir = 0.0,
    this.volumeBotolCorong = 0.0,
    this.beratBotolCorongPasir = 0.0,
    this.beratIsiPasir = 0.0,
    this.beratBotolCorongA = 0.0,
    this.beratBotolCorongSisaPasir = 0.0,
    this.beratPasirDalamCorong = 0.0,
    
   
    this.beratWadah = 0.0,
    this.beratTanahWadah = 0.0,
    this.beratTanah = 0.0,
    this.beratBotolCorongB = 0.0,
    this.beratBotolCorongSisaPasirB = 0.0,
    this.beratPasirDalamTakaran = 0.0,
    this.beratPasirDalamLubang = 0.0,
    this.vLubang = 0.0,
    this.beratIsiTanah = 0.0,
    this.kadarAir = 0.0,
    this.beratIsiTanahKering = 0.0,
    this.beratIsiPasirB = 0.0,
    this.persentaseKepadatan = 0.0,
    
   
    this.beratBotolCorongPasirC = 0.0,
    this.beratBotolSisaPasir = 0.0,
    
   
    this.kontraktor,
    this.lokasiProyek,
    this.jenisPekerjaan,
    this.tanggalPengujian,
    
   
    this.photoPaths = const [],
  });

 
  
  bool get memenuhiStandar => persentaseKepadatan >= 95.0;
  
  String get statusKepadatan {
    if (persentaseKepadatan >= 100) return 'Sangat Padat';
    if (persentaseKepadatan >= 95) return 'Memenuhi Standar';
    if (persentaseKepadatan >= 90) return 'Cukup Padat';
    return 'Kurang Padat';
  }
  
  bool get isDataComplete {
    return beratBotolCorong > 0 &&
           volumeBotolCorong > 0 &&
           beratTanah > 0 &&
           vLubang > 0;
  }

  bool get hasDokumentasiFoto => photoPaths.isNotEmpty;
  int get jumlahFoto => photoPaths.length;
  
  
  bool get hasProjectInfo => 
      (kontraktor != null && kontraktor!.isNotEmpty) ||
      (lokasiProyek != null && lokasiProyek!.isNotEmpty) ||
      (jenisPekerjaan != null && jenisPekerjaan!.isNotEmpty);

  
  
  SandConeTestResult copyWith({
    double? beratBotolCorong,
    double? beratBotolCorongAir,
    double? volumeBotolCorong,
    double? beratBotolCorongPasir,
    double? beratIsiPasir,
    double? beratBotolCorongA,
    double? beratBotolCorongSisaPasir,
    double? beratPasirDalamCorong,
    double? beratWadah,
    double? beratTanahWadah,
    double? beratTanah,
    double? beratBotolCorongB,
    double? beratBotolCorongSisaPasirB,
    double? beratPasirDalamTakaran,
    double? beratPasirDalamLubang,
    double? vLubang,
    double? beratIsiTanah,
    double? kadarAir,
    double? beratIsiTanahKering,
    double? beratIsiPasirB,
    double? persentaseKepadatan,
    double? beratBotolCorongPasirC,
    double? beratBotolSisaPasir,
    String? kontraktor,
    String? lokasiProyek,
    String? jenisPekerjaan,
    DateTime? tanggalPengujian,
    List<String>? photoPaths,
  }) {
    return SandConeTestResult(
      beratBotolCorong: beratBotolCorong ?? this.beratBotolCorong,
      beratBotolCorongAir: beratBotolCorongAir ?? this.beratBotolCorongAir,
      volumeBotolCorong: volumeBotolCorong ?? this.volumeBotolCorong,
      beratBotolCorongPasir: beratBotolCorongPasir ?? this.beratBotolCorongPasir,
      beratIsiPasir: beratIsiPasir ?? this.beratIsiPasir,
      beratBotolCorongA: beratBotolCorongA ?? this.beratBotolCorongA,
      beratBotolCorongSisaPasir: beratBotolCorongSisaPasir ?? this.beratBotolCorongSisaPasir,
      beratPasirDalamCorong: beratPasirDalamCorong ?? this.beratPasirDalamCorong,
      beratWadah: beratWadah ?? this.beratWadah,
      beratTanahWadah: beratTanahWadah ?? this.beratTanahWadah,
      beratTanah: beratTanah ?? this.beratTanah,
      beratBotolCorongB: beratBotolCorongB ?? this.beratBotolCorongB,
      beratBotolCorongSisaPasirB: beratBotolCorongSisaPasirB ?? this.beratBotolCorongSisaPasirB,
      beratPasirDalamTakaran: beratPasirDalamTakaran ?? this.beratPasirDalamTakaran,
      beratPasirDalamLubang: beratPasirDalamLubang ?? this.beratPasirDalamLubang,
      vLubang: vLubang ?? this.vLubang,
      beratIsiTanah: beratIsiTanah ?? this.beratIsiTanah,
      kadarAir: kadarAir ?? this.kadarAir,
      beratIsiTanahKering: beratIsiTanahKering ?? this.beratIsiTanahKering,
      beratIsiPasirB: beratIsiPasirB ?? this.beratIsiPasirB,
      persentaseKepadatan: persentaseKepadatan ?? this.persentaseKepadatan,
      beratBotolCorongPasirC: beratBotolCorongPasirC ?? this.beratBotolCorongPasirC,
      beratBotolSisaPasir: beratBotolSisaPasir ?? this.beratBotolSisaPasir,
      kontraktor: kontraktor ?? this.kontraktor,
      lokasiProyek: lokasiProyek ?? this.lokasiProyek,
      jenisPekerjaan: jenisPekerjaan ?? this.jenisPekerjaan,
      tanggalPengujian: tanggalPengujian ?? this.tanggalPengujian,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'beratBotolCorong': beratBotolCorong,
      'beratBotolCorongAir': beratBotolCorongAir,
      'volumeBotolCorong': volumeBotolCorong,
      'beratBotolCorongPasir': beratBotolCorongPasir,
      'beratIsiPasir': beratIsiPasir,
      'beratBotolCorongA': beratBotolCorongA,
      'beratBotolCorongSisaPasir': beratBotolCorongSisaPasir,
      'beratPasirDalamCorong': beratPasirDalamCorong,
      'beratWadah': beratWadah,
      'beratTanahWadah': beratTanahWadah,
      'beratTanah': beratTanah,
      'beratBotolCorongB': beratBotolCorongB,
      'beratBotolCorongSisaPasirB': beratBotolCorongSisaPasirB,
      'beratPasirDalamTakaran': beratPasirDalamTakaran,
      'beratPasirDalamLubang': beratPasirDalamLubang,
      'vLubang': vLubang,
      'beratIsiTanah': beratIsiTanah,
      'kadarAir': kadarAir,
      'beratIsiTanahKering': beratIsiTanahKering,
      'beratIsiPasirB': beratIsiPasirB,
      'persentaseKepadatan': persentaseKepadatan,
      'beratBotolCorongPasirC': beratBotolCorongPasirC,
      'beratBotolSisaPasir': beratBotolSisaPasir,
      'kontraktor': kontraktor,
      'lokasiProyek': lokasiProyek,
      'jenisPekerjaan': jenisPekerjaan,
      'tanggalPengujian': tanggalPengujian?.toIso8601String(),
      'photoPaths': photoPaths,
    };
  }

  factory SandConeTestResult.fromJson(Map<String, dynamic> json) {
    try {
      return SandConeTestResult(
        beratBotolCorong: _toDouble(json['beratBotolCorong']),
        beratBotolCorongAir: _toDouble(json['beratBotolCorongAir']),
        volumeBotolCorong: _toDouble(json['volumeBotolCorong']),
        beratBotolCorongPasir: _toDouble(json['beratBotolCorongPasir']),
        beratIsiPasir: _toDouble(json['beratIsiPasir']),
        beratBotolCorongA: _toDouble(json['beratBotolCorongA']),
        beratBotolCorongSisaPasir: _toDouble(json['beratBotolCorongSisaPasir']),
        beratPasirDalamCorong: _toDouble(json['beratPasirDalamCorong']),
        beratWadah: _toDouble(json['beratWadah']),
        beratTanahWadah: _toDouble(json['beratTanahWadah']),
        beratTanah: _toDouble(json['beratTanah']),
        beratBotolCorongB: _toDouble(json['beratBotolCorongB']),
        beratBotolCorongSisaPasirB: _toDouble(json['beratBotolCorongSisaPasirB']),
        beratPasirDalamTakaran: _toDouble(json['beratPasirDalamTakaran']),
        beratPasirDalamLubang: _toDouble(json['beratPasirDalamLubang']),
        vLubang: _toDouble(json['vLubang']),
        beratIsiTanah: _toDouble(json['beratIsiTanah']),
        kadarAir: _toDouble(json['kadarAir']),
        beratIsiTanahKering: _toDouble(json['beratIsiTanahKering']),
        beratIsiPasirB: _toDouble(json['beratIsiPasirB']),
        persentaseKepadatan: _toDouble(json['persentaseKepadatan']),
        beratBotolCorongPasirC: _toDouble(json['beratBotolCorongPasirC']),
        beratBotolSisaPasir: _toDouble(json['beratBotolSisaPasir']),
        kontraktor: json['kontraktor'] as String?,
        lokasiProyek: json['lokasiProyek'] as String?,
        jenisPekerjaan: json['jenisPekerjaan'] as String?,
        tanggalPengujian: json['tanggalPengujian'] != null 
            ? DateTime.parse(json['tanggalPengujian']) 
            : null,
        photoPaths: json['photoPaths'] != null 
            ? List<String>.from(json['photoPaths']) 
            : [],
      );
    } catch (e) {
      return SandConeTestResult();
    }
  }

 
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  
  
  @override
  String toString() {
    return 'SandConeTestResult('
        'derajatKepadatan: $persentaseKepadatan%, '
        'status: $statusKepadatan, '
        'vLubang: $vLubang ml, '
        'beratIsiTanah: $beratIsiTanah gr/ml, '
        'jumlahFoto: $jumlahFoto, '
        'hasProjectInfo: $hasProjectInfo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SandConeTestResult &&
        other.beratBotolCorong == beratBotolCorong &&
        other.beratBotolCorongAir == beratBotolCorongAir &&
        other.volumeBotolCorong == volumeBotolCorong &&
        other.beratBotolCorongPasir == beratBotolCorongPasir &&
        other.beratIsiPasir == beratIsiPasir &&
        other.beratBotolCorongA == beratBotolCorongA &&
        other.beratBotolCorongSisaPasir == beratBotolCorongSisaPasir &&
        other.beratPasirDalamCorong == beratPasirDalamCorong &&
        other.beratWadah == beratWadah &&
        other.beratTanahWadah == beratTanahWadah &&
        other.beratTanah == beratTanah &&
        other.beratBotolCorongB == beratBotolCorongB &&
        other.beratBotolCorongSisaPasirB == beratBotolCorongSisaPasirB &&
        other.beratPasirDalamTakaran == beratPasirDalamTakaran &&
        other.beratPasirDalamLubang == beratPasirDalamLubang &&
        other.vLubang == vLubang &&
        other.beratIsiTanah == beratIsiTanah &&
        other.kadarAir == kadarAir &&
        other.beratIsiTanahKering == beratIsiTanahKering &&
        other.beratIsiPasirB == beratIsiPasirB &&
        other.persentaseKepadatan == persentaseKepadatan;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      beratBotolCorong,
      beratBotolCorongAir,
      volumeBotolCorong,
      beratBotolCorongPasir,
      beratIsiPasir,
      beratBotolCorongA,
      beratBotolCorongSisaPasir,
      beratPasirDalamCorong,
      beratWadah,
      beratTanahWadah,
      beratTanah,
      beratBotolCorongB,
      beratBotolCorongSisaPasirB,
      beratPasirDalamTakaran,
      beratPasirDalamLubang,
      vLubang,
      beratIsiTanah,
      kadarAir,
      beratIsiTanahKering,
      beratIsiPasirB,
      persentaseKepadatan,
    ]);
  }
}