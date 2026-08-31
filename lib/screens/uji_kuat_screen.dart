import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/uji_kuat_result.dart';
import '../services/uji_kuat_service.dart';
import '../services/history_service.dart';
import '../services/unified_report_service.dart';
import '../widgets/uji_photo_capture_widget.dart';

class UjiKuatScreen extends StatefulWidget {
  const UjiKuatScreen({Key? key}) : super(key: key);

  @override
  State<UjiKuatScreen> createState() => _UjiKuatScreenState();
}

class _UjiKuatScreenState extends State<UjiKuatScreen>
    with TickerProviderStateMixin {
  
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  
  final UjiKuatService _service = UjiKuatService();
  final HistoryService _historyService = HistoryService();
  final UnifiedReportService _reportService = UnifiedReportService();

  
  final TextEditingController _sisiKubusController = TextEditingController(text: '150');
  final TextEditingController _panjangKubusController = TextEditingController(text: '150');
  final TextEditingController _lebarKubusController = TextEditingController(text: '150');
  final TextEditingController _tinggiKubusController = TextEditingController(text: '150');
  
  
  String _satuanBebanKubus = 'kN'; 
  bool _isDimensiKubusCustom = false; 
  
  
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  
  
  final TextEditingController _bebanController = TextEditingController();
  final TextEditingController _beratBendaUjiController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _mutuController = TextEditingController();

  
  String _standarAcuan = 'SNI';
  String _mutuBeton = 'K-';
  bool _isLoading = false;
  bool _hasCalculated = false;
  UjiKuatResult? _result;

  
  DateTime _tanggalPembuatan = DateTime.now().subtract(const Duration(days: 28));
  DateTime _tanggalPengujian = DateTime.now();

  
  List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sisiKubusController.dispose();
    _panjangKubusController.dispose();
    _lebarKubusController.dispose();
    _tinggiKubusController.dispose();
    _diameterController.dispose();
    _tinggiController.dispose();
    _bebanController.dispose();
    _beratBendaUjiController.dispose();
    _pekerjaanController.dispose();
    _lokasiController.dispose();
    _mutuController.dispose();
    super.dispose();
  }

  
  String _extractNumber(String mutu) {
    return mutu.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  
  String _formatMutuDisplay(String mutu) {
    return _service.formatMutuDisplay(mutu, _standarAcuan);
  }

  
  int _hitungUmurBeton() {
    return _tanggalPengujian.difference(_tanggalPembuatan).inDays;
  }

  

  void _validateInput() {
    List<String> errors = [];

   
    if (_tanggalPengujian.isBefore(_tanggalPembuatan)) {
      errors.add('Tanggal pengujian tidak boleh lebih awal dari tanggal pembuatan');
    }

    if (_standarAcuan == 'SNI') {
      if (_isDimensiKubusCustom) {
        if (_panjangKubusController.text.isEmpty ||
            _lebarKubusController.text.isEmpty) {
          errors.add('Panjang dan Lebar kubus harus diisi');
        }
      } else if (_sisiKubusController.text.isEmpty) {
        errors.add('Sisi kubus harus diisi');
      }
    } else {
      if (_diameterController.text.isEmpty) {
        errors.add('Diameter silinder harus diisi');
      }
    }

    if (_bebanController.text.isEmpty) {
      errors.add('Beban maksimal harus diisi');
    }
    if (_mutuBeton.isEmpty || _extractNumber(_mutuBeton).isEmpty) {
      errors.add('Mutu beton harus dipilih');
    }

    var mutuValidation = _service.validateMutuBeton(_mutuBeton, _standarAcuan);
    if (!mutuValidation['valid']) {
      errors.addAll(List<String>.from(mutuValidation['errors']));
    }

    if (_standarAcuan == 'SNI' && !_isDimensiKubusCustom &&
        _sisiKubusController.text.isNotEmpty) {
      double? sisiKubus = double.tryParse(_sisiKubusController.text);
      if (sisiKubus != null && sisiKubus > 0) {
        var dimensiValidation = _service.validateDimensiKubus(sisiKubus);
        if (!dimensiValidation['valid']) {
          errors.addAll(List<String>.from(dimensiValidation['errors']));
        }
      }
    } else if (_standarAcuan != 'SNI' && _diameterController.text.isNotEmpty) {
      double? diameter = double.tryParse(_diameterController.text);
      if (diameter != null && diameter > 0) {
        double tinggiOtomatis = diameter * 2;
        _tinggiController.text = tinggiOtomatis.toStringAsFixed(1);

        var dimensiValidation =
            _service.validateDimensiSilinder(diameter, tinggiOtomatis);
        if (!dimensiValidation['valid']) {
          errors.addAll(List<String>.from(dimensiValidation['errors']));
        }
      }
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    _hitungKuatTekan();
  }

  void _hitungKuatTekan() async {
    double? beban = double.tryParse(_bebanController.text);
    double? beratBendaUji = double.tryParse(_beratBendaUjiController.text);

    if (beban == null || beban <= 0) {
      _showErrorDialog(['Beban maksimal harus diisi dengan nilai > 0']);
      return;
    }

    UjiKuatData data;

    if (_standarAcuan == 'SNI') {
      double? sisiKubus;
      double? panjangKubus;
      double? lebarKubus;
      double? tinggiKubus;

      if (_isDimensiKubusCustom) {
        panjangKubus = double.tryParse(_panjangKubusController.text);
        lebarKubus = double.tryParse(_lebarKubusController.text);
        tinggiKubus = double.tryParse(_tinggiKubusController.text);
        if (panjangKubus == null || panjangKubus <= 0 ||
            lebarKubus == null || lebarKubus <= 0) {
          _showErrorDialog(['Panjang/Lebar kubus tidak valid']);
          return;
        }
      } else {
        sisiKubus = double.tryParse(_sisiKubusController.text);
        if (sisiKubus == null || sisiKubus <= 0) {
          _showErrorDialog(['Sisi kubus tidak valid']);
          return;
        }
      }

      data = UjiKuatData(
        sisiKubus: sisiKubus,
        panjangKubus: panjangKubus,
        lebarKubus: lebarKubus,
        tinggiKubus: tinggiKubus,
        beban: beban,
        satuanBeban: _satuanBebanKubus,
        tanggalPembuatan: _tanggalPembuatan,
        tanggalPengujian: _tanggalPengujian,
        mutuBeton: _mutuBeton,
        beratBendaUji: beratBendaUji,
        pekerjaan: _pekerjaanController.text.trim().isEmpty 
            ? null 
            : _pekerjaanController.text.trim(),
        lokasi: _lokasiController.text.trim().isEmpty 
            ? null 
            : _lokasiController.text.trim(),
        photoPaths: _photoPaths.isNotEmpty ? _photoPaths : null,
      );
    } else {
      double? diameter = double.tryParse(_diameterController.text);
      if (diameter == null || diameter <= 0) {
        _showErrorDialog(['Diameter silinder tidak valid']);
        return;
      }

      data = UjiKuatData(
        diameter: diameter,
        beban: beban,
        tanggalPembuatan: _tanggalPembuatan,
        tanggalPengujian: _tanggalPengujian,
        mutuBeton: _mutuBeton,
        beratBendaUji: beratBendaUji,
        pekerjaan: _pekerjaanController.text.trim().isEmpty 
            ? null 
            : _pekerjaanController.text.trim(),
        lokasi: _lokasiController.text.trim().isEmpty 
            ? null 
            : _lokasiController.text.trim(),
        photoPaths: _photoPaths.isNotEmpty ? _photoPaths : null,
      );
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        UjiKuatResult result = _service.prosesUjiKuat(data, _standarAcuan);

        try {
          await _historyService.saveToHistory(
            result: result,
            data: data,
            standarAcuan: _standarAcuan,
          );
          await _reportService.saveUjiKuatReport(result, data);
        } catch (e) {
          debugPrint('Gagal simpan riwayat: $e');
        }

        setState(() {
          _result = result;
          _isLoading = false;
          _hasCalculated = true;
        });

        if (mounted) {
          _showSuccessSnackBar(
            'Hasil berhasil disimpan!${_photoPaths.isNotEmpty ? ' (${_photoPaths.length} foto)' : ''}\nLihat di menu Laporan untuk export.'
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(['Terjadi kesalahan: $e']);
      }
    });
  }

  void _resetForm() {
    setState(() {
      _result = null;
      _hasCalculated = false;
      _sisiKubusController.text = '150';
      _panjangKubusController.text = '150';
      _lebarKubusController.text = '150';
      _tinggiKubusController.text = '150';
      _isDimensiKubusCustom = false;
      _satuanBebanKubus = 'kN';
      _diameterController.clear();
      _tinggiController.clear();
      _bebanController.clear();
      _beratBendaUjiController.clear();
      _pekerjaanController.clear();
      _lokasiController.clear();
      _mutuController.clear();
      _photoPaths.clear();
      _tanggalPembuatan = DateTime.now().subtract(const Duration(days: 28));
      _tanggalPengujian = DateTime.now();
      
      if (_standarAcuan == 'SNI') {
        _mutuBeton = 'K-';
      } else {
        _mutuBeton = 'fc\' ';
      }
    });
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

  void _showErrorDialog(List<String> errors) {
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
              child: const Icon(Icons.error_outline,
                  color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text('Validasi Gagal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  )),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map((error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(error,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF64748B),
                                )),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tutup',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
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

  Color _getStatusColor(String status) {
    if (status == 'MEMENUHI SYARAT' || status == 'ACCEPTABLE') {
      return const Color(0xFF10B981);
    }
    if (status == 'BATAS MINIMUM' || 
        status == 'PERLU PERHATIAN' ||
        status == 'MARGINALLY ACCEPTABLE' ||
        status == 'QUESTIONABLE') {
      return const Color(0xFFF59E0B);
    }
    if (status == 'TIDAK MEMENUHI SYARAT' || status == 'UNACCEPTABLE') {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF94A3B8);
  }

  IconData _getStatusIcon(String status) {
    if (status == 'MEMENUHI SYARAT' || status == 'ACCEPTABLE') {
      return Icons.check_circle_rounded;
    }
    if (status == 'BATAS MINIMUM' || 
        status == 'PERLU PERHATIAN' ||
        status == 'MARGINALLY ACCEPTABLE' ||
        status == 'QUESTIONABLE') {
      return Icons.warning_rounded;
    }
    if (status == 'TIDAK MEMENUHI SYARAT' || status == 'UNACCEPTABLE') {
      return Icons.error_rounded;
    }
    return Icons.help_outline;
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    
                    
                    if (_hasCalculated) _buildSuccessBanner(),
                    if (_hasCalculated) const SizedBox(height: 12),
                    
                    
                    _buildProjectInfoCard(),
                    const SizedBox(height: 12),
                    
                    
                    _buildConfigurationCard(),
                    const SizedBox(height: 12),
                    
                    
                    UjiPhotoCaptureWidget(
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
                    
                    
                    _buildDataInputCard(),
                    const SizedBox(height: 12),
                    
                    
                    if (_result != null) _buildResultCard(),
                    const SizedBox(height: 80),
                  ],
                ),
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
        title: const Text('Uji Kuat Tekan',
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
                  'Data berhasil disimpan. Untuk export PDF, buka menu "Laporan".',
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Proyek',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      _standarAcuan == 'SNI' ? 'SNI 03-2847-2002' : 
                      _standarAcuan == 'BINA MARGA' ? 'Bina Marga 2018 Rev 2' : 'ASTM C39',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          
          _buildProjectTextField(
            controller: _pekerjaanController,
            label: 'Pekerjaan',
            icon: Icons.work_rounded,
            hint: 'Masukkan nama pekerjaan/proyek',
          ),
          const SizedBox(height: 14),
          
         
          _buildProjectTextField(
            controller: _lokasiController,
            label: 'Lokasi Proyek',
            icon: Icons.location_on_rounded,
            hint: 'Masukkan lokasi proyek',
          ),
          const SizedBox(height: 16),
          
         
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Tgl Pembuatan',
                  date: _tanggalPembuatan,
                  icon: Icons.calendar_today_rounded,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Tgl Pengujian',
                  date: _tanggalPengujian,
                  icon: Icons.science_rounded,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          
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
                  child: const Icon(Icons.access_time_rounded,
                      color: Color(0xFF0EA5E9), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Umur Beton',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 3),
                      Text('${_hitungUmurBeton()} hari',
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

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF8B5CF6), size: 16),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 6),
            Text(dateFormat.format(date),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isPembuatan) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPembuatan ? _tanggalPembuatan : _tanggalPengujian,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isPembuatan) {
          _tanggalPembuatan = picked;
        } else {
          _tanggalPengujian = picked;
        }
      });
    }
  }
  Widget _buildConfigurationCard() {
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
                child: const Icon(Icons.settings_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KONFIGURASI PENGUJIAN',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      )),
                  SizedBox(height: 2),
                  Text('Standar Acuan & Mutu Beton',
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
          
         
          const Text(
            'Standar Acuan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 10),
          
         
          Row(
            children: [
              Expanded(
                child: _buildStandardRadioButton(
                  'SNI',
                  'SNI 03-2847-2002\n(Kubus 15×15×15 cm)',
                  'SNI',
                  Icons.view_in_ar_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStandardRadioButton(
                  'BINA MARGA',
                  'Bina Marga 2018\n(Silinder Ø × 2H)',
                  'BINA MARGA',
                  Icons.straighten_rounded,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          
          
          const Text(
            'Mutu Beton',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 10),
          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
            ),
            child: TextField(
              controller: _mutuController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78350F),
              ),
              decoration: InputDecoration(
                hintText: 'Masukkan nilai',
                hintStyle: TextStyle(
                  color: Colors.brown[300],
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.architecture_rounded, 
                    color: Color(0xFFD97706), size: 20),
                prefixText: _standarAcuan == 'SNI' ? 'K-' : 'fc\' ',
                prefixStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF78350F),
                ),
                suffixText: _standarAcuan == 'SNI' ? 'kg/cm²' : 'MPa',
                suffixStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                  String formatted = _standarAcuan == 'SNI' 
                      ? 'K-$value'
                      : 'fc\' $value';
                  setState(() {
                    _mutuBeton = formatted;
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
         
          const Text(
            'Pilihan Cepat:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
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
                    String formatted = _standarAcuan == 'SNI'
                        ? 'K-${option['value']}'
                        : 'fc\' ${option['value']}';
                    _mutuBeton = formatted;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFDEEAFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF3B82F6) 
                          : const Color(0xFF93C5FD),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    option['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF1E40AF),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
              color: const Color(0xFFDEEAFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, 
                    size: 18, 
                    color: Color(0xFF1E40AF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _standarAcuan == 'SNI'
                        ? 'Input angka untuk nilai K (berat karakteristik). Sistem otomatis menambahkan prefix K-. Contoh: input "225" = K-225'
                        : 'Input angka untuk nilai fc\' (kuat tekan). Sistem otomatis menambahkan fc\'. Contoh: input "25" = fc\' 25 MPa',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1E40AF),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardRadioButton(
    String title,
    String subtitle,
    String value,
    IconData icon,
  ) {
    bool isSelected = _standarAcuan == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _standarAcuan = value;
          _mutuController.clear();
          if (value == 'SNI') {
            _mutuBeton = 'K-';
            _sisiKubusController.text = '150';
          } else {
            _mutuBeton = 'fc\' ';
            _diameterController.clear();
            _tinggiController.clear();
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF3B82F6).withOpacity(0.1)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, 
                color: isSelected 
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF64748B),
                size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? const Color(0xFF1E40AF)
                    : const Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected 
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF94A3B8),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getQuickSelectOptions() {
    if (_standarAcuan == 'SNI') {
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
  Widget _buildDataInputCard() {
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
                child: Icon(
                  _standarAcuan == 'SNI' 
                      ? Icons.view_in_ar_rounded
                      : Icons.straighten_rounded,
                  color: Colors.white, 
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _standarAcuan == 'SNI' 
                          ? 'DATA PENGUJIAN KUBUS'
                          : 'DATA PENGUJIAN SILINDER',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _standarAcuan == 'SNI' 
                          ? 'Benda Uji Kubus 15×15×15 cm'
                          : 'Benda Uji Silinder (H:D = 2:1)',
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
          
          if (_standarAcuan == 'SNI')
            _buildKubusInputs()
          else
            _buildSilinderInputs(),
        ],
      ),
    );
  }

  Widget _buildKubusInputs() {
    return Column(
      children: [
        
        _buildToggleRow(
          label: 'Ukuran Benda Uji',
          options: const ['Standar (150mm)', 'Custom'],
          selectedIndex: _isDimensiKubusCustom ? 1 : 0,
          onSelected: (i) {
            setState(() {
              _isDimensiKubusCustom = (i == 1);
            });
          },
        ),
        const SizedBox(height: 12),

        if (!_isDimensiKubusCustom) ...[
          _buildInputField(
            controller: _sisiKubusController,
            label: 'Sisi Kubus',
            symbol: 'S',
            unit: 'mm',
            icon: Icons.view_in_ar_rounded,
            hint: 'Standar: 150 mm',
          ),
        ] else ...[
          _buildInputField(
            controller: _panjangKubusController,
            label: 'Panjang',
            symbol: 'P',
            unit: 'mm',
            icon: Icons.straighten_rounded,
            hint: 'Ukuran sisi 1 (bidang tekan)',
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _lebarKubusController,
            label: 'Lebar',
            symbol: 'L',
            unit: 'mm',
            icon: Icons.straighten_rounded,
            hint: 'Ukuran sisi 2 (bidang tekan)',
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _tinggiKubusController,
            label: 'Tinggi',
            symbol: 'T',
            unit: 'mm',
            icon: Icons.height_rounded,
            hint: 'Untuk dokumentasi, tidak memengaruhi luas',
          ),
        ],
        const SizedBox(height: 12),
        
        _buildInputField(
          controller: _beratBendaUjiController,
          label: 'Berat Benda Uji (Opsional)',
          symbol: 'W',
          unit: 'kg',
          icon: Icons.monitor_weight_rounded,
          hint: 'Untuk dokumentasi',
        ),
        const SizedBox(height: 12),

        
        _buildToggleRow(
          label: 'Satuan Beban Maksimum',
          options: const ['kN', 'kg/cm²'],
          selectedIndex: _satuanBebanKubus == 'kN' ? 0 : 1,
          onSelected: (i) {
            setState(() {
              _satuanBebanKubus = (i == 0) ? 'kN' : 'kg/cm²';
            });
          },
        ),
        const SizedBox(height: 12),
        
        _buildInputField(
          controller: _bebanController,
          label: 'Beban Maksimum',
          symbol: 'P',
          unit: _satuanBebanKubus,
          icon: Icons.fitness_center_rounded,
          hint: _satuanBebanKubus == 'kN'
              ? 'Bacaan langsung dari mesin uji (kN)'
              : 'Bacaan langsung dari mesin uji (kg/cm²)',
        ),
        const SizedBox(height: 14),
        
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDEEAFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, 
                      size: 18, 
                      color: Color(0xFF1E40AF)),
                  const SizedBox(width: 8),
                  const Text(
                    'Informasi Benda Uji Kubus (SNI)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _satuanBebanKubus == 'kN'
                    ? '📐 Bentuk: Kubus (bidang tekan Panjang × Lebar)\n'
                      '📏 Luas: Panjang × Lebar (mm → cm²)\n'
                      '⚖️ Beban: kN (bacaan alat baru)\n'
                      '🧮 Formula: Beban (kg) = Beban (kN) × 101,97\n'
                      '   fc (kg/cm²) = Beban (kg) / Luas (cm²)\n'
                      '📊 Contoh: 348 kN × 101,97 = 35.485,6 kg\n'
                      '   Luas 225 cm² → fc = 157,7 kg/cm²'
                    : '📐 Bentuk: Kubus (bidang tekan Panjang × Lebar)\n'
                      '📏 Luas: Panjang × Lebar (mm → cm²)\n'
                      '⚖️ Beban: kg/cm² (bacaan alat lama)\n'
                      '🧮 Formula: fc = P / Luas\n'
                      '📊 Contoh: P = 50.625 kg/cm², Luas = 225 cm²\n'
                      '   → fc = 50.625 / 225 = 225 kg/cm²',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1E40AF),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  
  Widget _buildToggleRow({
    required String label,
    required List<String> options,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            )),
        const SizedBox(height: 6),
        Row(
          children: List.generate(options.length, (i) {
            final bool selected = i == selectedIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
                child: InkWell(
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      options[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSilinderInputs() {
    return Column(
      children: [
        _buildInputField(
          controller: _diameterController,
          label: 'Diameter Silinder',
          symbol: 'D',
          unit: 'mm',
          icon: Icons.straighten_rounded,
          hint: 'Standar: 100 atau 150 mm',
          onChanged: (value) {
            if (value.isNotEmpty) {
              double? diameter = double.tryParse(value);
              if (diameter != null && diameter > 0) {
                _tinggiController.text = (diameter * 2).toStringAsFixed(1);
              }
            }
          },
        ),
        const SizedBox(height: 12),
        
        _buildInputField(
          controller: _tinggiController,
          label: 'Tinggi Silinder (Otomatis)',
          symbol: 'H',
          unit: 'mm',
          icon: Icons.height_rounded,
          hint: 'Auto: 2 × Diameter',
          enabled: false,
        ),
        const SizedBox(height: 12),
        
        _buildInputField(
          controller: _beratBendaUjiController,
          label: 'Berat Benda Uji (Opsional)',
          symbol: 'W',
          unit: 'kg',
          icon: Icons.monitor_weight_rounded,
          hint: 'Untuk dokumentasi',
        ),
        const SizedBox(height: 12),
        
        _buildInputField(
          controller: _bebanController,
          label: 'Gaya Tekan Maksimum',
          symbol: 'F',
          unit: 'kN',
          icon: Icons.fitness_center_rounded,
          hint: 'Dari mesin uji tekan',
        ),
        const SizedBox(height: 14),
        
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDEEAFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, 
                      size: 18, 
                      color: Color(0xFF1E40AF)),
                  const SizedBox(width: 8),
                  Text(
                    'Informasi Silinder (${_standarAcuan})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '📐 Bentuk: Silinder dengan rasio H:D = 2:1\n'
                '📏 Diameter: 100 mm (Ø10 cm) atau 150 mm (Ø15 cm)\n'
                '📏 Luas: 0.25 × π × D² dalam mm²\n'
                '⚖️ Gaya: Dalam kN (kilonewton)\n'
                '🧮 Formula: fc = (F × 1000) / Luas mm²\n'
                '📊 Contoh: F = 450 kN, D = 150 mm\n'
                '   → Luas = 17,678.57 mm²\n'
                '   → fc = (450 × 1000) / 17,678.57 = 25.45 MPa',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1E40AF),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
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
    Function(String)? onChanged,
  }) {
    return Column(
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
                    hintText: hint ?? 'Masukkan nilai',
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
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: onChanged,
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
    );
  }
  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();

    Color statusColor = _getStatusColor(_result!.statusKualitas);
    IconData statusIcon = _getStatusIcon(_result!.statusKualitas);
    String mutuDisplay = _formatMutuDisplay(_mutuBeton);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
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
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HASIL PENGUJIAN',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        )),
                    SizedBox(height: 2),
                    Text('Kuat Tekan Beton',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

         
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.1),
                  statusColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: statusColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Kualitas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 4),
                      Text(_result!.statusKualitas,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          
          Builder(builder: (context) {
            final bool isKubusSNI = _standarAcuan == 'SNI' && _result!.sisiKubus != null;
            final bool isPrediksi = _result!.isPrediksi28Hari;

            final double mainValue = isKubusSNI
                ? (_result!.kuatTekanKubus ?? _result!.kuatTekan)
                : _result!.kuatTekan;
            final String mainUnit = isKubusSNI ? 'kg/cm²' : 'MPa';

            final double? secondaryValue = isKubusSNI
                ? _result!.kuatTekan 
                : _result!.kuatTekanEkivalenKgCm2; 
            final String secondaryUnit = isKubusSNI ? 'MPa' : 'kg/cm²';
            final String secondaryLabel = isKubusSNI
                ? '≈ ${secondaryValue?.toStringAsFixed(2)} $secondaryUnit'
                : '≈ ${secondaryValue?.toStringAsFixed(2)} $secondaryUnit (setara kubus, info)';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPrediksi
                                ? 'PREDIKSI KUAT TEKAN\n(Umur 28 Hari)'
                                : 'KUAT TEKAN\n(Umur 28 Hari)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Compressive Strength',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              )),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              mainValue.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mainUnit,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (secondaryValue != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        secondaryLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          if (_result!.isPrediksi28Hari) ...[
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final bool isKubusSNI = _standarAcuan == 'SNI' && _result!.sisiKubus != null;
              final double? umurUjiValue = isKubusSNI
                  ? _result!.kuatTekanUmurUjiKgCm2
                  : _result!.kuatTekanUmurUjiMPa;
              final String umurUjiUnit = isKubusSNI ? 'kg/cm²' : 'MPa';
              if (umurUjiValue == null) return const SizedBox.shrink();
              return _buildResultRow(
                'Kuat Tekan Umur Uji (${_result!.umurBeton} hari)',
                '${umurUjiValue.toStringAsFixed(2)} $umurUjiUnit (hasil aktual, belum dikonversi)',
                Icons.science_rounded,
              );
            }),
          ],

          const SizedBox(height: 14),

         
          _buildResultRow('Mutu Rencana', mutuDisplay, Icons.architecture_rounded),
          
          if (_standarAcuan == 'SNI' && _result!.sisiKubus != null)
            _buildResultRow(
              'Bentuk Benda Uji',
              'Kubus ${(_result!.panjangKubus ?? _result!.sisiKubus!).toStringAsFixed(0)}×'
              '${(_result!.lebarKubus ?? _result!.sisiKubus!).toStringAsFixed(0)}×'
              '${(_result!.tinggiKubus ?? _result!.sisiKubus!).toStringAsFixed(0)} mm',
              Icons.view_in_ar_rounded,
            )
          else if (_result!.diameter != null)
            _buildResultRow(
              'Bentuk Benda Uji',
              'Silinder Ø${_result!.diameter!.toStringAsFixed(0)} mm × H${(_result!.diameter! * 2).toStringAsFixed(0)} mm',
              Icons.straighten_rounded,
            ),

          if (_result!.beratBendaUji != null)
            _buildResultRow(
              'Berat Benda Uji',
              '${_result!.beratBendaUji!.toStringAsFixed(2)} kg',
              Icons.monitor_weight_rounded,
            ),

          _buildResultRow(
            'Beban Maksimal',
            '${_result!.bebanMaksimal.toStringAsFixed(2)} '
            '${_standarAcuan == "SNI" ? (_result!.satuanBebanInput ?? "kg/cm²") : "kN"}',
            Icons.fitness_center_rounded,
          ),

          if (_standarAcuan != 'SNI' && _result!.kuatTekanEkivalenKgCm2 != null)
            _buildResultRow(
              'Kuat Tekan (Setara Kubus)',
              '${_result!.kuatTekanEkivalenKgCm2!.toStringAsFixed(2)} kg/cm² (info, tidak untuk evaluasi)',
              Icons.compare_arrows_rounded,
            ),

          _buildResultRow(
            'Luas Permukaan',
            _standarAcuan == 'SNI'
                ? '${_result!.luasPermukaan.toStringAsFixed(2)} cm²'
                : '${_result!.luasPermukaan.toStringAsFixed(2)} mm²',
            Icons.crop_square_rounded,
          ),

          _buildResultRow(
            'Umur Beton',
            '${_hitungUmurBeton()} hari',
            Icons.access_time_rounded,
          ),

          if (_result!.pekerjaan != null)
            _buildResultRow('Pekerjaan', _result!.pekerjaan!, Icons.work_rounded),

          if (_result!.lokasi != null)
            _buildResultRow('Lokasi', _result!.lokasi!, Icons.location_on_rounded),

          if (_result!.hasPhotos())
            _buildResultRow(
              'Foto Dokumentasi',
              '${_result!.getPhotoCount()} foto tersimpan',
              Icons.camera_alt_rounded,
            ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

         
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text('Keterangan Detail',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _result!.keterangan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

         
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Pengujian Baru',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0EA5E9),
                side: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
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
            onPressed: _isLoading || _result != null ? null : _validateInput,
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
            child: _isLoading
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
                            : Icons.calculate_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasCalculated
                            ? 'Tersimpan ✓'
                            : 'Hitung Kuat Tekan',
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

}
