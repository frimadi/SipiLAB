import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsCard({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  'Statistik Pengujian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            _buildStatRow(
              'Total Pengujian',
              '${statistics['total']} kali',
              Icons.science,
            ),
            _buildStatRow(
              'Rata-rata Kuat Tekan',
              '${statistics['avgKuatTekan'].toStringAsFixed(2)} MPa',
              Icons.analytics,
            ),
            _buildStatRow(
              'Kuat Tekan Maksimum',
              '${statistics['maxKuatTekan'].toStringAsFixed(2)} MPa',
              Icons.arrow_upward,
              color: Colors.green,
            ),
            _buildStatRow(
              'Kuat Tekan Minimum',
              '${statistics['minKuatTekan'].toStringAsFixed(2)} MPa',
              Icons.arrow_downward,
              color: Colors.red,
            ),
            
            const Divider(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: _buildSuccessRate(
                    'Memenuhi Syarat',
                    statistics['memenuhiSyarat'],
                    statistics['total'],
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSuccessRate(
                    'Tidak Memenuhi',
                    statistics['tidakMemenuhiSyarat'],
                    statistics['total'],
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRate(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}