

class KonversiResult {
  final double umurBeton; 
  final double faktorKonversi;
  final double kuatTekanBeton; 
  final double hasilKonversi; 
  final double hasilKonversiSilinder; 
  final double faktorBentuk; 
  final String karakteristik;
  final String jenisBendaUji; 
  final String satuan; 

  KonversiResult({
    required this.umurBeton,
    required this.faktorKonversi,
    required this.kuatTekanBeton,
    required this.hasilKonversi,
    required this.hasilKonversiSilinder, 
    required this.faktorBentuk,
    required this.karakteristik,
    required this.jenisBendaUji,
    required this.satuan,
  });

 
  String get satuanDisplay => satuan == 'kg_cm2' ? 'Kg/Cm²' : 'MPa (N/mm²)';
  String get jenisBendaUjiDisplay => jenisBendaUji == 'kubus' ? 'Kubus' : 'Silinder';
  
 
  String get infoBentuk {
    if (jenisBendaUji == 'kubus') {
      return 'Dikoreksi ke Silinder (× 0.83)';
    } else {
      return 'Tidak ada koreksi (sudah Silinder)';
    }
  }

  Map<String, dynamic> toJson() => {
        'umurBeton': umurBeton,
        'faktorKonversi': faktorKonversi,
        'kuatTekanBeton': kuatTekanBeton,
        'hasilKonversi': hasilKonversi,
        'hasilKonversiSilinder': hasilKonversiSilinder,
        'faktorBentuk': faktorBentuk,
        'karakteristik': karakteristik,
        'jenisBendaUji': jenisBendaUji,
        'satuan': satuan,
      };

  factory KonversiResult.fromJson(Map<String, dynamic> json) => KonversiResult(
        umurBeton: json['umurBeton'],
        faktorKonversi: json['faktorKonversi'],
        kuatTekanBeton: json['kuatTekanBeton'],
        hasilKonversi: json['hasilKonversi'],
        hasilKonversiSilinder: json['hasilKonversiSilinder'] ?? json['hasilKonversi'], 
        faktorBentuk: json['faktorBentuk'] ?? 1.0,
        karakteristik: json['karakteristik'],
        jenisBendaUji: json['jenisBendaUji'] ?? 'kubus',
        satuan: json['satuan'] ?? 'kg_cm2',
      );

  
  factory KonversiResult.fromMap(Map<String, dynamic> map) => 
      KonversiResult.fromJson(map);

 
  Map<String, dynamic> toMap() => toJson();
}