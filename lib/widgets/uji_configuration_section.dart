import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UjiConfigurationSection extends StatefulWidget {
  final String standarAcuan;
  final Function(String) onStandarChanged;
  final String mutuBeton;
  final Function(String) onMutuChanged;

  const UjiConfigurationSection({
    Key? key,
    required this.standarAcuan,
    required this.onStandarChanged,
    required this.mutuBeton,
    required this.onMutuChanged,
  }) : super(key: key);

  @override
  State<UjiConfigurationSection> createState() => _UjiConfigurationSectionState();
}

class _UjiConfigurationSectionState extends State<UjiConfigurationSection> {
  late TextEditingController _mutuController;

  @override
  void initState() {
    super.initState();
    _mutuController = TextEditingController(text: _extractNumber(widget.mutuBeton));
  }

  @override
  void didUpdateWidget(UjiConfigurationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
   
    if (oldWidget.standarAcuan != widget.standarAcuan) {
      _mutuController.text = '';
    }
  }

  @override
  void dispose() {
    _mutuController.dispose();
    super.dispose();
  }

  
  String _extractNumber(String mutu) {
    
    return mutu.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  
  List<Map<String, String>> _getQuickSelectOptions() {
    if (widget.standarAcuan == 'SNI') {
      return [
        {'label': 'K-175', 'value': '175'},
        {'label': 'K-225', 'value': '225'},
        {'label': 'K-250', 'value': '250'},
        {'label': 'K-300', 'value': '300'},
        {'label': 'K-350', 'value': '350'},
        {'label': 'K-400', 'value': '400'},
        {'label': 'K-500', 'value': '500'},
      ];
    } else {
      return [
        {'label': 'fc\' 20', 'value': '20'},
        {'label': 'fc\' 25', 'value': '25'},
        {'label': 'fc\' 30', 'value': '30'},
        {'label': 'fc\' 35', 'value': '35'},
        {'label': 'fc\' 40', 'value': '40'},
        {'label': 'fc\' 50', 'value': '50'},
      ];
    }
  }

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
                Icon(Icons.settings, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Konfigurasi Pengujian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            
            const Text(
              'Standar Acuan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('SNI'),
                    subtitle: const Text('SNI 03-2847-2002'),
                    value: 'SNI',
                    groupValue: widget.standarAcuan,
                    onChanged: (value) {
                      widget.onStandarChanged(value!);
                     
                      _mutuController.clear();
                      widget.onMutuChanged('K-');
                    },
                    activeColor: Colors.blue[700],
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('BINA MARGA'),
                    subtitle: const Text('Spek 2018 Rev 2'),
                    value: 'BINA MARGA',
                    groupValue: widget.standarAcuan,
                    onChanged: (value) {
                      widget.onStandarChanged(value!);
                     
                      _mutuController.clear();
                      widget.onMutuChanged('fc\' ');
                    },
                    activeColor: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
           
            TextFormField(
              controller: _mutuController,
              decoration: InputDecoration(
                labelText: widget.standarAcuan == 'SNI' 
                    ? 'Mutu Beton K (kg/cm²)' 
                    : 'Concrete Grade fc\' (MPa)',
                hintText: widget.standarAcuan == 'SNI' 
                    ? ' ' 
                    : ' ',
                prefixIcon: Icon(Icons.architecture),
                prefixText: widget.standarAcuan == 'SNI' ? 'K-' : 'fc\' ',
                suffixText: widget.standarAcuan == 'SNI' ? 'kg/cm²' : 'MPa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: widget.standarAcuan == 'SNI'
                    ? 'Input angka untuk nilai K (berat karakteristik kg/cm²)'
                    : 'Input angka untuk nilai fc\' (kuat tekan MPa)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                 
                  String formatted = widget.standarAcuan == 'SNI' 
                      ? 'K-$value'
                      : 'fc\' $value';
                  widget.onMutuChanged(formatted);
                }
              },
            ),
            
           
            const SizedBox(height: 12),
            const Text(
              'Pilihan Cepat:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getQuickSelectOptions().map((option) {
                
                bool isSelected = _mutuController.text == option['value'];
                
                return InkWell(
                  onTap: () {
                    
                    setState(() {
                      _mutuController.text = option['value']!;
                    });
                    
                    String formatted = widget.standarAcuan == 'SNI'
                        ? 'K-${option['value']}'
                        : 'fc\' ${option['value']}';
                    widget.onMutuChanged(formatted);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[700] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue[700]! : Colors.blue[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      option['label']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.blue[900],
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
           
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, 
                       size: 20, 
                       color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.standarAcuan == 'SNI'
                          ? 'Input angka untuk nilai K (berat karakteristik). Sistem otomatis menambahkan prefix K-. Contoh: input "225" = K-225 (225 kg/cm² = 22.07 MPa)'
                          : 'Input angka untuk nilai fc\' (kuat tekan). Sistem otomatis menambahkan fc\'. Contoh: input "25" = fc\' 25 MPa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
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
}