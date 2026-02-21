import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/batch_provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_batch.dart';

/// Parti/Batch Yönetimi Ekranı - Ürün detayında tab olarak
class BatchManagementTab extends StatelessWidget {
  final Product product;

  const BatchManagementTab({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final batchProvider = Provider.of<BatchProvider>(context);
    final batches = batchProvider.getBatchesByProductId(product.id);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Özet Kart
        _buildSummaryCard(context, batchProvider, batches, theme),
        
        const SizedBox(height: 16),

        // Yeni Parti Ekle Butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddBatchDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Parti Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Parti Listesi
        Expanded(
          child: batches.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    return _BatchCard(
                      batch: batches[index],
                      product: product,
                      onEdit: () => _showEditBatchDialog(context, batches[index]),
                      onDelete: () => _showDeleteDialog(context, batches[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    BatchProvider batchProvider,
    List<ProductBatch> batches,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final totalQuantity = batchProvider.getTotalQuantity(product.id);
    final earliestBatch = batchProvider.getEarliestBatch(product.id);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.inventory_2,
              label: 'Toplam Adet',
              value: totalQuantity.toString(),
              color: colorScheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.category,
              label: 'Parti Sayısı',
              value: batches.length.toString(),
              color: colorScheme.secondary,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.calendar_today,
              label: 'En Yakın SKT',
              value: earliestBatch == null
                  ? '-'
                  : DateFormat('dd.MM.yy').format(earliestBatch.expiryDate),
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz Parti Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı SKT tarihlerinde stok eklemek için\n"Yeni Parti Ekle" butonuna tıklayın',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddBatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _BatchDialog(
        productId: product.id,
        productName: product.name,
      ),
    );
  }

  void _showEditBatchDialog(BuildContext context, ProductBatch batch) {
    showDialog(
      context: context,
      builder: (context) => _BatchDialog(
        productId: product.id,
        productName: product.name,
        batch: batch,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductBatch batch) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parti Sil'),
        content: Text(
          'SKT: ${dateFormat.format(batch.expiryDate)}\n'
          'Adet: ${batch.quantity}\n\n'
          'Bu partiyi silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BatchProvider>().deleteBatch(batch.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parti silindi'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

// === SUMMARY ITEM === //
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// === BATCH CARD === //
class _BatchCard extends StatelessWidget {
  final ProductBatch batch;
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BatchCard({
    required this.batch,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    // Risk hesaplama
    final daysUntilExpiry = batch.expiryDate.difference(DateTime.now()).inDays;
    Color riskColor;
    String riskLabel;
    
    if (daysUntilExpiry < 0) {
      riskColor = Colors.red;
      riskLabel = 'Süresi Geçti';
    } else if (daysUntilExpiry <= 7) {
      riskColor = Colors.orange;
      riskLabel = '$daysUntilExpiry gün kaldı';
    } else if (daysUntilExpiry <= 30) {
      riskColor = Colors.blue;
      riskLabel = '$daysUntilExpiry gün kaldı';
    } else {
      riskColor = Colors.green;
      riskLabel = '$daysUntilExpiry gün kaldı';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // SKT
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Son Kullanma Tarihi',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: riskColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(batch.expiryDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Adet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adet',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        batch.quantity.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Risk Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: riskColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: riskColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    riskLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: riskColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Not (varsa)
            if (batch.notes != null && batch.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        batch.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Düzenle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Sil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// === BATCH DIALOG (Ekle/Düzenle) === //
class _BatchDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final ProductBatch? batch; // null ise yeni ekleme

  const _BatchDialog({
    required this.productId,
    required this.productName,
    this.batch,
  });

  @override
  State<_BatchDialog> createState() => _BatchDialogState();
}

class _BatchDialogState extends State<_BatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      _selectedDate = widget.batch!.expiryDate;
      _quantityController.text = widget.batch!.quantity.toString();
      _notesController.text = widget.batch!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tarihi seçin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final batchProvider = context.read<BatchProvider>();
    final quantity = int.parse(_quantityController.text);
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (widget.batch == null) {
      // Yeni parti
      await batchProvider.addBatch(
        productId: widget.productId,
        expiryDate: _selectedDate!,
        quantity: quantity,
        notes: notes,
      );
    } else {
      // Güncelleme
      final updated = widget.batch!.copyWith(
        expiryDate: _selectedDate,
        quantity: quantity,
        notes: notes,
      );
      await batchProvider.updateBatch(updated);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.batch == null ? 'Parti eklendi' : 'Parti güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return AlertDialog(
      title: Text(widget.batch == null ? 'Yeni Parti Ekle' : 'Parti Düzenle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün adı
              Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Tarih seçici
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedDate == null
                          ? Colors.red
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Son Kullanma Tarihi',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              _selectedDate == null
                                  ? 'Tarih Seçin'
                                  : dateFormat.format(_selectedDate!),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Adet
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Adet',
                  prefixIcon: Icon(Icons.inventory_2),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Adet gerekli';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Not (isteğe bağlı)
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Not (isteğe bağlı)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  hintText: 'Örn: A rafı, üst sıra',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.batch == null ? 'Ekle' : 'Güncelle'),
        ),
      ],
    );
  }
}
