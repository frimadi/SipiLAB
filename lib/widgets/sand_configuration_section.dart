import 'package:flutter/material.dart';

class SandConfigurationSection extends StatelessWidget {
  final TextEditingController w1Controller;
  final TextEditingController w2Controller;
  final TextEditingController w3Controller;
  final TextEditingController w4Controller;
  final TextEditingController w5Controller;
  final TextEditingController vkController;
  final TextEditingController w11Controller;
  final TextEditingController w12Controller;
  final double volumeBotolCorong;
  final double beratIsiPasir;
  final double beratPasirDalamCorong;
  final double beratPasirDalamTakaran;
  final double beratIsiPasirTakaran;

  const SandConfigurationSection({
    Key? key,
    required this.w1Controller,
    required this.w2Controller,
    required this.w3Controller,
    required this.w4Controller,
    required this.w5Controller,
    required this.vkController,
    required this.w11Controller,
    required this.w12Controller,
    required this.volumeBotolCorong,
    required this.beratIsiPasir,
    required this.beratPasirDalamCorong,
    required this.beratPasirDalamTakaran,
    required this.beratIsiPasirTakaran,
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
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.science_rounded, color: Colors.white, size: 20), 
                ),
                const SizedBox(width: 10), 
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I. KALIBRASI PASIR LABORATORIUM',
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'BERAT ISI PASIR DENGAN BOTOL ALAT',
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
              controller: w1Controller,
              label: 'Berat Botol + Corong',
              symbol: 'W1',
              unit: 'gram',
              icon: Icons.view_in_ar_rounded,
            ),

            _buildInputField(
              controller: w2Controller,
              label: 'Berat Botol + Corong + Air',
              symbol: 'W2',
              unit: 'gram',
              icon: Icons.water_drop_rounded,
            ),

            _buildResultField(
              label: 'Volume Botol + Corong',
              formula: 'W2-W1',
              value: volumeBotolCorong,
              unit: 'ml',
              icon: Icons.straighten_rounded,
            ),

            _buildInputField(
              controller: w3Controller,
              label: 'Berat Botol + Corong + Pasir',
              symbol: 'W3',
              unit: 'gram',
              icon: Icons.grass_rounded,
            ),

            _buildResultField(
              label: 'Berat Isi Pasir',
              formula: 'yρ lab= (W3-W1)/(W2-W1)',
              value: beratIsiPasir,
              unit: 'gram/ml',
              icon: Icons.calculate_rounded,
              isImportant: true,
            ),

            const SizedBox(height: 20), 
            const Divider(height: 1, thickness: 2, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 20),

            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_alt_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'II. BERAT ISI PASIR DENGAN TAKARAN',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14), 

            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'A. BERAT PASIR DALAM CORONG',
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
            const SizedBox(height: 10), 

            _buildInputField(
              controller: w4Controller,
              label: 'Berat Botol + Corong + Pasir',
              symbol: 'W4',
              unit: 'gram',
              icon: Icons.inventory_2_rounded,
            ),

            _buildInputField(
              controller: w5Controller,
              label: 'Berat Botol + Corong + Sisa Pasir',
              symbol: 'W5',
              unit: 'gram',
              icon: Icons.inventory_2_outlined,
            ),

            _buildResultField(
              label: 'Berat Pasir Dalam Corong',
              formula: 'W4-W5',
              value: beratPasirDalamCorong,
              unit: 'gram',
              icon: Icons.analytics_outlined,
            ),

            const SizedBox(height: 14),

            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'B. BERAT PASIR DALAM TAKARAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildInputField(
              controller: vkController,
              label: 'Isi Takaran',
              symbol: 'VK',
              unit: 'ml',
              icon: Icons.check_box_outlined,
            ),

            _buildInputField(
              controller: w11Controller,
              label: 'Berat Botol + Corong + Pasir',
              symbol: 'W11',
              unit: 'gram',
              icon: Icons.inventory_rounded,
            ),

            _buildInputField(
              controller: w12Controller,
              label: 'Berat Botol + Corong + Sisa Pasir',
              symbol: 'W12',
              unit: 'gram',
              icon: Icons.inventory_outlined,
            ),

            _buildResultField(
              label: 'Berat Pasir Dalam Takaran',
              formula: 'W13=W11-W12-(W4-W5)',
              value: beratPasirDalamTakaran,
              unit: 'gram',
              icon: Icons.analytics_outlined,
            ),

            _buildResultField(
              label: 'Berat Isi Pasir',
              formula: 'yρ = W13/VK',
              value: beratIsiPasirTakaran,
              unit: 'gram/ml',
              icon: Icons.calculate_rounded,
              isImportant: true,
            ),
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
}