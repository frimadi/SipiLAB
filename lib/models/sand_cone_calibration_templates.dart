import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Format tanggal dd/MM/yyyy
String formatTanggalKalibrasi(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

double _toDoubleValue(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

DateTime? _toDateValue(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

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

  bool get isValid =>
      w1 > 0 && w2 > w1 && w3 > w1 && w4 > 0 && w5 > 0 && w4 > w5;

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
      w1: _toDoubleValue(json['w1']),
      w2: _toDoubleValue(json['w2']),
      w3: _toDoubleValue(json['w3']),
      w4: _toDoubleValue(json['w4']),
      w5: _toDoubleValue(json['w5']),
      lastCalibrationDate: _toDateValue(json['lastCalibrationDate']),
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

/// Satu versi data kalibrasi sebuah alat (nilai W1-W5 + tanggal kalibrasi).
/// Daftar versi per alat disimpan terbaru di depan; indeks 0 = versi aktif.
class CalibrationVersion {
  final double w1;
  final double w2;
  final double w3;
  final double w4;
  final double w5;
  final DateTime? tanggalKalibrasi;
  final DateTime savedAt;

  CalibrationVersion({
    required this.w1,
    required this.w2,
    required this.w3,
    required this.w4,
    required this.w5,
    required this.tanggalKalibrasi,
    required this.savedAt,
  });

  double get volumeBotol => w2 - w1;
  double get beratIsiPasir => (w2 - w1) == 0 ? 0 : (w3 - w1) / (w2 - w1);
  double get beratPasirDalamCorong => w4 - w5;

  /// Kunci pembanding (nilai + tanggal), dipakai untuk mendeteksi versi yang sama.
  String get key {
    final tgl = tanggalKalibrasi == null
        ? '-'
        : '${tanggalKalibrasi!.year}-${tanggalKalibrasi!.month}-${tanggalKalibrasi!.day}';
    return '$w1|$w2|$w3|$w4|$w5|$tgl';
  }

  /// Mengembalikan pesan kesalahan, atau null jika data valid.
  String? validate() {
    if (w1 <= 0) return 'W1 harus bernilai positif';
    if (w2 <= w1) return 'W2 harus lebih besar dari W1';
    if (w3 <= w1) return 'W3 harus lebih besar dari W1';
    if (w4 <= 0) return 'W4 harus bernilai positif';
    if (w5 <= 0) return 'W5 harus bernilai positif';
    if (w4 <= w5) return 'W4 harus lebih besar dari W5';
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'w1': w1,
      'w2': w2,
      'w3': w3,
      'w4': w4,
      'w5': w5,
      'tanggalKalibrasi': tanggalKalibrasi?.toIso8601String(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory CalibrationVersion.fromJson(Map<String, dynamic> json) {
    return CalibrationVersion(
      w1: _toDoubleValue(json['w1']),
      w2: _toDoubleValue(json['w2']),
      w3: _toDoubleValue(json['w3']),
      w4: _toDoubleValue(json['w4']),
      w5: _toDoubleValue(json['w5']),
      tanggalKalibrasi: _toDateValue(json['tanggalKalibrasi']),
      savedAt: _toDateValue(json['savedAt']) ?? DateTime.now(),
    );
  }
}

/// Satu baris pratinjau impor untuk satu alat.
class CalibrationImportItem {
  final String deviceId;
  final String deviceName;
  final CalibrationVersion current;
  final CalibrationVersion incoming;
  final List<CalibrationVersion> incomingHistory;

  CalibrationImportItem({
    required this.deviceId,
    required this.deviceName,
    required this.current,
    required this.incoming,
    required this.incomingHistory,
  });

  bool get isSame => current.key == incoming.key;

  bool get isOlder {
    final a = incoming.tanggalKalibrasi;
    final b = current.tanggalKalibrasi;
    if (a == null || b == null) return false;
    return a.isBefore(b);
  }
}

class CalibrationImportPreview {
  final List<CalibrationImportItem> items;

  CalibrationImportPreview(this.items);

  bool get hasChanges => items.any((i) => !i.isSame);
  bool get hasOlder => items.any((i) => !i.isSame && i.isOlder);
}

class CalibrationTemplateService {
  static const String _prefsKey = 'sandcone_calibration_store_v1';
  static const String _exportFormat = 'sipilab-kalibrasi-sandcone';
  static const int maxVersionsPerDevice = 10;

  static const List<String> deviceIds = [
    'alat_uji_1',
    'alat_uji_2',
    'alat_uji_3',
  ];

  static const Map<String, String> _deviceNames = {
    'alat_uji_1': 'Alat Uji 1',
    'alat_uji_2': 'Alat Uji 2',
    'alat_uji_3': 'Alat Uji 3',
  };

  static const Map<String, String> _deviceDescriptions = {
    'alat_uji_1': 'Sand Cone Set #001',
    'alat_uji_2': 'Sand Cone Set #002',
    'alat_uji_3': 'Sand Cone Set #003',
  };

  static String deviceName(String id) => _deviceNames[id] ?? id;

  static String deviceDescription(String id) => _deviceDescriptions[id] ?? '';

  /// Nilai bawaan (data kalibrasi 16 Nov 2026, rata-rata Uji 1 dan Uji 2).
  /// Dipakai bila belum ada data tersimpan di perangkat.
  static Map<String, CalibrationVersion> defaultVersions() {
    final tgl = DateTime(2026, 11, 16);
    return {
      'alat_uji_1': CalibrationVersion(
        w1: 652.00,
        w2: 5669.50,
        w3: 8040.50,
        w4: 8040.50,
        w5: 6408.00,
        tanggalKalibrasi: tgl,
        savedAt: tgl,
      ),
      'alat_uji_2': CalibrationVersion(
        w1: 727.10,
        w2: 5620.00,
        w3: 8008.00,
        w4: 8008.00,
        w5: 6548.50,
        tanggalKalibrasi: tgl,
        savedAt: tgl,
      ),
      'alat_uji_3': CalibrationVersion(
        w1: 645.50,
        w2: 5672.00,
        w3: 7952.50,
        w4: 7952.50,
        w5: 6532.50,
        tanggalKalibrasi: tgl,
        savedAt: tgl,
      ),
    };
  }

  static CalibrationTemplate _templateFrom(String id, CalibrationVersion v) {
    return CalibrationTemplate(
      id: id,
      name: _deviceNames[id] ?? id,
      description: _deviceDescriptions[id] ?? '',
      w1: v.w1,
      w2: v.w2,
      w3: v.w3,
      w4: v.w4,
      w5: v.w5,
      lastCalibrationDate: v.tanggalKalibrasi,
      labName: null,
    );
  }

  static CalibrationTemplate _customTemplate() {
    return CalibrationTemplate(
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
    );
  }

  /// Template bawaan (sinkron, tanpa membaca data tersimpan).
  static List<CalibrationTemplate> getDefaultTemplates() {
    final defaults = defaultVersions();
    return [
      for (final id in deviceIds) _templateFrom(id, defaults[id]!),
      _customTemplate(),
    ];
  }

  // ---------------------------------------------------------------------------
  // Penyimpanan di perangkat
  // ---------------------------------------------------------------------------

  /// Membaca seluruh data: per alat, daftar versi (terbaru di indeks 0).
  static Future<Map<String, List<CalibrationVersion>>> loadStore() async {
    final defaults = defaultVersions();
    final store = <String, List<CalibrationVersion>>{
      for (final id in deviceIds) id: [defaults[id]!],
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final id in deviceIds) {
            final list = decoded[id];
            if (list is List && list.isNotEmpty) {
              final versions = <CalibrationVersion>[];
              for (final item in list) {
                if (item is Map) {
                  final v = CalibrationVersion.fromJson(
                      Map<String, dynamic>.from(item));
                  if (v.validate() == null) versions.add(v);
                }
              }
              if (versions.isNotEmpty) store[id] = versions;
            }
          }
        }
      }
    } catch (_) {
      // Data rusak: pakai nilai bawaan.
    }
    return store;
  }

  static Future<void> _saveStore(
      Map<String, List<CalibrationVersion>> store) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      for (final e in store.entries)
        e.key: e.value.map((v) => v.toJson()).toList(),
    };
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  static List<CalibrationVersion> _trim(List<CalibrationVersion> list) {
    if (list.length <= maxVersionsPerDevice) return list;
    return list.sublist(0, maxVersionsPerDevice);
  }

  /// Template aktif untuk dipilih di layar Sand Cone (3 alat + Kustom).
  static Future<List<CalibrationTemplate>> loadTemplates() async {
    final store = await loadStore();
    return [
      for (final id in deviceIds) _templateFrom(id, store[id]!.first),
      _customTemplate(),
    ];
  }

  static Future<CalibrationTemplate?> getTemplateByIdAsync(String id) async {
    final all = await loadTemplates();
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  static Future<List<CalibrationVersion>> getHistory(String id) async {
    final store = await loadStore();
    return store[id] ?? [];
  }

  /// Menyimpan versi kalibrasi baru sebagai versi aktif.
  /// Versi aktif sebelumnya tetap ada di riwayat.
  /// Mengembalikan pesan kesalahan, atau null bila berhasil.
  static Future<String?> saveCalibration(
      String id, CalibrationVersion version) async {
    if (!deviceIds.contains(id)) return 'Alat tidak dikenal';
    final error = version.validate();
    if (error != null) return error;

    final store = await loadStore();
    final list = List<CalibrationVersion>.from(store[id]!);
    if (list.first.key == version.key) return null; // tidak ada perubahan

    list.removeWhere((v) => v.key == version.key);
    list.insert(0, version);
    store[id] = _trim(list);
    await _saveStore(store);
    return null;
  }

  /// Menjadikan salah satu versi riwayat sebagai versi aktif.
  static Future<String?> restoreVersion(String id, CalibrationVersion version) {
    return saveCalibration(
      id,
      CalibrationVersion(
        w1: version.w1,
        w2: version.w2,
        w3: version.w3,
        w4: version.w4,
        w5: version.w5,
        tanggalKalibrasi: version.tanggalKalibrasi,
        savedAt: DateTime.now(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Ekspor / impor
  // ---------------------------------------------------------------------------

  static Future<String> exportToJson() async {
    final store = await loadStore();
    final data = <String, dynamic>{
      'format': _exportFormat,
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'devices': {
        for (final e in store.entries)
          e.key: e.value.map((v) => v.toJson()).toList(),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Membaca isi berkas impor dan menyusun pratinjau perubahan.
  /// Melempar FormatException bila berkas tidak sesuai.
  static Future<CalibrationImportPreview> parseImport(String content) async {
    dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } catch (_) {
      throw const FormatException('Berkas bukan JSON yang valid');
    }

    if (decoded is! Map || decoded['format'] != _exportFormat) {
      throw const FormatException(
          'Berkas ini bukan berkas kalibrasi Sand Cone SipiLAB');
    }
    final devices = decoded['devices'];
    if (devices is! Map) {
      throw const FormatException('Data alat pada berkas tidak ditemukan');
    }

    final store = await loadStore();
    final items = <CalibrationImportItem>[];

    for (final id in deviceIds) {
      final list = devices[id];
      if (list is! List || list.isEmpty) continue;

      final versions = <CalibrationVersion>[];
      for (final item in list) {
        if (item is Map) {
          try {
            final v =
                CalibrationVersion.fromJson(Map<String, dynamic>.from(item));
            if (v.validate() == null) versions.add(v);
          } catch (_) {}
        }
      }
      if (versions.isEmpty) continue;

      items.add(CalibrationImportItem(
        deviceId: id,
        deviceName: _deviceNames[id] ?? id,
        current: store[id]!.first,
        incoming: versions.first,
        incomingHistory: versions.sublist(1),
      ));
    }

    if (items.isEmpty) {
      throw const FormatException(
          'Tidak ada data kalibrasi yang valid pada berkas');
    }
    return CalibrationImportPreview(items);
  }

  /// Menerapkan hasil impor. Nilai yang aktif sebelumnya dipindah ke riwayat.
  /// Mengembalikan jumlah alat yang diperbarui.
  static Future<int> applyImport(CalibrationImportPreview preview) async {
    final store = await loadStore();
    var changed = 0;

    for (final item in preview.items) {
      if (item.isSame) continue;

      final merged = <CalibrationVersion>[item.incoming];
      final others = <CalibrationVersion>[
        ...store[item.deviceId]!,
        ...item.incomingHistory,
      ];
      for (final v in others) {
        if (!merged.any((m) => m.key == v.key)) merged.add(v);
      }
      store[item.deviceId] = _trim(merged);
      changed++;
    }

    if (changed > 0) await _saveStore(store);
    return changed;
  }

  // ---------------------------------------------------------------------------
  // Utilitas
  // ---------------------------------------------------------------------------

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
${template.lastCalibrationDate != null ? 'Kalibrasi: ${formatTanggalKalibrasi(template.lastCalibrationDate!)}' : ''}

Volume Botol (Vb): ${vb.toStringAsFixed(2)} ml
Berat Isi Pasir (Yp): ${yp.toStringAsFixed(4)} gr/ml
Berat Pasir dalam Corong (W6): ${w6.toStringAsFixed(2)} gram
''';
  }
}
