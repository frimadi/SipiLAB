
class CalibrationTemplate {
  final String id;
  final String name;
  final String description;
  final double w1; 
  final double w2; 
  final double w3; 
  final double w4; 
  final double w5; 
  final DateTime? lastCalibrationDate;
  final String? labName;

  CalibrationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.w1,
    required this.w2,
    required this.w3,
    required this.w4,
    required this.w5,
    this.lastCalibrationDate,
    this.labName,
  });

  
  double get volumeBotol => w2 - w1;
  double get beratIsiPasir => (w3 - w1) / (w2 - w1);
  double get beratPasirDalamCorong => w4 - w5;

  bool get isValid => w1 > 0 && w2 > w1 && w3 > w1 && w4 > 0 && w5 > 0 && w4 > w5;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'w1': w1,
      'w2': w2,
      'w3': w3,
      'w4': w4,
      'w5': w5,
      'lastCalibrationDate': lastCalibrationDate?.toIso8601String(),
      'labName': labName,
    };
  }

  factory CalibrationTemplate.fromJson(Map<String, dynamic> json) {
    return CalibrationTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      w1: (json['w1'] ?? 0).toDouble(),
      w2: (json['w2'] ?? 0).toDouble(),
      w3: (json['w3'] ?? 0).toDouble(),
      w4: (json['w4'] ?? 0).toDouble(),
      w5: (json['w5'] ?? 0).toDouble(),
      lastCalibrationDate: json['lastCalibrationDate'] != null
          ? DateTime.parse(json['lastCalibrationDate'])
          : null,
      labName: json['labName'],
    );
  }

  CalibrationTemplate copyWith({
    String? id,
    String? name,
    String? description,
    double? w1,
    double? w2,
    double? w3,
    double? w4,
    double? w5,
    DateTime? lastCalibrationDate,
    String? labName,
  }) {
    return CalibrationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      w1: w1 ?? this.w1,
      w2: w2 ?? this.w2,
      w3: w3 ?? this.w3,
      w4: w4 ?? this.w4,
      w5: w5 ?? this.w5,
      lastCalibrationDate: lastCalibrationDate ?? this.lastCalibrationDate,
      labName: labName ?? this.labName,
    );
  }
}


class CalibrationTemplateService {
  
  static List<CalibrationTemplate> getDefaultTemplates() {
    return [
      
      CalibrationTemplate(
        id: 'alat_uji_1',
        name: 'Alat Uji 1',
        description: 'Sand Cone Set #001 ',
        w1: 652.50, 
        w2: 5623.00,  
        w3: 8387.00,  
        w4: 8387.00,  
        w5: 6931.00,  
        labName: ' ',
      ),

       
      CalibrationTemplate(
        id: 'alat_uji_2',
        name: 'Alat Uji 2',
        description: 'Sand Cone Set #002',
        w1: 725.60,
        w2: 5590.80,
        w3: 8582.50,
        w4: 8582.50,
        w5: 7188.00,
        labName: ' ',
      ),

      
      CalibrationTemplate(
        id: 'alat_uji_3',
        name: 'Alat Uji 3',
        description: 'Sand Cone Set #003',
        w1: 638.00,
        w2: 5531.50,
        w3: 8253.50,
        w4: 8253.50,
        w5: 6778.00,
        labName: ' ',
      ),

      
      CalibrationTemplate(
        id: 'custom',
        name: 'Kustom',
        description: 'Input manual data kalibrasi alat sendiri',
        w1: 0.0,
        w2: 0.0,
        w3: 0.0,
        w4: 0.0,
        w5: 0.0,
        lastCalibrationDate: null,
        labName: 'Input Manual',
      ),
    ];
  }

  
  static CalibrationTemplate? getTemplateById(String id) {
    try {
      return getDefaultTemplates().firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  
  static String? validateTemplate(CalibrationTemplate template) {
    if (template.id == 'custom') {
      if (template.w1 <= 0) return 'W1 harus bernilai positif';
      if (template.w2 <= template.w1) return 'W2 harus lebih besar dari W1';
      if (template.w3 <= template.w1) return 'W3 harus lebih besar dari W1';
      if (template.w4 <= 0) return 'W4 harus bernilai positif';
      if (template.w5 <= 0) return 'W5 harus bernilai positif';
      if (template.w4 <= template.w5) return 'W4 harus lebih besar dari W5';
    }
    
    if (!template.isValid) {
      return 'Data template tidak valid';
    }
    
    return null; 
  }

  
  static String getTemplateInfo(CalibrationTemplate template) {
    final vb = template.volumeBotol;
    final yp = template.beratIsiPasir;
    final w6 = template.beratPasirDalamCorong;
    
    return '''
${template.name}
${template.description}
${template.labName != null ? 'Lab: ${template.labName}' : ''}
${template.lastCalibrationDate != null ? 'Kalibrasi: ${_formatDate(template.lastCalibrationDate!)}' : ''}

Volume Botol (Vb): ${vb.toStringAsFixed(2)} ml
Berat Isi Pasir (Yp): ${yp.toStringAsFixed(4)} gr/ml
Berat Pasir dalam Corong (W6): ${w6.toStringAsFixed(2)} gram
''';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  
  static Future<void> saveCustomTemplate(CalibrationTemplate template) async {
    
  }

 
  static Future<List<CalibrationTemplate>> loadSavedTemplates() async {
   
    return [];
  }
}