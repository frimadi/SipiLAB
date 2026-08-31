class UjiKuatResult {
  final double bebanMaksimal; 
  final double luasPermukaan; 
  final double kuatTekan; 
  final String statusKualitas;
  final String keterangan;
  final DateTime tanggalPembuatan; 
  final DateTime tanggalPengujian; 
  final int umurBeton; 
  final String standarAcuan; 
  final double? beratBendaUji; 
  
  
  final String? pekerjaan;
  final String? lokasi;
  
  
  final List<String>? photoPaths;
  
  
  final double? sisiKubus; 
  final double? kuatTekanKubus; 
  
  
  final double? panjangKubus; 
  final double? lebarKubus; 
  final double? tinggiKubus; 
  final String? satuanBebanInput; 
  final double? kuatTekanUmurUjiKgCm2; 
  
  final double? diameter; 
  final double? kuatTekanSilinder; 
  final double? kuatTekanEkivalenKgCm2; 
  final double? kuatTekanUmurUjiMPa; 

  UjiKuatResult({
    required this.bebanMaksimal,
    required this.luasPermukaan,
    required this.kuatTekan,
    required this.statusKualitas,
    required this.keterangan,
    required this.tanggalPembuatan,
    required this.tanggalPengujian,
    required this.umurBeton,
    required this.standarAcuan,
    this.beratBendaUji,
    this.pekerjaan,
    this.lokasi,
    this.photoPaths,
    this.sisiKubus,
    this.kuatTekanKubus,
    this.panjangKubus,
    this.lebarKubus,
    this.tinggiKubus,
    this.satuanBebanInput,
    this.kuatTekanUmurUjiKgCm2,
    this.diameter,
    this.kuatTekanSilinder,
    this.kuatTekanEkivalenKgCm2,
    this.kuatTekanUmurUjiMPa,
  });

  
  bool get isPrediksi28Hari => umurBeton != 28;

  Map<String, dynamic> toMap() {
    return {
      'bebanMaksimal': bebanMaksimal,
      'luasPermukaan': luasPermukaan,
      'kuatTekan': kuatTekan,
      'statusKualitas': statusKualitas,
      'keterangan': keterangan,
      'tanggalPembuatan': tanggalPembuatan.toIso8601String(),
      'tanggalPengujian': tanggalPengujian.toIso8601String(),
      'umurBeton': umurBeton,
      'standarAcuan': standarAcuan,
      'beratBendaUji': beratBendaUji,
      'pekerjaan': pekerjaan,
      'lokasi': lokasi,
      'photoPaths': photoPaths,
      'sisiKubus': sisiKubus,
      'kuatTekanKubus': kuatTekanKubus,
      'panjangKubus': panjangKubus,
      'lebarKubus': lebarKubus,
      'tinggiKubus': tinggiKubus,
      'satuanBebanInput': satuanBebanInput,
      'kuatTekanUmurUjiKgCm2': kuatTekanUmurUjiKgCm2,
      'diameter': diameter,
      'kuatTekanSilinder': kuatTekanSilinder,
      'kuatTekanEkivalenKgCm2': kuatTekanEkivalenKgCm2,
      'kuatTekanUmurUjiMPa': kuatTekanUmurUjiMPa,
    };
  }

  factory UjiKuatResult.fromMap(Map<String, dynamic> map) {
    return UjiKuatResult(
      bebanMaksimal: map['bebanMaksimal']?.toDouble() ?? 0.0,
      luasPermukaan: map['luasPermukaan']?.toDouble() ?? 0.0,
      kuatTekan: map['kuatTekan']?.toDouble() ?? 0.0,
      statusKualitas: map['statusKualitas'] ?? '',
      keterangan: map['keterangan'] ?? '',
      tanggalPembuatan: DateTime.parse(map['tanggalPembuatan']),
      tanggalPengujian: DateTime.parse(map['tanggalPengujian']),
      umurBeton: map['umurBeton'] ?? 0,
      standarAcuan: map['standarAcuan'] ?? 'SNI',
      beratBendaUji: map['beratBendaUji']?.toDouble(),
      pekerjaan: map['pekerjaan'],
      lokasi: map['lokasi'],
      photoPaths: map['photoPaths'] != null 
          ? List<String>.from(map['photoPaths']) 
          : null,
      sisiKubus: map['sisiKubus']?.toDouble(),
      kuatTekanKubus: map['kuatTekanKubus']?.toDouble(),
      panjangKubus: map['panjangKubus']?.toDouble(),
      lebarKubus: map['lebarKubus']?.toDouble(),
      tinggiKubus: map['tinggiKubus']?.toDouble(),
      satuanBebanInput: map['satuanBebanInput'],
      kuatTekanUmurUjiKgCm2: map['kuatTekanUmurUjiKgCm2']?.toDouble(),
      diameter: map['diameter']?.toDouble(),
      kuatTekanSilinder: map['kuatTekanSilinder']?.toDouble(),
      kuatTekanEkivalenKgCm2: map['kuatTekanEkivalenKgCm2']?.toDouble(),
      kuatTekanUmurUjiMPa: map['kuatTekanUmurUjiMPa']?.toDouble(),
    );
  }

  bool hasPhotos() => photoPaths != null && photoPaths!.isNotEmpty;
  int getPhotoCount() => photoPaths?.length ?? 0;

  UjiKuatResult copyWith({
    double? bebanMaksimal,
    double? luasPermukaan,
    double? kuatTekan,
    String? statusKualitas,
    String? keterangan,
    DateTime? tanggalPembuatan,
    DateTime? tanggalPengujian,
    int? umurBeton,
    String? standarAcuan,
    double? beratBendaUji,
    String? pekerjaan,
    String? lokasi,
    List<String>? photoPaths,
    double? sisiKubus,
    double? kuatTekanKubus,
    double? panjangKubus,
    double? lebarKubus,
    double? tinggiKubus,
    String? satuanBebanInput,
    double? kuatTekanUmurUjiKgCm2,
    double? diameter,
    double? kuatTekanSilinder,
    double? kuatTekanEkivalenKgCm2,
    double? kuatTekanUmurUjiMPa,
  }) {
    return UjiKuatResult(
      bebanMaksimal: bebanMaksimal ?? this.bebanMaksimal,
      luasPermukaan: luasPermukaan ?? this.luasPermukaan,
      kuatTekan: kuatTekan ?? this.kuatTekan,
      statusKualitas: statusKualitas ?? this.statusKualitas,
      keterangan: keterangan ?? this.keterangan,
      tanggalPembuatan: tanggalPembuatan ?? this.tanggalPembuatan,
      tanggalPengujian: tanggalPengujian ?? this.tanggalPengujian,
      umurBeton: umurBeton ?? this.umurBeton,
      standarAcuan: standarAcuan ?? this.standarAcuan,
      beratBendaUji: beratBendaUji ?? this.beratBendaUji,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      lokasi: lokasi ?? this.lokasi,
      photoPaths: photoPaths ?? this.photoPaths,
      sisiKubus: sisiKubus ?? this.sisiKubus,
      kuatTekanKubus: kuatTekanKubus ?? this.kuatTekanKubus,
      panjangKubus: panjangKubus ?? this.panjangKubus,
      lebarKubus: lebarKubus ?? this.lebarKubus,
      tinggiKubus: tinggiKubus ?? this.tinggiKubus,
      satuanBebanInput: satuanBebanInput ?? this.satuanBebanInput,
      kuatTekanUmurUjiKgCm2: kuatTekanUmurUjiKgCm2 ?? this.kuatTekanUmurUjiKgCm2,
      diameter: diameter ?? this.diameter,
      kuatTekanSilinder: kuatTekanSilinder ?? this.kuatTekanSilinder,
      kuatTekanEkivalenKgCm2: kuatTekanEkivalenKgCm2 ?? this.kuatTekanEkivalenKgCm2,
      kuatTekanUmurUjiMPa: kuatTekanUmurUjiMPa ?? this.kuatTekanUmurUjiMPa,
    );
  }
}

class UjiKuatData {
  
  final double? sisiKubus; 
  
  
  final double? panjangKubus; 
  final double? lebarKubus; 
  final double? tinggiKubus; 
  
  
  final double? diameter; 
  
  
  final double beban; 
  final String satuanBeban; 
  final DateTime tanggalPembuatan; 
  final DateTime tanggalPengujian; 
  final String mutuBeton; 
  final double? beratBendaUji;
  
  final String? pekerjaan;
  final String? lokasi;
  final List<String>? photoPaths;

  UjiKuatData({
    this.sisiKubus,
    this.panjangKubus,
    this.lebarKubus,
    this.tinggiKubus,
    this.diameter,
    required this.beban,
    this.satuanBeban = 'kN',
    required this.tanggalPembuatan,
    required this.tanggalPengujian,
    required this.mutuBeton,
    this.beratBendaUji,
    this.pekerjaan,
    this.lokasi,
    this.photoPaths,
  });
  
  bool isValid() {
    return (sisiKubus != null && sisiKubus! > 0) || 
           (panjangKubus != null && lebarKubus != null && 
            panjangKubus! > 0 && lebarKubus! > 0) ||
           (diameter != null && diameter! > 0);
  }
  
  
  bool isKubus() => (sisiKubus != null && sisiKubus! > 0) ||
      (panjangKubus != null && lebarKubus != null &&
       panjangKubus! > 0 && lebarKubus! > 0);

  
  double get panjangKubusEfektif => panjangKubus ?? sisiKubus ?? 0;
  double get lebarKubusEfektif => lebarKubus ?? sisiKubus ?? 0;
  double? get tinggiKubusEfektif => tinggiKubus ?? sisiKubus;
  
 
  int getUmurBeton() {
    return tanggalPengujian.difference(tanggalPembuatan).inDays;
  }

  bool hasPhotos() => photoPaths != null && photoPaths!.isNotEmpty;

  UjiKuatData copyWith({
    double? sisiKubus,
    double? panjangKubus,
    double? lebarKubus,
    double? tinggiKubus,
    double? diameter,
    double? beban,
    String? satuanBeban,
    DateTime? tanggalPembuatan,
    DateTime? tanggalPengujian,
    String? mutuBeton,
    double? beratBendaUji,
    String? pekerjaan,
    String? lokasi,
    List<String>? photoPaths,
  }) {
    return UjiKuatData(
      sisiKubus: sisiKubus ?? this.sisiKubus,
      panjangKubus: panjangKubus ?? this.panjangKubus,
      lebarKubus: lebarKubus ?? this.lebarKubus,
      tinggiKubus: tinggiKubus ?? this.tinggiKubus,
      diameter: diameter ?? this.diameter,
      beban: beban ?? this.beban,
      satuanBeban: satuanBeban ?? this.satuanBeban,
      tanggalPembuatan: tanggalPembuatan ?? this.tanggalPembuatan,
      tanggalPengujian: tanggalPengujian ?? this.tanggalPengujian,
      mutuBeton: mutuBeton ?? this.mutuBeton,
      beratBendaUji: beratBendaUji ?? this.beratBendaUji,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      lokasi: lokasi ?? this.lokasi,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}
