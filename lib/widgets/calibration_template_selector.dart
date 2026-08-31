import 'package:flutter/material.dart';
import '../models/sand_cone_calibration_templates.dart';

class CalibrationTemplateSelector extends StatefulWidget {
  final Function(CalibrationTemplate) onTemplateSelected;
  final CalibrationTemplate? initialTemplate;

  const CalibrationTemplateSelector({
    Key? key,
    required this.onTemplateSelected,
    this.initialTemplate,
  }) : super(key: key);

  @override
  State<CalibrationTemplateSelector> createState() =>
      _CalibrationTemplateSelectorState();
}

class _CalibrationTemplateSelectorState
    extends State<CalibrationTemplateSelector> {
  late CalibrationTemplate selectedTemplate;
  final List<CalibrationTemplate> templates =
      CalibrationTemplateService.getDefaultTemplates();

  @override
  void initState() {
    super.initState();
    selectedTemplate = widget.initialTemplate ??
        templates.firstWhere((t) => t.id == 'alat_uji_1');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
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
                child: const Icon(Icons.library_books_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PILIH TEMPLATE KALIBRASI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Data kalibrasi alat dari laboratorium',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

         
          ...templates.map((template) => _buildTemplateCard(template)),

          const SizedBox(height: 12),

        
          if (selectedTemplate.isValid) _buildSelectedTemplateInfo(),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(CalibrationTemplate template) {
    final isSelected = selectedTemplate.id == template.id;
    final isCustom = template.id == 'custom';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTemplate = template;
        });
        widget.onTemplateSelected(template);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCustom
                  ? const Color(0xFFFBBF24).withOpacity(0.1)
                  : const Color(0xFF8B5CF6).withOpacity(0.1))
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isCustom ? const Color(0xFFFBBF24) : const Color(0xFF8B5CF6))
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
           
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isCustom
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF8B5CF6))
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCustom ? Icons.edit_rounded : Icons.science_rounded,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (!isCustom && template.lastCalibrationDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 11, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Kalibrasi: ${_formatDate(template.lastCalibrationDate!)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

           
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCustom
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTemplateInfo() {
    if (selectedTemplate.id == 'custom') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFBBF24),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.info_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Mode Kustom: Isi nilai W1-W5 secara manual sesuai data kalibrasi alat Anda',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF78350F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9D5FF), Color(0xFFF3E8FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.science_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Data Kalibrasi Terpilih',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B21A8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Volume Botol (Vb)',
              '${selectedTemplate.volumeBotol.toStringAsFixed(2)} ml'),
          const SizedBox(height: 6),
          _buildInfoRow('Berat Isi Pasir (Yp)',
              '${selectedTemplate.beratIsiPasir.toStringAsFixed(4)} gr/ml'),
          const SizedBox(height: 6),
          _buildInfoRow('Berat Pasir dalam Corong (W6)',
              '${selectedTemplate.beratPasirDalamCorong.toStringAsFixed(2)} gram'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B21A8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B21A8),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}