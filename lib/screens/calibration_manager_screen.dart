import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/sand_cone_calibration_templates.dart';

/// Layar untuk mengelola data kalibrasi alat Sand Cone:
/// edit nilai W1-W5 + tanggal, lihat riwayat versi, ekspor dan impor.
class CalibrationManagerScreen extends StatefulWidget {
  const CalibrationManagerScreen({Key? key}) : super(key: key);

  @override
  State<CalibrationManagerScreen> createState() =>
      _CalibrationManagerScreenState();
}

class _CalibrationManagerScreenState extends State<CalibrationManagerScreen> {
  Map<String, List<CalibrationVersion>> _store = {};
  bool _loading = true;

  static const Color _purple = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = await CalibrationTemplateService.loadStore();
    if (!mounted) return;
    setState(() {
      _store = store;
      _loading = false;
    });
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red[700] : Colors.green[700],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Ekspor
  // ---------------------------------------------------------------------------

  Future<void> _export() async {
    try {
      final json = await CalibrationTemplateService.exportToJson();
      final dir = await getTemporaryDirectory();
      final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final file = File('${dir.path}/kalibrasi_sandcone_$stamp.json');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Data kalibrasi alat Sand Cone (SipiLAB)',
      );
    } catch (e) {
      _snack('Gagal ekspor: $e', error: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Impor
  // ---------------------------------------------------------------------------

  Future<void> _import() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;

      final f = picked.files.single;
      List<int>? bytes = f.bytes;
      if (bytes == null && f.path != null) {
        bytes = await File(f.path!).readAsBytes();
      }
      if (bytes == null) {
        throw const FormatException('Berkas tidak dapat dibaca');
      }

      final content = utf8.decode(bytes, allowMalformed: true);
      final preview = await CalibrationTemplateService.parseImport(content);
      if (!mounted) return;

      final ok = await _confirmImport(preview);
      if (ok != true) return;

      final n = await CalibrationTemplateService.applyImport(preview);
      await _load();
      _snack(n == 0
          ? 'Tidak ada perubahan, data sama dengan yang aktif'
          : 'Impor berhasil: $n alat diperbarui');
    } on FormatException catch (e) {
      _snack(e.message, error: true);
    } catch (e) {
      _snack('Gagal impor: $e', error: true);
    }
  }

  String _fmtDate(DateTime? d) =>
      d == null ? 'tanpa tanggal' : formatTanggalKalibrasi(d);

  Future<bool?> _confirmImport(CalibrationImportPreview preview) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Impor Kalibrasi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in preview.items) ...[
                Text(item.deviceName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                if (item.isSame)
                  const Text('Tidak ada perubahan (sama dengan yang aktif)',
                      style: TextStyle(fontSize: 12, color: Colors.grey))
                else ...[
                  Text(
                    'Tanggal: ${_fmtDate(item.current.tanggalKalibrasi)}'
                    ' → ${_fmtDate(item.incoming.tanggalKalibrasi)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Yp: ${item.current.beratIsiPasir.toStringAsFixed(4)}'
                    ' → ${item.incoming.beratIsiPasir.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (item.isOlder)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'Peringatan: tanggal kalibrasi pada berkas lebih lama dari yang aktif.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                ],
                const SizedBox(height: 10),
              ],
              if (preview.hasChanges)
                const Text(
                  'Nilai yang aktif sekarang akan disimpan di riwayat.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          if (preview.hasChanges)
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Terapkan'),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Edit
  // ---------------------------------------------------------------------------

  Future<void> _edit(String id) async {
    final list = _store[id];
    if (list == null || list.isEmpty) return;

    final result = await showDialog<CalibrationVersion>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EditCalibrationDialog(
        title: 'Edit ${CalibrationTemplateService.deviceName(id)}',
        initial: list.first,
      ),
    );
    if (result == null) return;

    final error = await CalibrationTemplateService.saveCalibration(id, result);
    if (error != null) {
      _snack(error, error: true);
      return;
    }
    await _load();
    _snack('Kalibrasi ${CalibrationTemplateService.deviceName(id)} disimpan');
  }

  // ---------------------------------------------------------------------------
  // Riwayat
  // ---------------------------------------------------------------------------

  void _showHistory(String id) {
    final list = _store[id] ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat ${CalibrationTemplateService.deviceName(id)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Maksimal ${CalibrationTemplateService.maxVersionsPerDevice} versi terakhir',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx2, i) {
                    final v = list[i];
                    final isActive = i == 0;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Kalibrasi ${_fmtDate(v.tanggalKalibrasi)}'
                        '${isActive ? '  (AKTIF)' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Yp ${v.beratIsiPasir.toStringAsFixed(4)}'
                        '  •  Vb ${v.volumeBotol.toStringAsFixed(2)}'
                        '  •  W6 ${v.beratPasirDalamCorong.toStringAsFixed(2)}\n'
                        'W1 ${v.w1}  W2 ${v.w2}  W3 ${v.w3}  W4 ${v.w4}  W5 ${v.w5}\n'
                        'Disimpan ${DateFormat('dd/MM/yyyy HH:mm').format(v.savedAt)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      isThreeLine: true,
                      trailing: isActive
                          ? null
                          : TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await _restore(id, v);
                              },
                              child: const Text('Pulihkan'),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restore(String id, CalibrationVersion v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pulihkan versi ini?'),
        content: Text(
          'Kalibrasi ${_fmtDate(v.tanggalKalibrasi)} akan dijadikan versi aktif '
          'untuk ${CalibrationTemplateService.deviceName(id)}. '
          'Versi yang aktif sekarang tetap ada di riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final error = await CalibrationTemplateService.restoreVersion(id, v);
    if (error != null) {
      _snack(error, error: true);
      return;
    }
    await _load();
    _snack('Versi dipulihkan');
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Kelola Kalibrasi Sand Cone'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Impor dari berkas',
            icon: const Icon(Icons.file_download_rounded),
            onPressed: _import,
          ),
          IconButton(
            tooltip: 'Ekspor / bagikan',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _export,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Nilai kalibrasi disimpan di perangkat ini. Gunakan Ekspor '
                    '(ikon bagikan) untuk mengirim ke rekan, dan Impor untuk '
                    'menerima berkas dari rekan. Versi sebelumnya tetap '
                    'tersimpan di Riwayat.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5B21B6)),
                  ),
                ),
                const SizedBox(height: 12),
                for (final id in CalibrationTemplateService.deviceIds)
                  _buildDeviceCard(id),
              ],
            ),
    );
  }

  Widget _buildDeviceCard(String id) {
    final list = _store[id] ?? [];
    if (list.isEmpty) return const SizedBox.shrink();
    final v = list.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CalibrationTemplateService.deviceName(id),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            CalibrationTemplateService.deviceDescription(id),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Kalibrasi: ${_fmtDate(v.tanggalKalibrasi)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _valueRow('W1', v.w1, 'W2', v.w2),
          _valueRow('W3', v.w3, 'W4', v.w4),
          _valueRow('W5', v.w5, '', null),
          const Divider(height: 18),
          Text(
            'Vb ${v.volumeBotol.toStringAsFixed(2)} ml   •   '
            'Yp ${v.beratIsiPasir.toStringAsFixed(4)} gr/ml   •   '
            'W6 ${v.beratPasirDalamCorong.toStringAsFixed(2)} g',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B21A8)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _edit(id),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => _showHistory(id),
                icon: const Icon(Icons.history_rounded, size: 18),
                label: Text('Riwayat (${list.length})'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueRow(String l1, double v1, String l2, double? v2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text('$l1 = ${v1.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ),
          Expanded(
            child: Text(v2 == null ? '' : '$l2 = ${v2.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Dialog edit kalibrasi
// =============================================================================

class _EditCalibrationDialog extends StatefulWidget {
  final String title;
  final CalibrationVersion initial;

  const _EditCalibrationDialog({
    required this.title,
    required this.initial,
  });

  @override
  State<_EditCalibrationDialog> createState() => _EditCalibrationDialogState();
}

class _EditCalibrationDialogState extends State<_EditCalibrationDialog> {
  late final TextEditingController _w1;
  late final TextEditingController _w2;
  late final TextEditingController _w3;
  late final TextEditingController _w4;
  late final TextEditingController _w5;
  DateTime? _date;
  bool _w4SameAsW3 = true;
  bool _confirmedSameDate = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _w1 = TextEditingController(text: v.w1.toStringAsFixed(2));
    _w2 = TextEditingController(text: v.w2.toStringAsFixed(2));
    _w3 = TextEditingController(text: v.w3.toStringAsFixed(2));
    _w4 = TextEditingController(text: v.w4.toStringAsFixed(2));
    _w5 = TextEditingController(text: v.w5.toStringAsFixed(2));
    _date = v.tanggalKalibrasi;
    _w4SameAsW3 = v.w3 == v.w4;
    for (final c in [_w1, _w2, _w3, _w4, _w5]) {
      c.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [_w1, _w2, _w3, _w4, _w5]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  void _onChanged() {
    if (_w4SameAsW3 && _w4.text != _w3.text) {
      _w4.text = _w3.text;
    }
    setState(() {
      _error = null;
      _confirmedSameDate = false;
    });
  }

  CalibrationVersion? _buildVersion() {
    final w1 = _parse(_w1.text);
    final w2 = _parse(_w2.text);
    final w3 = _parse(_w3.text);
    final w4 = _parse(_w4.text);
    final w5 = _parse(_w5.text);
    if (w1 == null || w2 == null || w3 == null || w4 == null || w5 == null) {
      return null;
    }
    return CalibrationVersion(
      w1: w1,
      w2: w2,
      w3: w3,
      w4: w4,
      w5: w5,
      tanggalKalibrasi: _date,
      savedAt: DateTime.now(),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _confirmedSameDate = false;
      });
    }
  }

  void _submit() {
    final v = _buildVersion();
    if (v == null) {
      setState(() => _error = 'Semua nilai W1-W5 harus diisi dengan angka');
      return;
    }
    if (_date == null) {
      setState(() => _error = 'Tanggal kalibrasi harus diisi');
      return;
    }
    final err = v.validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }

    // Nilai berubah tetapi tanggal masih sama: minta konfirmasi sekali.
    final init = widget.initial;
    final valuesChanged = v.w1 != init.w1 ||
        v.w2 != init.w2 ||
        v.w3 != init.w3 ||
        v.w4 != init.w4 ||
        v.w5 != init.w5;
    final d0 = init.tanggalKalibrasi;
    final sameDate = d0 != null &&
        d0.year == _date!.year &&
        d0.month == _date!.month &&
        d0.day == _date!.day;
    if (valuesChanged && sameDate && !_confirmedSameDate) {
      setState(() {
        _confirmedSameDate = true;
        _error = 'Nilai berubah tetapi tanggal kalibrasi masih sama dengan '
            'sebelumnya. Ubah tanggal bila ini kalibrasi baru, atau tekan '
            'Simpan sekali lagi untuk tetap menyimpan.';
      });
      return;
    }
    Navigator.pop(context, v);
  }

  Widget _field(TextEditingController c, String label, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'gram',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _buildVersion();

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text(
                _date == null
                    ? 'Pilih tanggal kalibrasi'
                    : 'Tanggal kalibrasi: ${formatTanggalKalibrasi(_date!)}',
              ),
            ),
            const SizedBox(height: 12),
            _field(_w1, 'W1  Berat Botol + Corong'),
            _field(_w2, 'W2  Berat Botol Penuh Air + Corong'),
            _field(_w3, 'W3  Berat Botol Penuh Pasir + Corong'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('W4 sama dengan W3',
                  style: TextStyle(fontSize: 13)),
              value: _w4SameAsW3,
              onChanged: (val) {
                setState(() => _w4SameAsW3 = val);
                if (val) _w4.text = _w3.text;
              },
            ),
            _field(_w4, 'W4  Berat Botol + Pasir + Corong',
                enabled: !_w4SameAsW3),
            _field(_w5, 'W5  Berat Botol + Sisa Pasir + Corong'),
            if (preview != null && preview.validate() == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Vb = ${preview.volumeBotol.toStringAsFixed(2)} ml\n'
                  'Yp = ${preview.beratIsiPasir.toStringAsFixed(4)} gr/ml\n'
                  'W6 = ${preview.beratPasirDalamCorong.toStringAsFixed(2)} gram',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B21A8),
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
