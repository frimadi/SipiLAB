import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/konversi_result.dart';
import '../services/konversi_service.dart';
import '../services/unified_report_service.dart';

class KonversiDataInputSection extends StatefulWidget {
  const KonversiDataInputSection({Key? key}) : super(key: key);

  @override
  State<KonversiDataInputSection> createState() =>
      _KonversiDataInputSectionState();
}

class _KonversiDataInputSectionState extends State<KonversiDataInputSection> {
  final _formKey = GlobalKey<FormState>();
  final _umurController = TextEditingController();
  final _kuatTekanController = TextEditingController();
  final _reportService = UnifiedReportService();
  
  KonversiResult? _hasil;
  bool _isCalculated = false;
  
 
  String _jenisBendaUji = 'kubus';
  String _satuan = 'kg_cm2';

  @override
  void dispose() {
    _umurController.dispose();
    _kuatTekanController.dispose();
    super.dispose();
  }

  void _hitungKonversi() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        double umur = double.parse(_umurController.text);
        double kuatTekan = double.parse(_kuatTekanController.text);
        
        _hasil = KonversiService.hitungKonversi(
          umurBeton: umur,
          kuatTekanBeton: kuatTekan,
          jenisBendaUji: _jenisBendaUji,
          satuan: _satuan,
        );
        _isCalculated = true;
      });
    }
  }

  void _reset() {
    setState(() {
      _umurController.clear();
      _kuatTekanController.clear();
      _hasil = null;
      _isCalculated = false;
    });
  }

  Future<void> _simpanLaporan() async {
    if (_hasil == null) return;
    
    try {
      await _reportService.saveKonversiBetonReport(_hasil!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Laporan berhasil disimpan'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Gagal menyimpan laporan: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Input Data Pengujian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, color: Colors.green[600], size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Jenis Benda Uji:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _jenisBendaUji,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'kubus',
                              child: Text('Kubus (15×15×15 cm)'),
                            ),
                            DropdownMenuItem(
                              value: 'silinder',
                              child: Text('Silinder (Ø15×30 cm)'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _jenisBendaUji = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.straighten, color: Colors.green[600], size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Satuan:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _satuan,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'kg_cm2',
                              child: Text('Kg/Cm²'),
                            ),
                            DropdownMenuItem(
                              value: 'mpa',
                              child: Text('MPa (N/mm²)'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _satuan = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _umurController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Umur Beton (Hari)',
                  hintText: ' ',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.green[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Umur beton harus diisi';
                  }
                  double? umur = double.tryParse(value);
                  if (umur == null || umur <= 0) {
                    return 'Umur beton harus lebih dari 0';
                  }
                  if (umur > 365) {
                    return 'Umur beton tidak boleh lebih dari 365 hari';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
             
              TextFormField(
                controller: _kuatTekanController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Kuat Tekan Beton (${_satuan == 'kg_cm2' ? 'Kg/Cm²' : 'MPa'})',
                  hintText: 'Hasil pengujian tekan',
                  prefixIcon: Icon(Icons.compress, color: Colors.green[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kuat tekan beton harus diisi';
                  }
                  double? kuatTekan = double.tryParse(value);
                  if (kuatTekan == null || kuatTekan <= 0) {
                    return 'Kuat tekan beton harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
            
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _hitungKonversi,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Hitung Konversi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              
            
              if (_isCalculated && _hasil != null) ...[
                const SizedBox(height: 24),
                const Divider(thickness: 2),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Hasil Konversi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[50]!, Colors.green[100]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!, width: 2),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow(
                        'Jenis Benda Uji',
                        _hasil!.jenisBendaUjiDisplay,
                        Icons.category,
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Umur Beton',
                        '${_hasil!.umurBeton.toStringAsFixed(0)} Hari',
                        Icons.calendar_today,
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Faktor Konversi (K)',
                        _hasil!.faktorKonversi.toStringAsFixed(3),
                        Icons.functions,
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Kuat Tekan Uji',
                        '${_hasil!.kuatTekanBeton.toStringAsFixed(2)} ${_hasil!.satuanDisplay}',
                        Icons.science,
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Karakteristik',
                        _hasil!.karakteristik,
                        Icons.info,
                      ),
                      const Divider(thickness: 2),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        'Kuat Tekan 28 Hari (${_hasil!.jenisBendaUjiDisplay})',
                        '${_hasil!.hasilKonversi.toStringAsFixed(2)} ${_hasil!.satuanDisplay}',
                        Icons.assessment,
                        isHighlight: true,
                      ),
                     
                      if (_hasil!.jenisBendaUji == 'kubus') ...[
                        const Divider(),
                        _buildResultRow(
                          'Ekuivalen Silinder',
                          '${_hasil!.hasilKonversiSilinder.toStringAsFixed(2)} ${_hasil!.satuanDisplay}',
                          Icons.swap_horiz,
                          isSecondary: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, 
                           color: Colors.blue[800], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Perhitungan: ${_hasil!.kuatTekanBeton.toStringAsFixed(2)} ÷ ${_hasil!.faktorKonversi.toStringAsFixed(3)} = ${_hasil!.hasilKonversi.toStringAsFixed(2)} ${_hasil!.satuanDisplay}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                           
                            if (_hasil!.jenisBendaUji == 'kubus') ...[
                              const SizedBox(height: 4),
                              Text(
                                'Koreksi Bentuk: ${_hasil!.hasilKonversi.toStringAsFixed(2)} × 0.83 = ${_hasil!.hasilKonversiSilinder.toStringAsFixed(2)} ${_hasil!.satuanDisplay} (Silinder)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[800],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
               
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _simpanLaporan,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan ke Laporan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
    bool isSecondary = false, 
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isHighlight 
                ? Colors.green[800] 
                : isSecondary 
                    ? Colors.orange[600] 
                    : Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isHighlight ? 16 : 14,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isSecondary ? Colors.orange[700] : Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 15,
              fontWeight: FontWeight.bold,
              color: isHighlight 
                  ? Colors.green[900] 
                  : isSecondary 
                      ? Colors.orange[900] 
                      : Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}