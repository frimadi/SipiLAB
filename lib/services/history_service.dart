import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/uji_kuat_result.dart';

class HistoryItem {
  final String id;
  final DateTime tanggal;
  final UjiKuatResult result;
  final UjiKuatData data;
  final String standarAcuan;

  HistoryItem({
    required this.id,
    required this.tanggal,
    required this.result,
    required this.data,
    required this.standarAcuan,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'standarAcuan': standarAcuan,
      'data': {
        'sisiKubus': data.sisiKubus,
        'panjangKubus': data.panjangKubus,
        'lebarKubus': data.lebarKubus,
        'tinggiKubus': data.tinggiKubus,
        'diameter': data.diameter,
        'beban': data.beban,
        'satuanBeban': data.satuanBeban,
        'tanggalPembuatan': data.tanggalPembuatan.toIso8601String(),
        'tanggalPengujian': data.tanggalPengujian.toIso8601String(),
        'mutuBeton': data.mutuBeton,
        'beratBendaUji': data.beratBendaUji,
        'pekerjaan': data.pekerjaan,
        'lokasi': data.lokasi,
        'photoPaths': data.photoPaths,
      },
      'result': result.toMap(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    final resultJson = json['result'];

    return HistoryItem(
      id: json['id'],
      tanggal: DateTime.parse(json['tanggal']),
      standarAcuan: json['standarAcuan'],
      data: UjiKuatData(
        sisiKubus: dataJson['sisiKubus']?.toDouble(),
        panjangKubus: dataJson['panjangKubus']?.toDouble(),
        lebarKubus: dataJson['lebarKubus']?.toDouble(),
        tinggiKubus: dataJson['tinggiKubus']?.toDouble(),
        diameter: dataJson['diameter']?.toDouble(),
        beban: dataJson['beban'].toDouble(),
        satuanBeban: dataJson['satuanBeban'] ?? 'kN',
        tanggalPembuatan: DateTime.parse(dataJson['tanggalPembuatan']),
        tanggalPengujian: DateTime.parse(dataJson['tanggalPengujian']),
        mutuBeton: dataJson['mutuBeton'],
        beratBendaUji: dataJson['beratBendaUji']?.toDouble(),
        pekerjaan: dataJson['pekerjaan'],
        lokasi: dataJson['lokasi'],
        photoPaths: dataJson['photoPaths'] != null 
            ? List<String>.from(dataJson['photoPaths']) 
            : null,
      ),
      result: UjiKuatResult.fromMap(resultJson),
    );
  }
}

class HistoryService {
  static const String _historyKey = 'uji_kuat_history';
  static const int _maxHistoryItems = 100;

  
  Future<void> saveToHistory({
    required UjiKuatResult result,
    required UjiKuatData data,
    required String standarAcuan,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      
      final newItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tanggal: DateTime.now(),
        result: result,
        data: data,
        standarAcuan: standarAcuan,
      );

      
      history.insert(0, newItem);

      
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      
      final jsonList = history.map((item) => item.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Gagal menyimpan riwayat: $e');
    }
  }

  
  Future<List<HistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => HistoryItem.fromJson(json)).toList();
    } catch (e) {
      
      return [];
    }
  }

  
  Future<void> deleteHistoryItem(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      history.removeWhere((item) => item.id == id);

      final jsonList = history.map((item) => item.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Gagal menghapus riwayat: $e');
    }
  }

  
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      throw Exception('Gagal menghapus semua riwayat: $e');
    }
  }

  
  Future<List<HistoryItem>> searchByDate(DateTime startDate, DateTime endDate) async {
    final history = await getHistory();
    return history.where((item) {
      return item.tanggal.isAfter(startDate) && 
             item.tanggal.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  
  Future<List<HistoryItem>> searchByStatus(String status) async {
    final history = await getHistory();
    return history.where((item) => item.result.statusKualitas == status).toList();
  }

  
  Future<String> exportHistoryAsJson() async {
    final history = await getHistory();
    final jsonList = history.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  
  Future<void> importHistoryFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      jsonList.map((json) => HistoryItem.fromJson(json)).toList();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      throw Exception('Gagal import riwayat: $e');
    }
  }
}