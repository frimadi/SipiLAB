import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class UjiInputKubusSection extends StatelessWidget {
  final TextEditingController sisiKubusController;
  final TextEditingController bebanController;
  final TextEditingController beratBendaUjiController;
  final DateTime tanggalPembuatan;
  final DateTime tanggalPengujian;
  final Function(DateTime) onTanggalPembuatanChanged;
  final Function(DateTime) onTanggalPengujianChanged;

  const UjiInputKubusSection({
    Key? key,
    required this.sisiKubusController,
    required this.bebanController,
    required this.beratBendaUjiController,
    required this.tanggalPembuatan,
    required this.tanggalPengujian,
    required this.onTanggalPembuatanChanged,
    required this.onTanggalPengujianChanged,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context, bool isPembuatan) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPembuatan ? tanggalPembuatan : tanggalPengujian,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      if (isPembuatan) {
        onTanggalPembuatanChanged(picked);
      } else {
        onTanggalPengujianChanged(picked);
      }
    }
  }

  int _hitungUmurBeton() {
    return tanggalPengujian.difference(tanggalPembuatan).inDays;
  }

  @override
  Widget build(BuildContext context) {
   
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
    final int umurBeton = _hitungUmurBeton();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        InkWell(
          onTap: () => _selectDate(context, true),
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tanggal Pembuatan Sampel (Casting)',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Tanggal saat beton dicetak/dicor',
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(tanggalPembuatan),
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

       
        InkWell(
          onTap: () => _selectDate(context, false),
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tanggal Pengujian Sampel (Testing)',
              prefixIcon: const Icon(Icons.science),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Tanggal saat pengujian dilakukan',
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(tanggalPengujian),
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Umur Beton: $umurBeton hari (otomatis dihitung)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

       
        TextFormField(
          controller: sisiKubusController,
          decoration: InputDecoration(
            labelText: 'Sisi Kubus (mm)',
            hintText: ' ',
            prefixIcon: const Icon(Icons.view_in_ar),
            suffixText: 'mm',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Standar SNI: 150×150×150 mm (15×15×15 cm)',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        
        const SizedBox(height: 16),

        
        Container(
          padding: const EdgeInsets.all(12),
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
                  Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Informasi Benda Uji Kubus (SNI)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '📐 Bentuk: Kubus dengan dimensi 15×15×15 cm (150×150×150 mm)\n'
                '📏 Luas permukaan: Sisi × Sisi dalam cm²\n'
                '   Contoh: 15 cm × 15 cm = 225 cm²\n'
                '⚖️ Beban maksimum: Dalam kg/cm² (langsung dari mesin uji)\n'
                '🧮 Formula perhitungan:\n'
                '   fc (kg/cm²) = Beban (kg/cm²) / Luas (cm²)\n'
                '📊 Contoh perhitungan:\n'
                '   Beban = 50,625 kg/cm², Luas = 225 cm²\n'
                '   fc = 50,625 / 225 = 225 kg/cm²',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[900],
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

       
        TextFormField(
          controller: beratBendaUjiController,
          decoration: InputDecoration(
            labelText: 'Berat Benda Uji (kg)',
            hintText: ' ',
            prefixIcon: const Icon(Icons.monitor_weight),
            suffixText: 'kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Opsional - Untuk dokumentasi',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),

        const SizedBox(height: 16),

       
        TextFormField(
          controller: bebanController,
          decoration: InputDecoration(
            labelText: 'Beban Maksimum (kg/cm²)',
            hintText: ' ',
            prefixIcon: const Icon(Icons.fitness_center),
            suffixText: 'kg/cm²',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Bacaan beban maksimum dari mesin uji (dalam kg/cm²)',
            helperMaxLines: 2,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),

        const SizedBox(height: 16),

        
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Untuk kubus SNI, masukkan beban maksimum dalam kg/cm² langsung dari mesin uji tekan.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange[900],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}