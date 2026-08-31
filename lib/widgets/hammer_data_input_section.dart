import 'package:flutter/material.dart';

class HammerDataInputSection extends StatefulWidget {
  final List<int> reboundValues;
  final Function(int) onAddValue;
  final Function(int) onRemoveValue;
  final Function() onClearAll;
  final String hammerType;

  const HammerDataInputSection({
    super.key,
    required this.reboundValues,
    required this.onAddValue,
    required this.onRemoveValue,
    required this.onClearAll,
    required this.hammerType,
  });

  @override
  State<HammerDataInputSection> createState() => _HammerDataInputSectionState();
}

class _HammerDataInputSectionState extends State<HammerDataInputSection> {
  final TextEditingController _inputController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addValue() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final value = int.tryParse(text);
    if (value == null) {
      setState(() {
        _errorMessage = 'Masukkan angka yang valid';
      });
      return;
    }

    
    Map<String, Map<String, int>> ranges = {
      'N-Type': {'min': 10, 'max': 70},
    };

    int min = ranges[widget.hammerType]?['min'] ?? 0;
    int max = ranges[widget.hammerType]?['max'] ?? 100;

    if (value < min || value > max) {
      setState(() {
        _errorMessage = 'Nilai harus antara $min - $max';
      });
      return;
    }

    widget.onAddValue(value);
    _inputController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasMinimumReadings = widget.reboundValues.length >= 10;
    final avgValue = widget.reboundValues.isEmpty
        ? 0.0
        : widget.reboundValues.reduce((a, b) => a + b) /
            widget.reboundValues.length;

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
                Icon(Icons.edit_note, color: Colors.green[700], size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Input Data Pembacaan (R)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.reboundValues.isNotEmpty)
                  IconButton(
                    onPressed: widget.onClearAll,
                    icon: const Icon(Icons.delete_sweep, size: 22),
                    color: Colors.red,
                    tooltip: 'Hapus Semua',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      labelText: 'Nilai Rebound',
                      labelStyle: const TextStyle(fontSize: 13),
                      hintText: 'Masukkan nilai (10-70)',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(Icons.pin, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: _errorMessage,
                      errorStyle: const TextStyle(fontSize: 11),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _addValue(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addValue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.add, size: 22),
                ),
              ],
            ),

            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: widget.reboundValues.length / 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hasMinimumReadings ? Colors.green : Colors.orange,
                    ),
                    minHeight: 7,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.reboundValues.length}/12',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasMinimumReadings ? Colors.green : Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            if (!hasMinimumReadings) ...[
              const SizedBox(height: 6),
              Text(
                '12 pembacaan diperlukan',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

           
            if (widget.reboundValues.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total',
                      widget.reboundValues.length.toString(),
                      Icons.numbers,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Rata-rata',
                      avgValue.toStringAsFixed(1),
                      Icons.analytics,
                      Colors.green,
                    ),
                    _buildStatItem(
                      'Min',
                      widget.reboundValues
                          .reduce((a, b) => a < b ? a : b)
                          .toString(),
                      Icons.arrow_downward,
                      Colors.orange,
                    ),
                    _buildStatItem(
                      'Max',
                      widget.reboundValues
                          .reduce((a, b) => a > b ? a : b)
                          .toString(),
                      Icons.arrow_upward,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ],

           
            if (widget.reboundValues.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Data Pembacaan (${widget.reboundValues.length} data):',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.reboundValues.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 16,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          widget.reboundValues[index].toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 20),
                          onPressed: () => widget.onRemoveValue(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

           
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates,
                      color: Colors.amber[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lakukan pembacaan 12 titik dengan jarak 20-30mm antar titik.',
                      style: TextStyle(
                        color: Colors.amber[900],
                        fontSize: 11,
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

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}