import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../providers/product_provider.dart';

/// SKT Güncelleme Ekranı
class UpdateExpiryScreen extends StatefulWidget {
  final Product product;

  const UpdateExpiryScreen({
    super.key,
    required this.product,
  });

  @override
  State<UpdateExpiryScreen> createState() => _UpdateExpiryScreenState();
}

class _UpdateExpiryScreenState extends State<UpdateExpiryScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedExpiryDate;
  final _shelfLifeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mevcut değerleri yükle
    _selectedExpiryDate = widget.product.expiryDate;
    _shelfLifeController.text = widget.product.shelfLifeDays.toString();
  }

  @override
  void dispose() {
    _shelfLifeController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: AppStrings.selectDate,
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.save,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textWhite,
              surface: AppColors.background,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen son kullanma tarihi seçin'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final shelfLifeDays = int.tryParse(_shelfLifeController.text) ?? 0;

    final updatedProduct = widget.product.copyWith(
      expiryDate: _selectedExpiryDate,
      shelfLifeDays: shelfLifeDays,
    );

    final productProvider = context.read<ProductProvider>();
    final success = await productProvider.updateProduct(updatedProduct);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SKT bilgileri başarıyla güncellendi'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Güncelleme başarısız oldu'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Color _getRiskColor() {
    if (_selectedExpiryDate == null) return Colors.grey;
    
    final shelfLifeDays = int.tryParse(_shelfLifeController.text) ?? 0;
    final adjustedDate = _selectedExpiryDate!.subtract(Duration(days: shelfLifeDays));
    final daysUntil = adjustedDate.difference(DateTime.now()).inDays;

    if (daysUntil < 0) return AppColors.danger;
    if (daysUntil <= 3) return AppColors.danger;
    if (daysUntil <= 7) return AppColors.warning;
    if (daysUntil <= 14) return const Color(0xFFFFA726);
    return AppColors.success;
  }

  String _getRiskText() {
    if (_selectedExpiryDate == null) return 'Tarih seçilmedi';
    
    final shelfLifeDays = int.tryParse(_shelfLifeController.text) ?? 0;
    final adjustedDate = _selectedExpiryDate!.subtract(Duration(days: shelfLifeDays));
    final daysUntil = adjustedDate.difference(DateTime.now()).inDays;

    if (daysUntil < 0) return 'SÜRESI DOLMUŞ';
    if (daysUntil == 0) return 'BUGÜN SONA ERİYOR';
    if (daysUntil <= 3) return 'KRİTİK: $daysUntil gün kaldı';
    if (daysUntil <= 7) return 'YÜKSEK RİSK: $daysUntil gün kaldı';
    if (daysUntil <= 14) return 'DİKKAT: $daysUntil gün kaldı';
    return 'GÜVENLİ: $daysUntil+ gün';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('SKT Bilgilerini Güncelle'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ürün Bilgileri Kartı
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory_2, color: AppColors.primary, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (widget.product.brand != null)
                                    Text(
                                      widget.product.brand!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.qr_code,
                          'Barkod',
                          widget.product.barcode,
                        ),
                        if (widget.product.category != null)
                          _buildInfoRow(
                            Icons.category,
                            'Kategori',
                            widget.product.category!,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Mevcut SKT Bilgileri
                if (widget.product.expiryDate != null)
                  Card(
                    color: AppColors.info.withValues(alpha: 0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.info, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.info),
                              SizedBox(width: 8),
                              Text(
                                'Mevcut SKT Bilgileri',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Son Kullanma: ${dateFormat.format(widget.product.expiryDate!)}'),
                          Text('Raf Ömrü: ${widget.product.shelfLifeDays} gün'),
                          if (widget.product.daysUntilExpiry != null)
                            Text(
                              'Kalan Süre: ${widget.product.daysUntilExpiry} gün',
                              style: TextStyle(
                                color: _getRiskColorForCurrentProduct(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // === YENİ SKT BİLGİLERİ === //
                const Text(
                  'Yeni SKT Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Son Kullanma Tarihi
                InkWell(
                  onTap: _selectExpiryDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedExpiryDate != null
                            ? AppColors.primary
                            : AppColors.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: _selectedExpiryDate != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Son Kullanma Tarihi *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedExpiryDate != null
                                    ? dateFormat.format(_selectedExpiryDate!)
                                    : 'Tarih seçin',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedExpiryDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Raf Ömrü
                TextFormField(
                  controller: _shelfLifeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Raftan Kalkma Süresi (gün) *',
                    hintText: 'Örn: 3',
                    prefixIcon: const Icon(Icons.access_time),
                    helperText: 'Ürünün raftan ne kadar önce kalkacağı',
                    helperMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Raf ömrünü girin';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 0) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 24),

                // Risk Önizleme Kartı
                if (_selectedExpiryDate != null &&
                    _shelfLifeController.text.isNotEmpty)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _getRiskColor(),
                        width: 2,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getRiskColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield,
                                color: _getRiskColor(),
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Risk Durumu',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      _getRiskText(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getRiskColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildPreviewRow(
                            'Paket SKT',
                            dateFormat.format(_selectedExpiryDate!),
                          ),
                          _buildPreviewRow(
                            'Raf Ömrü',
                            '${_shelfLifeController.text} gün',
                          ),
                          _buildPreviewRow(
                            'Düzeltilmiş SKT',
                            dateFormat.format(
                              _selectedExpiryDate!.subtract(
                                Duration(
                                  days: int.tryParse(_shelfLifeController.text) ?? 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Kaydet Butonu
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveChanges,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isLoading ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // İptal Butonu
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('İptal'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColorForCurrentProduct() {
    final days = widget.product.daysUntilExpiry;
    if (days == null) return Colors.grey;
    if (days < 0) return AppColors.danger;
    if (days <= 3) return AppColors.danger;
    if (days <= 7) return AppColors.warning;
    if (days <= 14) return const Color(0xFFFFA726);
    return AppColors.success;
  }
}
