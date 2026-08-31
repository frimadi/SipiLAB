import 'package:flutter/material.dart';
import '../services/konversi_service.dart';

class KonversiConfigurationSection extends StatelessWidget {
  const KonversiConfigurationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabelData = KonversiService.getTabelReferensi();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tabel Referensi PBI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      Text(
                        'Umur 3 - 365 Hari',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                 
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Umur Beton\n(Hari)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Faktor Konversi\nK = ...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Karakteristik',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                 
                  ...tabelData.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, dynamic> data = entry.value;
                    bool isEven = idx % 2 == 0;
                    bool isHighlight = data['umur'] == 28 || data['umur'] == 90 || data['umur'] == 365;
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isHighlight 
                            ? Colors.blue[50] 
                            : (isEven ? Colors.grey[50] : Colors.white),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${data['umur']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                                color: isHighlight ? Colors.blue[900] : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              data['faktor'].toStringAsFixed(data['umur'] <= 28 ? 2 : 3),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isHighlight ? Colors.blue[900] : Colors.blue[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              data['karakteristik'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
                                color: isHighlight ? Colors.blue[800] : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rumus: Kuat Tekan 28 Hari = Kuat Tekan Uji ÷ Faktor Konversi',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: Colors.amber[800], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Data lengkap tersedia untuk umur 3-365 hari dengan interpolasi otomatis',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber[800],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}