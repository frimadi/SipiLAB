import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class UjiInputSilinderSection extends StatefulWidget {
  final TextEditingController diameterController;
  final TextEditingController tinggiController;
  final TextEditingController bebanController;
  final TextEditingController beratBendaUjiController;
  final DateTime tanggalPembuatan;
  final DateTime tanggalPengujian;
  final Function(DateTime) onTanggalPembuatanChanged;
  final Function(DateTime) onTanggalPengujianChanged;
  final String standarAcuan;

  const UjiInputSilinderSection({
    Key? key,
    required this.diameterController,
    required this.tinggiController,
    required this.bebanController,
    required this.beratBendaUjiController,
    required this.tanggalPembuatan,
    required this.tanggalPengujian,
    required this.onTanggalPembuatanChanged,
    required this.onTanggalPengujianChanged,
    required this.standarAcuan,
  }) : super(key: key);

  @override
  State<UjiInputSilinderSection> createState() => _UjiInputSilinderSectionState();
}

class _UjiInputSilinderSectionState extends State<UjiInputSilinderSection> {
 
  Future<void> _selectDate(BuildContext context, bool isPembuatan) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPembuatan ? widget.tanggalPembuatan : widget.tanggalPengujian,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      if (isPembuatan) {
        widget.onTanggalPembuatanChanged(picked);
      } else {
        widget.onTanggalPengujianChanged(picked);
      }
    }
  }

  int _hitungUmurBeton() {
    return widget.tanggalPengujian.difference(widget.tanggalPembuatan).inDays;
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
                  dateFormat.format(widget.tanggalPembuatan),
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
                  dateFormat.format(widget.tanggalPengujian),
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
          controller: widget.diameterController,
          decoration: InputDecoration(
            labelText: 'Diameter Silinder (mm)',
            hintText: ' ',
            prefixIcon: const Icon(Icons.straighten),
            suffixText: 'mm',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Diameter standar: 100 mm atau 150 mm',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              double? diameter = double.tryParse(value);
              if (diameter != null && diameter > 0) {
                widget.tinggiController.text = (diameter * 2).toStringAsFixed(1);
              }
            }
          },
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
                    'Informasi Benda Uji Silinder (${widget.standarAcuan})',
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
                '📐 Bentuk: Silinder dengan rasio tinggi:diameter = 2:1\n'
                '📏 Diameter standar: 100 mm (Ø10 cm) atau 150 mm (Ø15 cm)\n'
                '📏 Luas permukaan: 0.25 × π × D² dalam mm²\n'
                '   Formula: 0.25 × (22/7) × D²\n'
                '   Contoh D=150mm: 0.25 × (22/7) × 150² = 17,678.57 mm²\n'
                '⚖️ Gaya tekan: Dalam kN (kilonewton) dari mesin uji\n'
                '🧮 Formula perhitungan:\n'
                '   fc (MPa) = (Gaya kN × 1000) / Luas mm²\n'
                '   Karena 1 MPa = 1 N/mm², hasil langsung dalam MPa\n'
                '📊 Contoh perhitungan:\n'
                '   Gaya = 450 kN, Diameter = 150 mm\n'
                '   Luas = 17,678.57 mm²\n'
                '   fc = (450 × 1000) / 17,678.57 = 25.45 MPa',
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
          controller: widget.tinggiController,
          decoration: InputDecoration(
            labelText: 'Tinggi Silinder (mm)',
            prefixIcon: const Icon(Icons.height),
            suffixText: 'mm',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Otomatis terisi (rasio 2:1 dari diameter)',
            filled: true,
            fillColor: Colors.grey[100],
          ),
          readOnly: true,
          style: const TextStyle(color: Colors.black54),
        ),

        const SizedBox(height: 16),

        
        if (widget.standarAcuan == 'BINA MARGA')
          Column(
            children: [
              TextFormField(
                controller: widget.beratBendaUjiController,
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
            ],
          ),

       
        TextFormField(
          controller: widget.bebanController,
          decoration: InputDecoration(
            labelText: 'Gaya Tekan dari Mesin Uji (kN)',
            hintText: ' ',
            prefixIcon: const Icon(Icons.fitness_center),
            suffixText: 'kN',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Bacaan gaya tekan dari mesin uji (dalam kN)',
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
                  'Untuk silinder, masukkan gaya tekan dalam kN. Sistem akan otomatis menghitung kuat tekan dalam MPa.',
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