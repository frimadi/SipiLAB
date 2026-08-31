import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/sand_cone_test_result.dart';
import '../models/sand_cone_calibration_templates.dart';
import '../services/sand_cone_test_service.dart';
import '../services/unified_report_service.dart';
import '../widgets/calibration_template_selector.dart';
import '../widgets/sand_photo_capture_widget.dart';

class SandConeScreen extends StatefulWidget {
  const SandConeScreen({Key? key}) : super(key: key);

  @override
  State<SandConeScreen> createState() => _SandConeScreenState();
}

class _SandConeScreenState extends State<SandConeScreen> {
 
  final UnifiedReportService _reportService = UnifiedReportService();

 
  final TextEditingController _w1Controller = TextEditingController();
  final TextEditingController _w2Controller = TextEditingController();
  final TextEditingController _w3Controller = TextEditingController();
  final TextEditingController _w4Controller = TextEditingController();
  final TextEditingController _w5Controller = TextEditingController();

 
  final TextEditingController _w7Controller = TextEditingController();
  final TextEditingController _w8Controller = TextEditingController();
  final TextEditingController _w10Controller = TextEditingController();
  final TextEditingController _w11Controller = TextEditingController();
  final TextEditingController _kadarAirController = TextEditingController();
  final TextEditingController _ydLabController = TextEditingController();

 
  final TextEditingController _kontraktorController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();

 
  CalibrationTemplate? selectedTemplate;
  bool isCustomMode = false;


  List<String> _photoPaths = [];


  double _vb = 0;
  double _yp = 0;
  double _w6 = 0;
  double _w9 = 0;
  double _w12 = 0;
  double _w13 = 0;
  double _v = 0;
  double _yd = 0;
  double _ydLap = 0;
  double _derajatKepadatan = 0;

  String? _calculationError;
  bool _hasValidationError = false;
  bool _hasCalculated = false;
  bool _isLoading = false;
  String _selectedDate = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

   
    _loadDefaultTemplate();
    _addListeners();
  }

  void _loadDefaultTemplate() {
    final template = CalibrationTemplateService.getTemplateById('alat_uji_1');
    if (template != null) {
      _applyTemplate(template);
    }
  }

  void _applyTemplate(CalibrationTemplate template) {
    setState(() {
      selectedTemplate = template;
      isCustomMode = template.id == 'custom';
      
      _w1Controller.text = template.w1 > 0 ? template.w1.toString() : '';
      _w2Controller.text = template.w2 > 0 ? template.w2.toString() : '';
      _w3Controller.text = template.w3 > 0 ? template.w3.toString() : '';
      _w4Controller.text = template.w4 > 0 ? template.w4.toString() : '';
      _w5Controller.text = template.w5 > 0 ? template.w5.toString() : '';
    });
    
    _calculate();
  }

  void _addListeners() {
    _w1Controller.addListener(_calculate);
    _w2Controller.addListener(_calculate);
    _w3Controller.addListener(_calculate);
    _w4Controller.addListener(_calculate);
    _w5Controller.addListener(_calculate);
    _w7Controller.addListener(_calculate);
    _w8Controller.addListener(_calculate);
    _w10Controller.addListener(_calculate);
    _w11Controller.addListener(_calculate);
    _kadarAirController.addListener(_calculate);
    _ydLabController.addListener(_calculate);
  }

  void _calculate() {
    setState(() {
      double w1 = double.tryParse(_w1Controller.text) ?? 0;
      double w2 = double.tryParse(_w2Controller.text) ?? 0;
      double w3 = double.tryParse(_w3Controller.text) ?? 0;
      double w4 = double.tryParse(_w4Controller.text) ?? 0;
      double w5 = double.tryParse(_w5Controller.text) ?? 0;
      double w7 = double.tryParse(_w7Controller.text) ?? 0;
      double w8 = double.tryParse(_w8Controller.text) ?? 0;
      double w10 = double.tryParse(_w10Controller.text) ?? 0;
      double w11 = double.tryParse(_w11Controller.text) ?? 0;
      double kadarAir = double.tryParse(_kadarAirController.text) ?? 0;
      double ydLab = double.tryParse(_ydLabController.text) ?? 0;

      ComprehensiveResult comprehensive = SandConeTestService.hitungSemuaHasil(
        w1: w1,
        w2: w2,
        w3: w3,
        w4: w4,
        w5: w5,
        w7: w7,
        w8: w8,
        w10: w10,
        w11: w11,
        kadarAir: kadarAir,
        ydLab: ydLab,
      );

      if (comprehensive.isAllValid) {
        _calculationError = null;
        _hasValidationError = false;

        _vb = comprehensive.getValue('volumeBotol') ?? 0;
        _yp = comprehensive.getValue('beratIsiPasir') ?? 0;
        _w6 = comprehensive.getValue('beratPasirDalamCorong') ?? 0;
        _w9 = comprehensive.getValue('beratAgregatBasah') ?? 0;
        _w12 = comprehensive.getValue('beratPasirCorongLubang') ?? 0;
        _w13 = comprehensive.getValue('beratPasirDalamLubang') ?? 0;
        _v = comprehensive.getValue('volumeLubang') ?? 0;
        _yd = comprehensive.getValue('beratIsiTanahBasah') ?? 0;
        _ydLap = comprehensive.getValue('beratIsiTanahKering') ?? 0;
        _derajatKepadatan = comprehensive.getValue('derajatKepadatan') ?? 0;
      } else {
        _calculationError = comprehensive.firstError;
        _hasValidationError = true;

        final validValues = comprehensive.getValidValues();
        _vb = validValues['volumeBotol'] ?? 0;
        _yp = validValues['beratIsiPasir'] ?? 0;
        _w6 = validValues['beratPasirDalamCorong'] ?? 0;
        _w9 = validValues['beratAgregatBasah'] ?? 0;
        _w12 = validValues['beratPasirCorongLubang'] ?? 0;
        _w13 = validValues['beratPasirDalamLubang'] ?? 0;
        _v = validValues['volumeLubang'] ?? 0;
        _yd = validValues['beratIsiTanahBasah'] ?? 0;
        _ydLap = validValues['beratIsiTanahKering'] ?? 0;
        _derajatKepadatan = validValues['derajatKepadatan'] ?? 0;
      }
    });
  }

  @override
  void dispose() {
   
    _w1Controller.dispose();
    _w2Controller.dispose();
    _w3Controller.dispose();
    _w4Controller.dispose();
    _w5Controller.dispose();
    _w7Controller.dispose();
    _w8Controller.dispose();
    _w10Controller.dispose();
    _w11Controller.dispose();
    _kadarAirController.dispose();
    _ydLabController.dispose();
    _kontraktorController.dispose();
    _lokasiController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            sliver: SliverToBoxAdapter(
             
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  if (_hasValidationError && _calculationError != null)
                    _buildErrorBanner(),
                  if (_hasValidationError && _calculationError != null)
                    const SizedBox(height: 12),
                  if (_hasCalculated) _buildSuccessBanner(),
                  if (_hasCalculated) const SizedBox(height: 12),
                  _buildProjectInfoCard(),
                  const SizedBox(height: 12),
                  
                  CalibrationTemplateSelector(
                    onTemplateSelected: _applyTemplate,
                    initialTemplate: selectedTemplate,
                  ),
                  const SizedBox(height: 12),
                  
                  PhotoCaptureWidget(
                    initialPhotos: _photoPaths,
                    onPhotosChanged: (photos) {
                      setState(() {
                        _photoPaths = photos;
                      });
                    },
                    maxPhotos: 5,
                    title: 'Foto Dokumentasi Pengujian',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSectionKalibrasi(),
                  const SizedBox(height: 12),
                  _buildSectionPengujian(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 18),
            ),
            onPressed: _showResetDialog,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
        title: const Text('Sand Cone Test',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            )),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0EA5E9),
                Color(0xFF0284C7),
                Color(0xFF0369A1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFEE2E2),
            const Color(0xFFFEE2E2).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Error Validasi',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
                const SizedBox(height: 3),
                Text(
                  _calculationError ?? 'Terjadi kesalahan perhitungan',
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD1FAE5),
            const Color(0xFFD1FAE5).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hasil Tersimpan!',
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
                SizedBox(height: 3),
                Text(
                  'Data berhasil disimpan. Untuk export PDF/Excel, buka menu "Laporan".',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.assignment_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Proyek',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        )),
                    SizedBox(height: 2),
                    Text('SNI 2828:2011',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildProjectTextField(
            controller: _kontraktorController,
            label: 'Nama Kontraktor',
            icon: Icons.business_rounded,
            hint: 'Masukkan nama kontraktor',
          ),
          const SizedBox(height: 14),
          _buildProjectTextField(
            controller: _lokasiController,
            label: 'Lokasi Proyek',
            icon: Icons.location_on_rounded,
            hint: 'Masukkan lokasi proyek',
          ),
          const SizedBox(height: 14),
          _buildProjectTextField(
            controller: _pekerjaanController,
            label: 'Jenis Pekerjaan',
            icon: Icons.construction_rounded,
            hint: 'Masukkan jenis pekerjaan',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8FAFC), Colors.white],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today_rounded,
                      color: Color(0xFF0EA5E9), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal Pengujian',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 3),
                      Text(_selectedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
              letterSpacing: -0.2,
            )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSectionKalibrasi() {
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
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.science_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('KALIBRASI ALAT SAND CONE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        )),
                    const SizedBox(height: 2),
                    Text(
                      isCustomMode ? 'Mode: Kustom (Input Manual)' : 'Mode: ${selectedTemplate?.name ?? ""}',
                      style: const TextStyle(
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
          
          _buildInputField(
            controller: _w1Controller,
            label: 'Berat Botol + Corong',
            symbol: 'W1',
            unit: 'gram',
            icon: Icons.view_in_ar_rounded,
            enabled: isCustomMode,
          ),
          _buildInputField(
            controller: _w2Controller,
            label: 'Berat Botol Penuh Air + Corong',
            symbol: 'W2',
            unit: 'gram',
            icon: Icons.water_drop_rounded,
            enabled: isCustomMode,
          ),
          _buildResultField(
            label: 'Volume Botol (Vb)',
            formula: 'Vb = W2-W1',
            value: _vb,
            unit: 'ml',
            icon: Icons.straighten_rounded,
          ),
          _buildInputField(
            controller: _w3Controller,
            label: 'Berat Botol Penuh Pasir + Corong',
            symbol: 'W3',
            unit: 'gram',
            icon: Icons.grass_rounded,
            enabled: isCustomMode,
          ),
          _buildResultField(
            label: 'Berat Isi Pasir (Yp)',
            formula: 'Yp = (W3-W1)/(W2-W1)',
            value: _yp,
            unit: 'gr/ml',
            icon: Icons.calculate_rounded,
            isImportant: true,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _w4Controller,
            label: 'Berat Botol + Pasir Corong',
            symbol: 'W4',
            unit: 'gram',
            icon: Icons.inventory_2_rounded,
            enabled: isCustomMode,
          ),
          _buildInputField(
            controller: _w5Controller,
            label: 'Berat Botol + Sisa Pasir + Corong',
            symbol: 'W5',
            unit: 'gram',
            icon: Icons.inventory_2_outlined,
            enabled: isCustomMode,
          ),
          _buildResultField(
            label: 'Berat Pasir Dalam Corong (W6)',
            formula: 'W6 = W4-W5',
            value: _w6,
            unit: 'gram',
            icon: Icons.analytics_outlined,
            isImportant: true,
          ),
        ],
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
    bool enabled = true,
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
                  color: enabled 
                      ? const Color(0xFFFBBF24).withOpacity(0.2)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, 
                    size: 15, 
                    color: enabled 
                        ? const Color(0xFFD97706) 
                        : const Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: enabled 
                          ? const Color(0xFF475569)
                          : const Color(0xFF94A3B8),
                    )),
              ),
              if (!enabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Dari Template',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.bold,
                      )),
                ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(symbol,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B82F6),
                      fontFamily: 'monospace',
                    )),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: enabled 
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: enabled
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFE2E8F0),
                        width: 1.5),
                  ),
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: enabled
                          ? const Color(0xFF78350F)
                          : const Color(0xFF64748B),
                    ),
                    decoration: InputDecoration(
                      hintText: hint ?? (enabled ? 'Masukkan nilai' : 'Otomatis dari template'),
                      hintStyle: TextStyle(
                        color: enabled ? Colors.brown[300] : Colors.grey[400],
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
                child: Text(unit,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    )),
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
                child: Icon(icon,
                    size: 15,
                    color: isImportant
                        ? const Color(0xFF059669)
                        : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isImportant ? FontWeight.bold : FontWeight.w600,
                      color: isImportant
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF475569),
                    )),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(formula,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                      fontFamily: 'monospace',
                    )),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  child: Text(value.toStringAsFixed(4),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isImportant
                            ? const Color(0xFF065F46)
                            : const Color(0xFF1E293B),
                        fontFamily: 'monospace',
                      )),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(unit,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSectionPengujian() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
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
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.terrain_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PENGUJIAN KEPADATAN',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      )),
                  SizedBox(height: 2),
                  Text('Section II - SNI 2828:2011',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _w7Controller,
            label: 'Berat Cawan Kosong',
            symbol: 'W7',
            unit: 'gram',
            icon: Icons.inbox_rounded,
          ),
          _buildInputField(
            controller: _w8Controller,
            label: 'Berat Cawan + Agregat/Tanah',
            symbol: 'W8',
            unit: 'gram',
            icon: Icons.scale_rounded,
          ),
          _buildResultField(
            label: 'Berat Agregat Basah (W9)',
            formula: 'W9 = W8-W7',
            value: _w9,
            unit: 'gram',
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _w10Controller,
            label: 'Berat Botol + Pasir + Corong',
            symbol: 'W10',
            unit: 'gram',
            icon: Icons.science_rounded,
          ),
          _buildInputField(
            controller: _w11Controller,
            label: 'Berat Botol + Sisa Pasir + Corong',
            symbol: 'W11',
            unit: 'gram',
            icon: Icons.science_outlined,
          ),
          _buildResultField(
            label: 'Berat Pasir di dalam Corong + Lubang (W12)',
            formula: 'W12 = W10-W11',
            value: _w12,
            unit: 'gram',
            icon: Icons.grass_rounded,
          ),
          _buildResultField(
            label: 'Berat Pasir di dalam Lubang (W13)',
            formula: 'W13 = W12-W6',
            value: _w13,
            unit: 'gram',
            icon: Icons.analytics_rounded,
            isImportant: true,
          ),
          _buildResultField(
            label: 'Volume Pasir dalam Lubang (V)',
            formula: 'V = W13/Yp',
            value: _v,
            unit: 'ml',
            icon: Icons.water_drop_outlined,
          ),
          _buildResultField(
            label: 'Berat isi Tanah Basah (Yd)',
            formula: 'Yd = W9/V',
            value: _yd,
            unit: 'gr/ml',
            icon: Icons.compress_rounded,
            isImportant: true,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _kadarAirController,
            label: 'Kadar Air (dalam persen)',
            symbol: 'W',
            unit: '%',
            icon: Icons.water_rounded,
            hint: ' ',
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDEEAFF),
                  const Color(0xFFDEEAFF).withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF0EA5E9).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.science_rounded,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Text('Data dari Laboratorium',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      flex: 3,
                      child: Text('Kepadatan Lab (Yd Lab)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          )),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: const Color(0xFF0EA5E9).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text('Yd Lab (Sampel)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1),
                            fontFamily: 'monospace',
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF0EA5E9).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _ydLabController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Masukkan nilai',
                            hintStyle: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: const Text('gr/ml',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildResultField(
            label: 'Berat isi Kering (Yd Lap)',
            formula: 'Yd Lap = Yd/(1+W/100)',
            value: _ydLap,
            unit: 'gr/ml',
            icon: Icons.compress,
            isImportant: true,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          _buildDerajatKepadatanCard(),
          const SizedBox(height: 10),
          _buildStatusIndicator(_derajatKepadatan),
        ],
      ),
    );
  }

  Widget _buildDerajatKepadatanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPercentageColor(_derajatKepadatan).withOpacity(0.1),
            _getPercentageColor(_derajatKepadatan).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPercentageColor(_derajatKepadatan),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DERAJAT KEPADATAN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _getPercentageColor(_derajatKepadatan),
                    )),
                const SizedBox(height: 3),
                const Text('Yd Lap/Yd Lab × 100%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                      fontFamily: 'monospace',
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getPercentageColor(_derajatKepadatan),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:
                      _getPercentageColor(_derajatKepadatan).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(_derajatKepadatan.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    )),
                const SizedBox(width: 4),
                const Text('%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ],
            ),
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
            child: Text(status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                )),
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
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading || _hasValidationError ? null : _saveToReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasCalculated
                  ? const Color(0xFF10B981)
                  : const Color(0xFF0EA5E9),
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF94A3B8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading && !_hasCalculated
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasCalculated
                            ? Icons.check_circle_rounded
                            : Icons.save_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasCalculated ? 'Tersimpan ✓' : 'Simpan ke Laporan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveToReport() async {
    if (_hasValidationError) {
      _showErrorSnackBar('Tidak dapat menyimpan: $_calculationError');
      return;
    }

    setState(() => _isLoading = true);

    try {
      SandConeTestResult result = _getCurrentResult();
      await _reportService.saveSandConeReport(result);

      if (mounted) {
        setState(() => _hasCalculated = true);
        _showSuccessSnackBar(
            'Hasil berhasil disimpan!\nLihat di menu Laporan untuk export.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  SandConeTestResult _getCurrentResult() {
    return SandConeTestResult(
      beratBotolCorong: double.tryParse(_w1Controller.text) ?? 0,
      beratBotolCorongAir: double.tryParse(_w2Controller.text) ?? 0,
      volumeBotolCorong: _vb,
      beratBotolCorongPasir: double.tryParse(_w3Controller.text) ?? 0,
      beratIsiPasir: _yp,
      beratBotolCorongA: double.tryParse(_w4Controller.text) ?? 0,
      beratBotolCorongSisaPasir: double.tryParse(_w5Controller.text) ?? 0,
      beratPasirDalamCorong: _w6,
      beratBotolCorongB: double.tryParse(_w10Controller.text) ?? 0,
      beratBotolCorongSisaPasirB: double.tryParse(_w11Controller.text) ?? 0,
      beratPasirDalamTakaran: _w13,
      beratIsiPasirB: double.tryParse(_ydLabController.text) ?? 0,
      beratTanahWadah: double.tryParse(_w8Controller.text) ?? 0,
      beratWadah: double.tryParse(_w7Controller.text) ?? 0,
      beratTanah: _w9,
      beratBotolCorongPasirC: double.tryParse(_w10Controller.text) ?? 0,
      beratBotolSisaPasir: double.tryParse(_w11Controller.text) ?? 0,
      beratPasirDalamLubang: _w13,
      vLubang: _v,
      beratIsiTanah: _yd,
      kadarAir: double.tryParse(_kadarAirController.text) ?? 0,
      beratIsiTanahKering: _ydLap,
      persentaseKepadatan: _derajatKepadatan,
      photoPaths: _photoPaths,
      kontraktor: _kontraktorController.text.trim().isEmpty 
          ? null 
          : _kontraktorController.text.trim(),
      lokasiProyek: _lokasiController.text.trim().isEmpty 
          ? null 
          : _lokasiController.text.trim(),
      jenisPekerjaan: _pekerjaanController.text.trim().isEmpty 
          ? null 
          : _pekerjaanController.text.trim(),
      tanggalPengujian: DateTime.now(),
    );
  }

  void _resetForm() {
    _w1Controller.clear();
    _w2Controller.clear();
    _w3Controller.clear();
    _w4Controller.clear();
    _w5Controller.clear();
    _w7Controller.clear();
    _w8Controller.clear();
    _w10Controller.clear();
    _w11Controller.clear();
    _kadarAirController.clear();
    _ydLabController.clear();
    _kontraktorController.clear();
    _lokasiController.clear();
    _pekerjaanController.clear();
    _calculationError = null;
    _hasValidationError = false;
    _hasCalculated = false;
    _photoPaths.clear();
    _loadDefaultTemplate();
  }

  void _showResetDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEF4444).withOpacity(0.2),
                    const Color(0xFFEF4444).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restart_alt_rounded,
                  color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text('Reset Form',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  )),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin mereset semua data? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
          ),
          ElevatedButton(
            onPressed: () {
              _resetForm();
              Navigator.pop(context);
              _showSuccessSnackBar('Form berhasil direset');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Reset',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 4,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }
}

