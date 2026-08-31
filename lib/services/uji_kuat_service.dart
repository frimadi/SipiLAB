import '../models/uji_kuat_result.dart';


class UjiKuatService {
  static const Map<String, double> SNI_MUTU_BETON = {
    'K-175': 175.0,
    'K-225': 225.0,
    'K-250': 250.0,
    'K-300': 300.0,
    'K-350': 350.0,
    'K-400': 400.0,
    'K-500': 500.0,
  };

  static const double SISI_KUBUS_STANDAR = 150.0; 
  static const List<double> DIAMETER_SILINDER_STANDAR = [100.0, 150.0]; 
  static const double RASIO_TINGGI_DIAMETER = 2.0;
  static const double FAKTOR_KUBUS_KE_SILINDER = 0.83;
  static const double FAKTOR_KGCM2_TO_MPA = 0.0980665; 
  static const double FAKTOR_KN_TO_KGF = 101.97; 
  
  
  Map<String, dynamic> validateDimensiKubus(double sisiKubus) {
    List<String> errors = [];
    if (sisiKubus != SISI_KUBUS_STANDAR) {
      errors.add('Sisi kubus standar SNI adalah ${SISI_KUBUS_STANDAR} mm (15 cm)');
    }
    return {
      'valid': errors.isEmpty,
      'errors': errors,
    };
  }
  
  Map<String, dynamic> validateDimensiSilinder(double diameter, double tinggi) {
    List<String> errors = [];
    
    if (!DIAMETER_SILINDER_STANDAR.contains(diameter)) {
      errors.add('Diameter harus ${DIAMETER_SILINDER_STANDAR.join(" atau ")} mm');
    }
    
    double tinggiSeharusnya = diameter * RASIO_TINGGI_DIAMETER;
    if ((tinggi - tinggiSeharusnya).abs() > 5.0) {
      errors.add('Tinggi harus ${tinggiSeharusnya.toStringAsFixed(0)} mm (rasio 2:1)');
    }
    
    return {
      'valid': errors.isEmpty,
      'errors': errors,
      'tinggiSeharusnya': tinggiSeharusnya,
    };
  }
  
  Map<String, dynamic> validateMutuBeton(String mutu, String standar) {
    List<String> errors = [];
    double? nilai = _parseInputNumber(mutu);
    
    if (nilai == null || nilai <= 0) {
      errors.add('Nilai mutu beton harus > 0');
      return {'valid': false, 'errors': errors};
    }
    
    if (standar == 'SNI') {
      if (nilai < 100 || nilai > 600) {
        errors.add('Nilai K untuk SNI umumnya antara 100-600 kg/cm²');
      }
    } else {
      if (nilai < 10 || nilai > 100) {
        errors.add('Nilai fc\' umumnya antara 10-100 MPa');
      }
    }
    
    return {'valid': errors.isEmpty, 'errors': errors};
  }


  
  
  
  double hitungLuasPermukaanKubus(double panjang, double lebar) {
    double panjangCm = panjang / 10.0;
    double lebarCm = lebar / 10.0;
    double luasCm2 = panjangCm * lebarCm;
    return luasCm2;
  }

  
  double konversiKNKeKgf(double bebanKN) {
    return bebanKN * FAKTOR_KN_TO_KGF;
  }

  
  
  double konversiMPaKeKgCm2EkuivalenKubus(double kuatTekanMPa) {
    double mpaEkuivalenKubus = kuatTekanMPa / FAKTOR_KUBUS_KE_SILINDER;
    return mpaEkuivalenKubus / FAKTOR_KGCM2_TO_MPA;
  }

  double hitungLuasPermukaanSilinder(double diameter) {
    
    double luas = 0.25 * (22.0 / 7.0) * diameter * diameter;
    return luas;
  }

  
  
  
  double hitungKuatTekanKubus(double bebanKg, double luasPermukaanCm2) {
    double kuatTekanKgCm2 = bebanKg / luasPermukaanCm2;
    return kuatTekanKgCm2;
  }

 
  double hitungKuatTekanSilinder(double bebanKN, double luasPermukaanMm2) {
    double kuatTekanMPa = (bebanKN * 1000.0) / luasPermukaanMm2;
    return kuatTekanMPa;
  }

  
  
  double faktorKoreksiUmur(int umurBeton) {
    if (umurBeton >= 28) return 1.0;
    
    
    if (umurBeton == 21) return 0.95; 
    if (umurBeton == 14) return 0.88; 
    if (umurBeton == 7) return 0.65;
    if (umurBeton == 3) return 0.40;
    
   
    if (umurBeton > 21) {
      return 0.95 + (umurBeton - 21) * (1.0 - 0.95) / 7; 
    } else if (umurBeton > 14) {
      return 0.88 + (umurBeton - 14) * (0.95 - 0.88) / 7; 
    } else if (umurBeton > 7) {
      return 0.65 + (umurBeton - 7) * (0.88 - 0.65) / 7; 
    } else if (umurBeton > 3) {
      return 0.40 + (umurBeton - 3) * (0.65 - 0.40) / 4;
    }
    return 0.40;
  }

  double konversiKe28Hari(double kuatTekan, int umurBeton) {
    double faktor = faktorKoreksiUmur(umurBeton);
    if (faktor == 0 || faktor.isNaN) return kuatTekan;
    return kuatTekan / faktor;
  }

 
  
  double konversiKgCm2ToMPa(double kgCm2) {
    return kgCm2 * FAKTOR_KGCM2_TO_MPA;
  }

  double? _parseInputNumber(String input) {
    if (input.isEmpty) return null;
    String cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  double parseMutuBeton(String mutu, String standar) {
    double? nilai = _parseInputNumber(mutu);
    if (nilai == null) return 0;
    
    if (standar == 'SNI') {
      
      return nilai; 
    } else {
     
      return nilai;
    }
  }

  String formatMutuDisplay(String mutu, String standar) {
    double? nilai = _parseInputNumber(mutu);
    if (nilai == null) return mutu;
    
    if (standar == 'SNI') {
      double mpa = nilai * FAKTOR_KGCM2_TO_MPA;
      return 'K-${nilai.toStringAsFixed(0)} (${nilai.toStringAsFixed(0)} kg/cm² ≈ ${mpa.toStringAsFixed(2)} MPa)';
    } else {
      return 'fc\' ${nilai.toStringAsFixed(0)} MPa';
    }
  }

  
  
  String evaluasiKualitasSNI(double kuatTekan28KgCm2, double mutuRencanaKgCm2) {
    double persentase = (kuatTekan28KgCm2 / mutuRencanaKgCm2) * 100;
    
    if (persentase >= 100) {
      return 'MEMENUHI SYARAT';
    } else if (persentase >= 95) {
      return 'BATAS MINIMUM';
    } else if (persentase >= 85) {
      return 'PERLU PERHATIAN';
    } else {
      return 'TIDAK MEMENUHI SYARAT';
    }
  }

 
  String evaluasiKualitasBinaMarga(double kuatTekan28MPa, double mutuRencanaMPa) {
    const double faktorMinimumIndividu = 0.85;
    double batasMinimum = mutuRencanaMPa * faktorMinimumIndividu;
    
    
    if (kuatTekan28MPa >= mutuRencanaMPa) {
        return 'MEMENUHI SYARAT';
    } else if (kuatTekan28MPa >= batasMinimum) {
        return 'PERLU PERHATIAN (Lulus Batas Minimum Individu)';
    } else {
        return 'TIDAK MEMENUHI SYARAT';
    }
  }
  
  String evaluasiKualitasASTM(double kuatTekanMPa, double mutuRencanaMPa) {
      return evaluasiKualitasBinaMarga(kuatTekanMPa, mutuRencanaMPa);
  }

  
  
  String generateKeterangan(
    double kuatTekan28MPa, 
    double mutuRencanaMPa, 
    int umurBeton,
    String standar,
    String mutuBetonInput,
    DateTime tanggalPembuatan,
    DateTime tanggalPengujian,
    {double? sisiKubus, double? panjangKubus, double? lebarKubus,
      double? tinggiKubus, double? diameter, double? beratBendaUji,
      String? pekerjaan, String? lokasi}
  ) {
    double selisih = kuatTekan28MPa - mutuRencanaMPa;
    double persentase = (kuatTekan28MPa / mutuRencanaMPa) * 100;
    
    String mutuDisplay = formatMutuDisplay(mutuBetonInput, standar);
    
    String umurInfo = umurBeton < 28 
        ? 'Hasil ini telah dikonversi ke umur beton 28 hari menggunakan faktor koreksi PBI. ' 
        : '';
    
    StringBuffer hasil = StringBuffer();
    
   
    if (pekerjaan != null && pekerjaan.isNotEmpty) {
      hasil.write('Pekerjaan: $pekerjaan. ');
    }
    if (lokasi != null && lokasi.isNotEmpty) {
      hasil.write('Lokasi: $lokasi. ');
    }
    if ((pekerjaan != null && pekerjaan.isNotEmpty) || 
        (lokasi != null && lokasi.isNotEmpty)) {
      hasil.write('\n\n');
    }
    
   
    hasil.write('Tanggal Pembuatan: ${_formatTanggal(tanggalPembuatan)}. ');
    hasil.write('Tanggal Pengujian: ${_formatTanggal(tanggalPengujian)}. ');
    hasil.write('Umur Beton: $umurBeton hari. ');
    hasil.write('\n\n');
    
   
    if (standar == 'SNI' && sisiKubus != null) {
      double p = panjangKubus ?? sisiKubus;
      double l = lebarKubus ?? sisiKubus;
      double t = tinggiKubus ?? sisiKubus;
      hasil.write('Pengujian menggunakan benda uji KUBUS ${p.toStringAsFixed(0)}×${l.toStringAsFixed(0)}×${t.toStringAsFixed(0)} mm. ');
    } else if (diameter != null) {
      hasil.write('Pengujian menggunakan benda uji SILINDER diameter ${diameter.toStringAsFixed(0)} mm. ');
    }
    
    if (beratBendaUji != null) {
      hasil.write('Berat benda uji: ${beratBendaUji.toStringAsFixed(2)} kg. ');
    }
    
    
    hasil.write('${umurInfo}Kuat tekan yang diperoleh: ${kuatTekan28MPa.toStringAsFixed(2)} MPa. '); 
    hasil.write('Mutu rencana: $mutuDisplay. ');
    
    if (selisih >= 0) {
      hasil.write('Kelebihan: ${selisih.toStringAsFixed(2)} MPa (${persentase.toStringAsFixed(1)}% dari mutu rencana).'); 
    } else {
      hasil.write('Kekurangan: ${selisih.abs().toStringAsFixed(2)} MPa (${persentase.toStringAsFixed(1)}% dari mutu rencana).'); 
    }
    
    if (standar == 'SNI') {
      hasil.write('\n\nSesuai SNI 03-2847-2002, beton kubus dianggap memenuhi syarat jika kuat tekan rata-rata ≥ K yang disyaratkan.');
    } else if (standar == 'BINA MARGA') {
      hasil.write('\n\nSesuai Spesifikasi Bina Marga 2018 Rev 2, beton memenuhi syarat jika hasil individu ≥ 0.85×fc\' dan rata-rata ≥ 1.15×fc\'.');
    } else {
      hasil.write('\n\nBased on ASTM C39, concrete is acceptable if compressive strength ≥ specified fc\'.');
    }
    
    return hasil.toString();
  }

  String _formatTanggal(DateTime tanggal) {
    const List<String> bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  
  
  UjiKuatResult prosesUjiKuat(UjiKuatData data, String standar) {
    double luasPermukaan;
    double kuatTekan28; 
    double mutuRencana;
    String statusKualitas;
    
    int umurBeton = data.getUmurBeton();
    
    if (standar == 'SNI' && data.isKubus()) {
     
      double panjang = data.panjangKubusEfektif;
      double lebar = data.lebarKubusEfektif;
      double? tinggi = data.tinggiKubusEfektif;
      
      luasPermukaan = hitungLuasPermukaanKubus(panjang, lebar);
      
      
      double bebanKg = data.satuanBeban == 'kN'
          ? konversiKNKeKgf(data.beban)
          : data.beban;
      
     
      double kuatTekanUmurUjiKgCm2 = hitungKuatTekanKubus(bebanKg, luasPermukaan);
      
      
      double kuatTekan28KgCm2 = konversiKe28Hari(kuatTekanUmurUjiKgCm2, umurBeton);
      
      
      mutuRencana = parseMutuBeton(data.mutuBeton, standar); 
      
      
      statusKualitas = evaluasiKualitasSNI(kuatTekan28KgCm2, mutuRencana);
      
      
      kuatTekan28 = konversiKgCm2ToMPa(kuatTekan28KgCm2); 

      
      String keterangan = generateKeterangan(
        kuatTekan28, 
        konversiKgCm2ToMPa(mutuRencana), 
        umurBeton, 
        standar,
        data.mutuBeton,
        data.tanggalPembuatan,
        data.tanggalPengujian,
        sisiKubus: data.sisiKubus ?? panjang,
        panjangKubus: panjang,
        lebarKubus: lebar,
        tinggiKubus: tinggi,
        beratBendaUji: data.beratBendaUji,
        pekerjaan: data.pekerjaan,
        lokasi: data.lokasi,
      );
      
      return UjiKuatResult(
        bebanMaksimal: data.beban, 
        luasPermukaan: luasPermukaan, 
        kuatTekan: kuatTekan28, 
        statusKualitas: statusKualitas,
        keterangan: keterangan,
        tanggalPembuatan: data.tanggalPembuatan,
        tanggalPengujian: data.tanggalPengujian,
        umurBeton: umurBeton,
        standarAcuan: standar,
        beratBendaUji: data.beratBendaUji,
        pekerjaan: data.pekerjaan,
        lokasi: data.lokasi,
        photoPaths: data.photoPaths,
        sisiKubus: data.sisiKubus,
        kuatTekanKubus: kuatTekan28KgCm2, 
        panjangKubus: panjang,
        lebarKubus: lebar,
        tinggiKubus: tinggi,
        satuanBebanInput: data.satuanBeban,
      );
      
    } else if (data.diameter != null) {
     
      
      luasPermukaan = hitungLuasPermukaanSilinder(data.diameter!);
      double kuatTekanUmurUjiMPa = hitungKuatTekanSilinder(data.beban, luasPermukaan);
      kuatTekan28 = konversiKe28Hari(kuatTekanUmurUjiMPa, umurBeton);
      mutuRencana = parseMutuBeton(data.mutuBeton, standar); 
      
      if (standar == 'BINA MARGA') {
        statusKualitas = evaluasiKualitasBinaMarga(kuatTekan28, mutuRencana);
      } else {
        statusKualitas = evaluasiKualitasASTM(kuatTekan28, mutuRencana);
      }
      
      String keterangan = generateKeterangan(
        kuatTekan28, 
        mutuRencana, 
        umurBeton, 
        standar,
        data.mutuBeton,
        data.tanggalPembuatan,
        data.tanggalPengujian,
        diameter: data.diameter,
        beratBendaUji: data.beratBendaUji,
        pekerjaan: data.pekerjaan,
        lokasi: data.lokasi,
      );
      
      return UjiKuatResult(
        bebanMaksimal: data.beban,
        luasPermukaan: luasPermukaan,
        kuatTekan: kuatTekan28,
        statusKualitas: statusKualitas,
        keterangan: keterangan,
        tanggalPembuatan: data.tanggalPembuatan,
        tanggalPengujian: data.tanggalPengujian,
        umurBeton: umurBeton,
        standarAcuan: standar,
        beratBendaUji: data.beratBendaUji,
        pekerjaan: data.pekerjaan,
        lokasi: data.lokasi,
        photoPaths: data.photoPaths,
        diameter: data.diameter,
        kuatTekanSilinder: kuatTekan28,
        
        kuatTekanEkivalenKgCm2: konversiMPaKeKgCm2EkuivalenKubus(kuatTekan28),
      );
    } else {
      throw Exception('Data tidak valid: Dimensi benda uji tidak lengkap.');
    }
  }
}