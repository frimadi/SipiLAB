import 'package:flutter/material.dart';

class SandDataInputSection extends StatelessWidget {
  final TextEditingController w8Controller;
  final TextEditingController w9Controller;
  final TextEditingController w6Controller;
  final TextEditingController w7Controller;
  final TextEditingController kadarAirController;
  final TextEditingController beratIsiTanahKeringLabController;
  final double beratTanah;
  final double beratPasirDalamLubang;
  final double vLubang;
  final double beratIsiTanah;
  final double beratIsiTanahKeringLapangan;
  final double persentaseKepadatan;

  const SandDataInputSection({
    Key? key,
    required this.w8Controller,
    required this.w9Controller,
    required this.w6Controller,
    required this.w7Controller,
    required this.kadarAirController,
    required this.beratIsiTanahKeringLabController,
    required this.beratTanah,
    required this.beratPasirDalamLubang,
    required this.vLubang,
    required this.beratIsiTanah,
    required this.beratIsiTanahKeringLapangan,
    required this.persentaseKepadatan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.terrain_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'III. PEMERIKSAAN LAPANGAN',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'KEPADATAN TANAH',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            
            _buildInputField(
              controller: w8Controller,
              label: 'Berat Tanah + Wadah',
              symbol: 'W8',
              unit: 'gram',
              icon: Icons.scale_rounded,
            ),

            _buildInputField(
              controller: w9Controller,
              label: 'Berat Wadah',
              symbol: 'W9',
              unit: 'gram',
              icon: Icons.inbox_rounded,
            ),

            _buildResultField(
              label: 'Berat Tanah',
              formula: 'W8-W9',
              value: beratTanah,
              unit: 'gram',
              icon: Icons.analytics_outlined,
            ),

            const SizedBox(height: 10),

            _buildInputField(
              controller: w6Controller,
              label: 'Berat + Botol + Corong + Pasir',
              symbol: 'W6',
              unit: 'gram',
              icon: Icons.science_rounded,
            ),

            _buildInputField(
              controller: w7Controller,
              label: 'Berat + Botol + Corong + Sisa Pasir',
              symbol: 'W7',
              unit: 'gram',
              icon: Icons.science_outlined,
            ),

            _buildResultField(
              label: 'Berat Pasir Dalam Lubang',
              formula: 'W10=(W6-W7)-(W4-W5)',
              value: beratPasirDalamLubang,
              unit: 'gram',
              icon: Icons.grass_rounded,
            ),

            _buildResultField(
              label: 'Isi Lubang',
              formula: 'Ve=W10/yρ',
              value: vLubang,
              unit: 'ml',
              icon: Icons.water_drop_outlined,
            ),

            _buildResultField(
              label: 'Berat Isi Tanah',
              formula: 'ys=(W8-W9)/Ve',
              value: beratIsiTanah,
              unit: 'gram/ml',
              icon: Icons.compress_rounded,
              isImportant: true,
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),

           
            _buildInputField(
              controller: kadarAirController,
              label: 'Kadar Air (dalam desimal)',
              symbol: 'Wc',
              unit: 'desimal',
              icon: Icons.water_rounded,
              hint: 'Contoh: 0.05 untuk 5%',
            ),

            
            _buildResultField(
              label: 'Berat Isi Tanah Kering',
              formula: 'yd Lap=ys/(1+Wc)',
              value: beratIsiTanahKeringLapangan,
              unit: 'gram/ml',
              icon: Icons.compress,
              isImportant: true,
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),

           
            _buildPersentaseKepadatanCard(),

            const SizedBox(height: 10),

            
            _buildStatusIndicator(persentaseKepadatan),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String symbol,
    required String unit,
    required IconData icon,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: const Color(0xFFD97706)),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF78350F),
                    ),
                    decoration: InputDecoration(
                      hintText: hint ?? 'Masukkan nilai',
                      hintStyle: TextStyle(
                        color: Colors.brown[300],
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultField({
    required String label,
    required String formula,
    required double value,
    required String unit,
    required IconData icon,
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isImportant
                      ? const Color(0xFF10B981).withOpacity(0.2)
                      : const Color(0xFF64748B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: isImportant ? const Color(0xFF059669) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isImportant ? FontWeight.bold : FontWeight.w600,
                    color: isImportant ? const Color(0xFF1E293B) : const Color(0xFF475569),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formula,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isImportant
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isImportant
                          ? const Color(0xFF10B981)
                          : const Color(0xFFCBD5E1),
                      width: isImportant ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    value.toStringAsFixed(4),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isImportant ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersentaseKepadatanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPercentageColor(persentaseKepadatan).withOpacity(0.1),
            _getPercentageColor(persentaseKepadatan).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPercentageColor(persentaseKepadatan),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERSENTASE KEPADATAN',
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.bold,
                        color: _getPercentageColor(persentaseKepadatan),
                      ),
                    ),
                    const SizedBox(height: 3), 
                    const Text(
                      'yd Lap/yd Lab × 100',
                      style: TextStyle(
                        fontSize: 11, 
                        color: Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
                decoration: BoxDecoration(
                  color: _getPercentageColor(persentaseKepadatan),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getPercentageColor(persentaseKepadatan).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      persentaseKepadatan.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 26, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '%',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(double percentage) {
    String status;
    Color statusColor;
    IconData icon;

    if (percentage >= 95) {
      status = 'MEMENUHI SYARAT (≥ 95%)';
      statusColor = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
    } else if (percentage >= 90) {
      status = 'PERLU PERHATIAN (90-95%)';
      statusColor = const Color(0xFFF59E0B);
      icon = Icons.warning_rounded;
    } else {
      status = 'TIDAK MEMENUHI SYARAT (< 90%)';
      statusColor = const Color(0xFFEF4444);
      icon = Icons.error_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 22),
          const SizedBox(width: 10), 
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 95) {
      return const Color(0xFF10B981);
    } else if (percentage >= 90) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }
}