import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HammerConfigurationSection extends StatelessWidget {
  final String selectedStandard;
  final String selectedHammerType;
  final String selectedPosition;
  final int concreteAge;
  final String testedBy; 
  final String location;
  final double calibrationFactor;
  final Function(String) onStandardChanged;
  final Function(String) onHammerTypeChanged;
  final Function(String) onPositionChanged;
  final Function(int) onAgeChanged;
  final Function(String) onTestedByChanged; 
  final Function(String) onLocationChanged;
  final Function(double) onCalibrationChanged;

  const HammerConfigurationSection({
    super.key,
    required this.selectedStandard,
    required this.selectedHammerType,
    required this.selectedPosition,
    required this.concreteAge,
    required this.testedBy, 
    required this.location,
    required this.calibrationFactor,
    required this.onStandardChanged,
    required this.onHammerTypeChanged,
    required this.onPositionChanged,
    required this.onAgeChanged,
    required this.onTestedByChanged, 
    required this.onLocationChanged,
    required this.onCalibrationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final calibrationController = TextEditingController(
      text: calibrationFactor.toStringAsFixed(8),
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue[700], size: 22),
                const SizedBox(width: 8),
                Text(
                  'Konfigurasi Test',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

           
            TextFormField(
              initialValue: testedBy,
              decoration: InputDecoration(
                labelText: 'Nama Pekerja',
                labelStyle: const TextStyle(fontSize: 13),
                hintText: ' ',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.person, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14),
              textCapitalization: TextCapitalization.words,
              onChanged: onTestedByChanged,
            ),
            const SizedBox(height: 12),

           
            TextFormField(
              initialValue: location,
              decoration: InputDecoration(
                labelText: 'Lokasi Test',
                labelStyle: const TextStyle(fontSize: 13),
                hintText: ' ',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.location_on, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: onLocationChanged,
            ),
            const SizedBox(height: 12),

           
            DropdownButtonFormField<String>(
              value: selectedStandard,
              decoration: InputDecoration(
                labelText: 'Standar',
                labelStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.book, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black),
              items: const [
                DropdownMenuItem(
                  value: 'SNI',
                  child:
                      Text('SNI 03-4430-1997', style: TextStyle(fontSize: 14)),
                ),
                DropdownMenuItem(
                  value: 'ASTM',
                  child: Text('ASTM C805', style: TextStyle(fontSize: 14)),
                ),
              ],
              onChanged: (value) {
                if (value != null) onStandardChanged(value);
              },
            ),
            const SizedBox(height: 12),

           
            DropdownButtonFormField<String>(
              value: selectedHammerType,
              decoration: InputDecoration(
                labelText: 'Tipe Hammer',
                labelStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.build, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black),
              items: const [
                DropdownMenuItem(
                  value: 'N-Type',
                  child: Text('N-Type (Standar)', style: TextStyle(fontSize: 14)),
                ),
              ],
              onChanged: (value) {
                if (value != null) onHammerTypeChanged(value);
              },
            ),
            const SizedBox(height: 12),

            
            DropdownButtonFormField<String>(
              value: selectedPosition,
              decoration: InputDecoration(
                labelText: 'Posisi Pengujian',
                labelStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.place, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Pilih sesuai lokasi pada struktur beton',
                helperStyle: const TextStyle(fontSize: 11),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: Colors.black),
              items: const [
                DropdownMenuItem(
                  value: 'A',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_forward, size: 16, color: Colors.red),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Posisi A: Horizontal (Dinding) 0°', 
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'B',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, size: 16, color: Colors.orange),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Posisi B: Vertikal ↓ (Plat Bawah) +90°', 
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'C',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 16, color: Colors.blue),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Posisi C: Vertikal ↑ (Lantai Atas) -90°', 
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) onPositionChanged(value);
              },
            ),
            const SizedBox(height: 12),

            
            TextFormField(
              initialValue: concreteAge.toString(),
              decoration: InputDecoration(
                labelText: 'Umur Beton (hari)',
                labelStyle: const TextStyle(fontSize: 13),
                hintText: 'Minimal 3 hari',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.calendar_today, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Minimal 3 hari untuk hammer test',
                helperStyle: const TextStyle(fontSize: 11),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final age = int.tryParse(value) ?? 28;
                onAgeChanged(age);
              },
            ),

            const SizedBox(height: 16),

            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple[300]!, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: Colors.deepPurple[700], size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'KALIBRASI ALAT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Faktor Kalibrasi',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              calibrationFactor.toStringAsFixed(8),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[700],
                              ),
                            ),
                          ],
                        ),
                        if (calibrationFactor != 1.0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Persentase',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${((calibrationFactor - 1) * 100).toStringAsFixed(4)}%',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  
                  Text(
                    'Preset Kalibrasi:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildCalibrationPreset(
                        context,
                        'Tanpa Kalibrasi (1.0)',
                        1.0,
                        onCalibrationChanged,
                        calibrationFactor == 1.0,
                      ),
                      _buildCalibrationPreset(
                        context,
                        'Custom',
                        0.0,
                        (value) => _showCustomCalibrationDialog(
                          context,
                          calibrationController,
                          onCalibrationChanged,
                        ),
                        false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: calibrationController,
                          decoration: InputDecoration(
                            labelText: 'Faktor Kalibrasi Manual',
                            labelStyle: const TextStyle(fontSize: 12),
                            hintText: '',
                            prefixIcon: const Icon(Icons.calculate, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,8}'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          final value = double.tryParse(
                            calibrationController.text,
                          );
                          if (value != null && value > 0 && value <= 2.0) {
                            onCalibrationChanged(value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Kalibrasi diubah: ${value.toStringAsFixed(8)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Nilai tidak valid (0 < x ≤ 2.0)'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Terapkan',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.green[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                 
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.amber[800], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Faktor kalibrasi dari sertifikat alat. Default: 1.0 (tanpa kalibrasi)',
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: 10,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            
           
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[700], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Catatan Penting',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Pastikan permukaan beton bersih, kering, dan halus\n'
                    '• Posisi A, B, C menggunakan rumus korelasi berbeda\n'
                    '• Pilih posisi sesuai lokasi pada struktur beton\n'
                    '• Lakukan minimal 10-12 pembacaan per titik test\n'
                    '• Pukulan dilakukan tegak lurus permukaan (horizontal)',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationPreset(
    BuildContext context,
    String label,
    double value,
    Function(double) onChange,
    bool isActive,
  ) {
    return ElevatedButton(
      onPressed: value > 0 ? () => onChange(value) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.deepPurple[600] : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        elevation: isActive ? 4 : 1,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showCustomCalibrationDialog(
    BuildContext context,
    TextEditingController controller,
    Function(double) onChange,
  ) {
    final customController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, color: Colors.deepPurple),
            ),
            const SizedBox(width: 12),
            const Text('Kalibrasi Custom'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan faktor kalibrasi berdasarkan sertifikat alat:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: customController,
              decoration: InputDecoration(
                labelText: 'Faktor Kalibrasi',
                hintText: 'Contoh: 1.00125156',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Formula: Nilai Standar / Nilai Alat',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')),
              ],
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contoh Perhitungan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Jika nilai standar = 80\n'
                    'Nilai alat rata-rata = 79.9\n'
                    'Faktor = 80 / 79.9 = 1.00125156',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(customController.text);
              if (value != null && value > 0 && value <= 2.0) {
                controller.text = value.toStringAsFixed(8);
                onChange(value);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kalibrasi custom diterapkan: ${value.toStringAsFixed(8)}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nilai tidak valid! (0 < x ≤ 2.0)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[600],
            ),
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
}