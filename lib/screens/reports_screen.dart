import 'dart:io';
import 'package:flutter/material.dart';
import '../services/unified_report_service.dart';
import '../services/unified_export_service.dart';
import '../models/hammer_test_result.dart';
import '../models/sand_cone_test_result.dart';
import '../models/uji_kuat_result.dart';
import '../models/konversi_result.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> 
    with SingleTickerProviderStateMixin {
  final UnifiedReportService _service = UnifiedReportService();
  final UnifiedExportService _exportService = UnifiedExportService();
  
  List<UnifiedReport> _reports = [];
  Map<String, int> _statistics = {};
  bool _isLoading = true;
  bool _isExporting = false;
  String _filterType = 'all';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      switch (_tabController.index) {
        case 0: _filterType = 'all'; break;
        case 1: _filterType = 'sand_cone'; break;
        case 2: _filterType = 'hammer_test'; break;
        case 3: _filterType = 'uji_kuat'; break;
        case 4: _filterType = 'konversi_beton'; break;
      }
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    
    try {
      List<UnifiedReport> reports;
      if (_filterType == 'all') {
        reports = await _service.getAllReports();
      } else {
        reports = await _service.getReportsByType(_filterType);
      }
      
      final stats = await _service.getReportStatistics();
      
      setState(() {
        _reports = reports;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat laporan: $e')),
        );
      }
    }
  }

  Future<void> _exportToPDF(UnifiedReport report) async {
    setState(() => _isExporting = true);
    
    try {
      final file = await _exportService.exportSingleReportToPDF(report);
      await _exportService.sharePDF(file, report.title);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal export PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAllToPDF() async {
    if (_reports.isEmpty) return;
    
    setState(() => _isExporting = true);
    
    try {
      final file = await _exportService.exportMultipleReportsToPDF(_reports);
      await _exportService.sharePDF(file, 'Laporan Gabungan');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF gabungan berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal export PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _deleteReport(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Laporan'),
        content: const Text('Yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteReport(id);
      _loadReports();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _clearAllReports() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua Laporan'),
        content: const Text('Yakin ingin menghapus SEMUA laporan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.clearAllReports();
      _loadReports();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua laporan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Laporan Pengujian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_reports.isNotEmpty && !_isExporting)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportAllToPDF,
              tooltip: 'Export PDF',
            ),
          if (_reports.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllReports,
              tooltip: 'Hapus Semua',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard('Semua', _statistics['total'] ?? 0, 
                          Icons.folder_open, Colors.white.withOpacity(0.2)),
                      const SizedBox(width: 8),
                      _buildStatCard('Sand Cone', _statistics['sand_cone'] ?? 0, 
                          Icons.science, Colors.white.withOpacity(0.2)),
                      const SizedBox(width: 8),
                      _buildStatCard('Hammer', _statistics['hammer_test'] ?? 0, 
                          Icons.construction, Colors.white.withOpacity(0.2)),
                      const SizedBox(width: 8),
                      _buildStatCard('Uji Kuat', _statistics['uji_kuat'] ?? 0, 
                          Icons.fitness_center, Colors.white.withOpacity(0.2)),
                      const SizedBox(width: 8),
                      _buildStatCard('Konversi', _statistics['konversi_beton'] ?? 0, 
                          Icons.transform, Colors.white.withOpacity(0.2)),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF6366F1),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF6366F1),
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Semua'),
                    Tab(text: 'Sand Cone'),
                    Tab(text: 'Hammer'),
                    Tab(text: 'Uji Kuat'),
                    Tab(text: 'Konversi'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reports.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadReports,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) => _buildReportCard(_reports[index]),
                      ),
                    ),
          if (_isExporting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Membuat PDF...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color bgColor) {
    return Container(
      width: 85,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(height: 6),
          Text(count.toString(), 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, 
                  color: Colors.white)),
          Text(label, 
              style: const TextStyle(fontSize: 10, color: Colors.white), 
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
                color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.description_outlined, 
                size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text('Belum Ada Laporan', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, 
                  color: Colors.grey[800])),
          const SizedBox(height: 8),
          Text('Lakukan pengujian untuk membuat laporan', 
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  Widget _buildReportCard(UnifiedReport report) {
    IconData icon;
    LinearGradient gradient;
    bool hasPhotos = false;
    int photoCount = 0;
    
    switch (report.type) {
      case 'sand_cone':
        icon = Icons.science;
        gradient = const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]);
        final sandResult = SandConeTestResult.fromJson(report.data);
        hasPhotos = sandResult.hasDokumentasiFoto;
        photoCount = sandResult.jumlahFoto;
        break;
      case 'hammer_test':
        icon = Icons.construction;
        gradient = const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]);
        final hammerResult = HammerTestResult.fromMap(report.data);
        hasPhotos = hammerResult.hasDokumentasiFoto;
        photoCount = hammerResult.jumlahFoto;
        break;
      case 'uji_kuat':
        icon = Icons.fitness_center;
        gradient = const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
        final ujiResult = UjiKuatResult.fromMap(report.data['result']);
        hasPhotos = ujiResult.hasPhotos();
        photoCount = ujiResult.getPhotoCount();
        break;
      case 'konversi_beton':
        icon = Icons.transform;
        gradient = const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
        break;
      default:
        icon = Icons.description;
        gradient = const LinearGradient(colors: [Colors.grey, Colors.grey]);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showReportDetail(report),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      gradient: gradient, 
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.title, 
                          style: const TextStyle(fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF1E293B)), 
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(report.summary, 
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]), 
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, 
                              size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(_formatDate(report.date), 
                              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          if (hasPhotos) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt, 
                                      size: 10, color: Colors.purple[700]),
                                  const SizedBox(width: 3),
                                  Text('$photoCount', 
                                      style: TextStyle(fontSize: 10, 
                                          color: Colors.purple[700], 
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red[700], size: 20),
                          const SizedBox(width: 12),
                          const Text('Export PDF'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red[700], size: 20),
                          const SizedBox(width: 12),
                          const Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'pdf') {
                      _exportToPDF(report);
                    } else if (value == 'delete') {
                      _deleteReport(report.id);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDetail(UnifiedReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300], 
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.title, 
                                style: const TextStyle(fontSize: 20, 
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_formatDate(report.date), 
                                style: TextStyle(fontSize: 14, 
                                    color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.close), 
                          onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: _buildDetailContent(report),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(UnifiedReport report) {
    switch (report.type) {
      case 'sand_cone':
        return _buildSandConeDetail(SandConeTestResult.fromJson(report.data));
      case 'hammer_test':
        return _buildHammerTestDetail(HammerTestResult.fromMap(report.data));
      case 'uji_kuat':
        return _buildUjiKuatDetail(report.data);
      case 'konversi_beton':
        return _buildKonversiBetonDetail(KonversiResult.fromJson(report.data));
      default:
        return const Text('Detail tidak tersedia');
    }
  }
   Widget _buildSandConeDetail(SandConeTestResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        if (result.hasProjectInfo) ...[
          _buildSectionTitle('📋 INFORMASI PROYEK'),
          _buildDetailCard([
            if (result.kontraktor != null && result.kontraktor!.isNotEmpty)
              _buildDetailRow('Nama Kontraktor', result.kontraktor!, Icons.business),
            if (result.lokasiProyek != null && result.lokasiProyek!.isNotEmpty)
              _buildDetailRow('Lokasi Proyek', result.lokasiProyek!, Icons.location_on),
            if (result.jenisPekerjaan != null && result.jenisPekerjaan!.isNotEmpty)
              _buildDetailRow('Jenis Pekerjaan', result.jenisPekerjaan!, Icons.construction),
            if (result.tanggalPengujian != null)
              _buildDetailRow('Tanggal Pengujian', 
                  _formatDate(result.tanggalPengujian!), Icons.calendar_today),
          ]),
          const SizedBox(height: 16),
        ],
        
        _buildSectionTitle('📊 HASIL UTAMA'),
        _buildDetailCard([
          _buildDetailRow('Berat Isi Kering (Yd Lap)', 
              '${result.beratIsiTanahKering.toStringAsFixed(4)} g/cm³', 
              Icons.compress),
          _buildDetailRow('Derajat Kepadatan', 
              '${result.persentaseKepadatan.toStringAsFixed(2)}%', 
              Icons.timeline),
          _buildDetailRow('Status Kepadatan', result.statusKepadatan, Icons.check_circle,
              valueColor: result.persentaseKepadatan >= 95 ? Colors.green : Colors.orange),
          _buildDetailRow('Klasifikasi', 
              result.persentaseKepadatan >= 95 ? 'Baik' : 
              result.persentaseKepadatan >= 90 ? 'Sedang' : 'Kurang', 
              Icons.category),
          if (result.hasDokumentasiFoto)
            _buildDetailRow('Dokumentasi Foto', '${result.jumlahFoto} foto', 
                Icons.camera_alt),
        ]),
        
        const SizedBox(height: 16),
        
        
        if (result.hasDokumentasiFoto) ...[
          _buildSectionTitle('📸 DOKUMENTASI FOTO (${result.jumlahFoto})'),
          _buildPhotoGrid(result.photoPaths, 'Sand Cone Test'),
          const SizedBox(height: 16),
        ],
        
        _buildSectionTitle('🔬 SECTION I: KALIBRASI ALAT'),
        _buildDetailCard([
          _buildDetailRow('Berat Botol + Corong (W1)', 
              '${result.beratBotolCorong.toStringAsFixed(2)} gram', 
              Icons.view_in_ar),
          _buildDetailRow('Berat Botol + Corong + Air (W2)', 
              '${result.beratBotolCorongAir.toStringAsFixed(2)} gram', 
              Icons.water_drop),
          _buildDetailRow('Volume Botol (Vb)', 
              '${result.volumeBotolCorong.toStringAsFixed(4)} ml', 
              Icons.straighten),
          _buildDetailRow('Berat Botol + Corong + Pasir (W3)', 
              '${result.beratBotolCorongPasir.toStringAsFixed(2)} gram', 
              Icons.grass),
          _buildDetailRow('Berat Isi Pasir (Yρ)', 
              '${result.beratIsiPasir.toStringAsFixed(4)} g/ml', 
              Icons.calculate,
              valueColor: Colors.blue[700]),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📏 SECTION II: PENGUJIAN KEPADATAN'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A. BERAT PASIR DALAM CORONG',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, 
                      color: Colors.purple[900])),
              const Divider(height: 16),
              _buildDetailRow('W4 (Botol + Pasir + Corong)', 
                  '${result.beratBotolCorongA.toStringAsFixed(2)} gram', 
                  Icons.inventory_2),
              _buildDetailRow('W5 (Botol + Sisa Pasir + Corong)', 
                  '${result.beratBotolCorongSisaPasir.toStringAsFixed(2)} gram', 
                  Icons.inventory_2_outlined),
              _buildDetailRow('W6 (Berat Pasir Dalam Corong)', 
                  '${result.beratPasirDalamCorong.toStringAsFixed(4)} gram', 
                  Icons.analytics,
                  valueColor: Colors.purple[700]),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildDetailCard([
          _buildDetailRow('Berat Wadah (W7)', 
              '${result.beratWadah.toStringAsFixed(2)} gram', 
              Icons.inbox),
          _buildDetailRow('Berat Tanah + Wadah (W8)', 
              '${result.beratTanahWadah.toStringAsFixed(2)} gram', 
              Icons.scale),
          _buildDetailRow('Berat Tanah (W9)', 
              '${result.beratTanah.toStringAsFixed(4)} gram', 
              Icons.analytics_outlined),
          _buildDetailRow('W10 (Botol + Pasir + Corong)', 
              '${result.beratBotolCorongB.toStringAsFixed(2)} gram', 
              Icons.science),
          _buildDetailRow('W11 (Botol + Sisa Pasir + Corong)', 
              '${result.beratBotolCorongSisaPasirB.toStringAsFixed(2)} gram', 
              Icons.science_outlined),
          _buildDetailRow('Berat Pasir di Lubang (W13)', 
              '${result.beratPasirDalamLubang.toStringAsFixed(4)} gram', 
              Icons.grass,
              valueColor: Colors.green[700]),
          _buildDetailRow('Volume Lubang (V)', 
              '${result.vLubang.toStringAsFixed(4)} ml', 
              Icons.water_drop_outlined),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('💧 SECTION III: KADAR AIR & KEPADATAN'),
        _buildDetailCard([
          _buildDetailRow('Berat Isi Tanah Basah (Yd)', 
              '${result.beratIsiTanah.toStringAsFixed(4)} g/cm³', 
              Icons.compress),
          _buildDetailRow('Kadar Air (W)', 
              '${result.kadarAir.toStringAsFixed(2)}%', 
              Icons.water),
          _buildDetailRow('Berat Isi Tanah Kering Lab (Yd Lab)', 
              '${result.beratIsiPasirB.toStringAsFixed(4)} g/cm³', 
              Icons.science),
          _buildDetailRow('Berat Isi Tanah Kering Lapangan (Yd Lap)', 
              '${result.beratIsiTanahKering.toStringAsFixed(4)} g/cm³', 
              Icons.compress,
              valueColor: Colors.blue[900]),
        ]),
        
        const SizedBox(height: 16),
        
       
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                result.persentaseKepadatan >= 95 
                    ? Colors.green[50]! 
                    : Colors.orange[50]!,
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: result.persentaseKepadatan >= 95 
                  ? Colors.green[300]! 
                  : Colors.orange[300]!,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                result.persentaseKepadatan >= 95 
                    ? Icons.check_circle 
                    : Icons.warning,
                color: result.persentaseKepadatan >= 95 
                    ? Colors.green 
                    : Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                result.persentaseKepadatan >= 95 
                    ? 'MEMENUHI STANDAR' 
                    : result.persentaseKepadatan >= 90
                        ? 'PERLU PERHATIAN'
                        : 'TIDAK MEMENUHI STANDAR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: result.persentaseKepadatan >= 95 
                      ? Colors.green[900] 
                      : Colors.orange[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Derajat Kepadatan: ${result.persentaseKepadatan.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: result.persentaseKepadatan >= 95 
                      ? Colors.green 
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.persentaseKepadatan >= 95
                    ? 'Pemadatan telah mencapai standar yang disyaratkan (≥95%)'
                    : result.persentaseKepadatan >= 90
                        ? 'Pemadatan mendekati standar, perlu pemadatan tambahan'
                        : 'Pemadatan tidak memenuhi syarat, perlu pemadatan ulang',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📋 CATATAN STANDAR SNI 2828:2011'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text('Informasi Penting',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, 
                          color: Colors.blue[900])),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• Standar kepadatan minimum: 95% dari kepadatan laboratorium\n'
                '• Formula: Derajat = (Yd Lap / Yd Lab) × 100%\n'
                '• Metode: Sand Cone Test (Uji Kerucut Pasir)\n'
                '• Kadar air dinyatakan dalam persen (%)\n'
                '• Berat isi dalam gram per mililiter (g/ml atau g/cm³)',
                style: TextStyle(fontSize: 12, color: Colors.blue[900], height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHammerTestDetail(HammerTestResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('📍 INFORMASI TEST'),
        _buildDetailCard([
          _buildDetailRow('ID Test', result.testId, Icons.tag),
          _buildDetailRow('Lokasi Test', result.location, Icons.location_on),
          _buildDetailRow('Tanggal Test', _formatDate(result.testDate), Icons.calendar_today),
          if (result.testedBy.isNotEmpty)
            _buildDetailRow('Pekerja/Teknisi', result.testedBy, Icons.person),
          _buildDetailRow('Standar', result.standard, Icons.book),
          _buildDetailRow('Tipe Hammer', result.hammerType, Icons.build),
          _buildDetailRow('Posisi Pengujian', 
              '${result.position} - ${result.positionDescription}', 
              Icons.place),
          _buildDetailRow('Orientasi Pukulan', result.orientationDescription, Icons.rotate_90_degrees_ccw),
          _buildDetailRow('Umur Beton', '${result.age} hari', Icons.timer),
          if (result.hasDokumentasiFoto)
            _buildDetailRow('Dokumentasi Foto', '${result.jumlahFoto} foto', Icons.camera_alt),
        ]),
        
        const SizedBox(height: 16),
        
       
        if (result.hasDokumentasiFoto) ...[
          _buildSectionTitle('📸 DOKUMENTASI FOTO (${result.jumlahFoto})'),
          _buildPhotoGrid(result.photoPaths, 'Hammer Test'),
          const SizedBox(height: 16),
        ],
        
        _buildSectionTitle('📊 DATA PEMBACAAN (${result.reboundValues.length} data)'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.reboundValues.asMap().entries.map((entry) {
                  return Container(
                    width: 65,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Column(
                      children: [
                        Text('R${entry.key + 1}',
                            style: TextStyle(fontSize: 10, color: Colors.blue[900],
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${entry.value}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                color: Colors.blue[900])),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📈 ANALISIS STATISTIK'),
        _buildDetailCard([
          _buildDetailRow('Jumlah Pembacaan', '${result.reboundValues.length} data', Icons.numbers),
          _buildDetailRow('Rata-rata (R)', result.rValue.toStringAsFixed(2), Icons.analytics),
          _buildDetailRow('Standar Deviasi (SD)', result.standardDeviation.toStringAsFixed(2), Icons.show_chart),
          _buildDetailRow('Koefisien Variasi (CoV)', 
              '${result.coefficientOfVariation.toStringAsFixed(2)}%', 
              Icons.percent),
          _buildDetailRow('Status Kualitas Data', result.qualityStatus, Icons.verified,
              valueColor: result.coefficientOfVariation < 5 ? Colors.green : Colors.orange),
        ]),
        
        const SizedBox(height: 16),
        
        if (result.calibrationFactor != 1.0) ...[
          _buildSectionTitle('⚙️ KOREKSI KALIBRASI ALAT'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[300]!, width: 2),
            ),
            child: Column(
              children: [
                _buildDetailRow('R Sebelum Kalibrasi', result.rValue.toStringAsFixed(2), Icons.timeline),
                const Divider(height: 16),
                _buildDetailRow('Faktor Kalibrasi', result.calibrationFactor.toStringAsFixed(8), Icons.tune),
                const Divider(height: 16),
                _buildDetailRow('R Setelah Kalibrasi', 
                  (result.rValue * result.calibrationFactor).toStringAsFixed(2), 
                  Icons.done,
                  valueColor: Colors.purple[900],
                  valueBold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        _buildSectionTitle('💪 HASIL KUAT TEKAN'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green[50]!, Colors.green[100]!]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[300]!, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.speed, size: 32, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  const Text('Kuat Tekan Estimasi', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text('${result.compressiveStrengthMPa.toStringAsFixed(2)} MPa',
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, 
                      color: Colors.green[900])),
              const SizedBox(height: 8),
              Text('≈ ${result.compressiveStrengthKgCm2.toStringAsFixed(2)} kg/cm²',
                  style: TextStyle(fontSize: 16, color: Colors.green[800])),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Formula Posisi ${result.position}:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('fc = a×R² + b×R + c',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 13, 
                            color: Colors.green[900])),
                    const SizedBox(height: 4),
                    Text('R = ${(result.rValue * result.calibrationFactor).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📋 CATATAN PENTING'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                  const SizedBox(width: 8),
                  Text('Informasi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, 
                          color: Colors.amber[900])),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• Hasil adalah ESTIMASI berdasarkan korelasi empiris\n'
                '• Sesuai SNI 03-4430-1997\n'
                '• Menggunakan rumus korelasi Posisi ${result.position}\n'
                '• Untuk hasil definitif, lakukan uji tekan silinder\n'
                '• Konversi: 1 MPa ≈ 10.197 kg/cm²\n'
                '• Faktor yang mempengaruhi: kelembaban, carbonasi, tekstur permukaan',
                style: TextStyle(fontSize: 12, color: Colors.amber[900], height: 1.6),
              ),
            ],
          ),
        ),
        
        if (result.age < 28) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[800], size: 20),
                    const SizedBox(width: 8),
                    Text('Rekomendasi',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, 
                            color: Colors.orange[900])),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Beton berumur ${result.age} hari (< 28 hari)\n'
                  'Disarankan testing ulang setelah 28 hari untuk hasil yang lebih akurat',
                  style: TextStyle(fontSize: 12, color: Colors.orange[900], height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
   Widget _buildUjiKuatDetail(Map<String, dynamic> data) {
    final result = UjiKuatResult.fromMap(data['result']);
    final testData = data['data'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('📊 HASIL UTAMA'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                result.statusKualitas.contains('MEMENUHI') 
                    ? Colors.green[50]! 
                    : Colors.orange[50]!,
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: result.statusKualitas.contains('MEMENUHI') 
                  ? Colors.green[300]! 
                  : Colors.orange[300]!,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                result.statusKualitas.contains('MEMENUHI') 
                    ? Icons.check_circle 
                    : Icons.warning,
                size: 48,
                color: result.statusKualitas.contains('MEMENUHI') 
                    ? Colors.green 
                    : Colors.orange,
              ),
              const SizedBox(height: 12),
              Text(
                result.statusKualitas,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: result.statusKualitas.contains('MEMENUHI') 
                      ? Colors.green[900] 
                      : Colors.orange[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text('Kuat Tekan (28 hari)',
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 8),
              Text('${result.kuatTekan.toStringAsFixed(2)} MPa',
                  style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold,
                      color: result.statusKualitas.contains('MEMENUHI') 
                          ? Colors.green[900] 
                          : Colors.orange[900])),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        
        if (result.pekerjaan != null || result.lokasi != null) ...[
          _buildSectionTitle('📍 INFORMASI PROYEK'),
          _buildDetailCard([
            if (result.pekerjaan != null)
              _buildDetailRow('Nama Pekerjaan', result.pekerjaan!, Icons.work),
            if (result.lokasi != null)
              _buildDetailRow('Lokasi Proyek', result.lokasi!, Icons.location_on),
          ]),
          const SizedBox(height: 16),
        ],
        
        
        if (result.hasPhotos()) ...[
          _buildSectionTitle('📸 DOKUMENTASI FOTO (${result.getPhotoCount()})'),
          _buildPhotoGrid(result.photoPaths!, 'Uji Kuat Tekan'),
          const SizedBox(height: 16),
        ],
        
        _buildSectionTitle('📅 DATA PENGUJIAN'),
        _buildDetailCard([
          _buildDetailRow('Tanggal Pembuatan (Casting)', 
              _formatDate(result.tanggalPembuatan), 
              Icons.calendar_today),
          _buildDetailRow('Tanggal Pengujian (Testing)', 
              _formatDate(result.tanggalPengujian), 
              Icons.science),
          _buildDetailRow('Umur Beton Saat Uji', 
              '${result.umurBeton} hari', 
              Icons.access_time),
          _buildDetailRow('Standar Acuan', result.standarAcuan, Icons.book),
          _buildDetailRow('Mutu Rencana', testData['mutuBeton'], Icons.architecture),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('🔬 DIMENSI BENDA UJI'),
        _buildDetailCard([
          if (result.standarAcuan == 'SNI' && result.sisiKubus != null) ...[
            _buildDetailRow('Bentuk', 'Kubus', Icons.view_in_ar),
            _buildDetailRow('Dimensi', 
                '${(result.panjangKubus ?? result.sisiKubus!).toStringAsFixed(0)} × '
                '${(result.lebarKubus ?? result.sisiKubus!).toStringAsFixed(0)} × '
                '${(result.tinggiKubus ?? result.sisiKubus!).toStringAsFixed(0)} mm', 
                Icons.straighten),
            _buildDetailRow('Luas Permukaan', 
                '${result.luasPermukaan.toStringAsFixed(2)} cm²', 
                Icons.crop_square),
          ] else if (result.diameter != null) ...[
            _buildDetailRow('Bentuk', 'Silinder', Icons.view_in_ar),
            _buildDetailRow('Diameter', 
                '${result.diameter!.toStringAsFixed(0)} mm (Ø${(result.diameter! / 10).toStringAsFixed(0)} cm)', 
                Icons.straighten),
            _buildDetailRow('Tinggi', 
                '${(result.diameter! * 2).toStringAsFixed(0)} mm (rasio 2:1)', 
                Icons.height),
            _buildDetailRow('Luas Permukaan', 
                '${result.luasPermukaan.toStringAsFixed(2)} mm²', 
                Icons.crop_square),
          ],
          if (result.beratBendaUji != null)
            _buildDetailRow('Berat Benda Uji', 
                '${result.beratBendaUji!.toStringAsFixed(2)} kg', 
                Icons.monitor_weight),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('💪 HASIL PEMBEBANAN'),
        _buildDetailCard([
          _buildDetailRow(
            result.standarAcuan == 'SNI' ? 'Beban Maksimal' : 'Gaya Tekan',
            result.standarAcuan == 'SNI' 
                ? '${result.bebanMaksimal.toStringAsFixed(2)} ${result.satuanBebanInput ?? "kg/cm²"}'
                : '${result.bebanMaksimal.toStringAsFixed(2)} kN',
            Icons.fitness_center,
          ),
          if (result.standarAcuan == 'SNI' && result.kuatTekanKubus != null)
            _buildDetailRow('Kuat Tekan (Umur Uji)', 
                '${result.kuatTekanKubus!.toStringAsFixed(2)} kg/cm²', 
                Icons.speed),
          if (result.standarAcuan != 'SNI' && result.kuatTekanSilinder != null)
            _buildDetailRow('Kuat Tekan (Umur Uji)', 
                '${result.kuatTekanSilinder!.toStringAsFixed(2)} MPa', 
                Icons.speed),
          if (result.standarAcuan != 'SNI' && result.kuatTekanEkivalenKgCm2 != null)
            _buildDetailRow('Setara Kubus (info)', 
                '${result.kuatTekanEkivalenKgCm2!.toStringAsFixed(2)} kg/cm²', 
                Icons.compare_arrows),
          if (result.umurBeton < 28)
            _buildDetailRow('Faktor Konversi ke 28 Hari', 
                'Menggunakan Tabel PBI', 
                Icons.functions),
          _buildDetailRow('Kuat Tekan Estimasi (28 Hari)', 
              '${result.kuatTekan.toStringAsFixed(2)} MPa', 
              Icons.analytics,
              valueColor: Colors.blue[900],
              valueBold: true),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📝 KETERANGAN DETAIL'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            result.keterangan,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📋 CATATAN STANDAR'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text('Informasi Standar',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, 
                          color: Colors.blue[900])),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result.standarAcuan == 'SNI'
                    ? '• Standar: SNI 03-2847-2002 (Kubus 15×15×15 cm)\n'
                      '• Beton memenuhi syarat jika fc ≥ K yang disyaratkan\n'
                      '• Input beban dalam kg/cm²\n'
                      '• Formula: fc = Beban / Luas permukaan\n'
                      '• Konversi: 1 MPa = 10.197 kg/cm²'
                    : result.standarAcuan == 'BINA MARGA'
                        ? '• Standar: Spesifikasi Bina Marga 2018 Rev 2\n'
                          '• Kriteria individu: fc ≥ 0.85 × fc\'\n'
                          '• Kriteria rata-rata: fc ≥ 1.15 × fc\'\n'
                          '• Input gaya dalam kN (kilonewton)\n'
                          '• Diameter standar: 100 mm atau 150 mm'
                        : '• Standar: ASTM C39 (Silinder)\n'
                          '• Concrete is acceptable if fc ≥ specified fc\'\n'
                          '• Input load in kN (kilonewton)\n'
                          '• Standard diameter: 100 mm or 150 mm',
                style: TextStyle(fontSize: 12, color: Colors.blue[900], height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKonversiBetonDetail(KonversiResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('📊 HASIL KONVERSI'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.orange[50]!, Colors.orange[100]!]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[300]!, width: 2),
          ),
          child: Column(
            children: [
              Icon(Icons.assessment, size: 48, color: Colors.orange[700]),
              const SizedBox(height: 12),
              const Text('Kuat Tekan Estimasi 28 Hari',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, 
                      color: Colors.black54)),
              const SizedBox(height: 8),
              Text('${result.hasilKonversi.toStringAsFixed(2)} ${result.satuanDisplay}',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, 
                      color: Colors.orange[900])),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  'Perhitungan: ${result.kuatTekanBeton.toStringAsFixed(2)} ÷ ${result.faktorKonversi.toStringAsFixed(3)}',
                  style: TextStyle(fontSize: 12, color: Colors.orange[900], 
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📋 DATA INPUT'),
        _buildDetailCard([
          _buildDetailRow('Jenis Benda Uji', result.jenisBendaUjiDisplay, Icons.category),
          _buildDetailRow('Satuan', result.satuanDisplay, Icons.straighten),
          _buildDetailRow('Umur Beton Saat Uji', 
              '${result.umurBeton.toStringAsFixed(0)} Hari', 
              Icons.calendar_today),
          _buildDetailRow('Kuat Tekan Hasil Uji', 
              '${result.kuatTekanBeton.toStringAsFixed(2)} ${result.satuanDisplay}', 
              Icons.science),
          _buildDetailRow('Karakteristik Beton', result.karakteristik, Icons.info),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('🔢 FAKTOR KONVERSI'),
        _buildDetailCard([
          _buildDetailRow('Faktor K (Tabel PBI)', 
              result.faktorKonversi.toStringAsFixed(4), 
              Icons.functions),
          _buildDetailRow('Referensi', 'Peraturan Beton Indonesia (PBI)', Icons.book),
          _buildDetailRow('Metode', 
              result.umurBeton % 7 == 0 || result.umurBeton == 3 || result.umurBeton == 14 || result.umurBeton == 21 || result.umurBeton >= 28
                  ? 'Nilai Tabel Langsung'
                  : 'Interpolasi Linear', 
              Icons.analytics),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📐 FORMULA KONVERSI'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate, color: Colors.purple[700], size: 20),
                  const SizedBox(width: 8),
                  Text('Rumus Konversi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, 
                          color: Colors.purple[900])),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'fc\'₂₈ = fc\'ᵤ / Kᵤ',
                style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'monospace',
                    color: Colors.purple[900]),
              ),
              const SizedBox(height: 8),
              Text(
                'Dimana:\n'
                'fc\'₂₈ = Kuat tekan umur 28 hari\n'
                'fc\'ᵤ = Kuat tekan umur uji (${result.umurBeton.toStringAsFixed(0)} hari)\n'
                'Kᵤ = Faktor konversi (${result.faktorKonversi.toStringAsFixed(4)})',
                style: TextStyle(fontSize: 12, color: Colors.purple[800], height: 1.6),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Contoh Perhitungan:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, 
                    color: Colors.purple[900]),
              ),
              const SizedBox(height: 6),
              Text(
                '${result.kuatTekanBeton.toStringAsFixed(2)} ${result.satuanDisplay} ÷ ${result.faktorKonversi.toStringAsFixed(4)} = ${result.hasilKonversi.toStringAsFixed(2)} ${result.satuanDisplay}',
                style: TextStyle(
                    fontSize: 13, 
                    fontFamily: 'monospace',
                    color: Colors.purple[800]),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📊 TABEL FAKTOR KONVERSI PBI'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Faktor Konversi (Semen Portland Biasa):',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, 
                      color: Colors.grey[900])),
              const SizedBox(height: 12),
              Table(
                border: TableBorder.all(color: Colors.grey[400]!, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Umur Beton',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Faktor K',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  _buildTableRow('3 hari', '0.40'),
                  _buildTableRow('7 hari', '0.65'),
                  _buildTableRow('14 hari', '0.88'),
                  _buildTableRow('21 hari', '0.95'),
                  _buildTableRow('28 hari', '1.00'),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('📋 CATATAN PENTING'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text('Informasi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, 
                          color: Colors.blue[900])),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• Konversi menggunakan tabel faktor PBI (Peraturan Beton Indonesia)\n'
                '• Hasil merupakan estimasi kuat tekan pada umur 28 hari\n'
                '• Jenis benda uji: ${result.jenisBendaUjiDisplay}\n'
                '• Untuk umur diantara nilai tabel dilakukan interpolasi linear\n'
                '• Faktor untuk Semen Portland Pozzolan dapat berbeda\n'
                '• Disarankan dilakukan pengujian aktual pada umur 28 hari untuk verifikasi',
                style: TextStyle(fontSize: 12, color: Colors.blue[900], height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String umur, String faktor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(umur, style: const TextStyle(fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(faktor,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
   Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(title, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, 
              color: Color(0xFF1E293B))),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: children.map((child) {
          final index = children.indexOf(child);
          return Column(
            children: [
              child,
              if (index < children.length - 1) const Divider(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, 
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, 
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid(List<String> photoPaths, String testType) {
    if (photoPaths.isEmpty) return const SizedBox.shrink();
    
    int crossAxisCount;
    double childAspectRatio;
    
    if (photoPaths.length == 1) {
      crossAxisCount = 1;
      childAspectRatio = 16 / 9;
    } else if (photoPaths.length == 2) {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
    } else if (photoPaths.length <= 4) {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
    } else {
      crossAxisCount = 3;
      childAspectRatio = 1.0;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, size: 16, color: Colors.purple[700]),
              ),
              const SizedBox(width: 8),
              Text(
                'Tap foto untuk memperbesar',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: photoPaths.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _viewPhotoFullscreen(photoPaths[index], index + 1, 
                    photoPaths.length),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(photoPaths[index]),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, color: Colors.grey[600], 
                                    size: 32),
                                const SizedBox(height: 4),
                                Text(
                                  'Foto ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12)),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.zoom_in, 
                                color: Colors.white.withOpacity(0.8), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _viewPhotoFullscreen(String photoPath, int photoIndex, int totalPhotos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('Foto $photoIndex dari $totalPhotos'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Info Foto'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Foto: $photoIndex dari $totalPhotos'),
                          const SizedBox(height: 8),
                          Text(
                            'Path: $photoPath',
                            style: const TextStyle(fontSize: 10, 
                                color: Colors.grey),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                File(photoPath),
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, color: Colors.white, 
                          size: 64),
                      const SizedBox(height: 16),
                      const Text('Gagal memuat foto', 
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Path: $photoPath',
                          style: const TextStyle(color: Colors.white70, 
                              fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

