import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Color _getRiskColor() {
    switch (_product.riskLevel) {
      case RiskLevel.expired:
        return AppColors.danger;
      case RiskLevel.critical:
        return AppColors.danger;
      case RiskLevel.high:
        return AppColors.warning;
      case RiskLevel.medium:
        return const Color(0xFFFFA726);
      case RiskLevel.low:
        return AppColors.success;
    }
  }

  String _getRiskText() {
    switch (_product.riskLevel) {
      case RiskLevel.expired:
        return AppStrings.expiredWarning;
      case RiskLevel.critical:
        return AppStrings.criticalRisk;
      case RiskLevel.high:
        return AppStrings.highRisk;
      case RiskLevel.medium:
        return AppStrings.mediumRisk;
      case RiskLevel.low:
        return AppStrings.lowRisk;
    }
  }

  IconData _getRiskIcon() {
    switch (_product.riskLevel) {
      case RiskLevel.expired:
        return Icons.dangerous;
      case RiskLevel.critical:
        return Icons.error;
      case RiskLevel.high:
        return Icons.warning_amber;
      case RiskLevel.medium:
        return Icons.access_time;
      case RiskLevel.low:
        return Icons.check_circle;
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _product.expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      locale: const Locale('tr', 'TR'),
      helpText: AppStrings.selectNewExpiryDate,
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

    if (picked != null && picked != _product.expiryDate) {
      await _updateExpiryDate(picked);
    }
  }

  Future<void> _updateExpiryDate(DateTime newDate) async {
    final updatedProduct = _product.copyWith(expiryDate: newDate);
    
    final productProvider = context.read<ProductProvider>();
    final success = await productProvider.updateProduct(updatedProduct);

    if (mounted) {
      if (success) {
        setState(() {
          _product = updatedProduct;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.dateUpdated),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.errorMessage ?? 'Güncelleme başarısız'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _markAsStockOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.confirmStockOut),
        content: const Text(AppStrings.confirmStockOutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Stoku 0'a çek
      final updatedProduct = _product.copyWith(quantity: 0);
      final productProvider = context.read<ProductProvider>();
      final success = await productProvider.updateProduct(updatedProduct);

      if (mounted) {
        if (success) {
          setState(() {
            _product = updatedProduct;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.stockMarkedAsZero),
              backgroundColor: AppColors.warning,
            ),
          );
          // Ana ekrana dön
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _initiateReturn() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.confirmReturn),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.confirmReturnMessage),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text('Miktar: ${_product.quantity} adet'),
                  if (_product.price != null)
                    Text('Toplam: ${(_product.price! * _product.quantity).toStringAsFixed(2)} ₺'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
            ),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // İade sürecini başlat (Backend'e istek gönderilecek)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.returnProcessStarted),
          backgroundColor: AppColors.info,
          duration: Duration(seconds: 3),
        ),
      );
      
      // TODO: Backend'e iade talebi gönder
      // await returnRepository.createReturnRequest(product);
      
      // Ana ekrana dön
      Navigator.pop(context);
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.danger, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text(AppStrings.confirmDelete)),
          ],
        ),
        content: const Text(AppStrings.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final productProvider = context.read<ProductProvider>();
      final success = await productProvider.deleteProduct(_product.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.productDeleted),
              backgroundColor: AppColors.danger,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final riskColor = _getRiskColor();
    final adjustedExpiryDate = _product.expiryDate.subtract(
      Duration(days: _product.shelfLifeDays),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.productDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteProduct,
            tooltip: AppStrings.deleteProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Risk Banner
            if (_product.riskLevel == RiskLevel.expired ||
                _product.riskLevel == RiskLevel.critical)
              Container(
                padding: const EdgeInsets.all(16),
                color: riskColor,
                child: Row(
                  children: [
                    Icon(_getRiskIcon(), color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _product.riskLevel == RiskLevel.expired
                                ? AppStrings.expiredWarning
                                : AppStrings.criticalWarning,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.takeAction,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Product Image
            Container(
              height: 200,
              color: AppColors.surface,
              child: _product.imageUrl != null
                  ? Image.network(
                      _product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.inventory_2,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.inventory_2,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),

            // Product Info Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    _product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Brand & Category
                  Row(
                    children: [
                      if (_product.brand != null) ...[
                        const Icon(Icons.business, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _product.brand!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (_product.brand != null && _product.category != null)
                        const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                      if (_product.category != null) ...[
                        const Icon(Icons.category, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _product.category!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Risk Status Card
                  _buildInfoCard(
                    title: AppStrings.riskStatus,
                    color: riskColor,
                    children: [
                      Row(
                        children: [
                          Icon(_getRiskIcon(), color: riskColor, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getRiskText(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: riskColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_product.daysUntilExpiry.abs()} ${AppStrings.day} ${_product.daysUntilExpiry < 0 ? "geçti" : "kaldı"}',
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
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Expiry Info Card
                  _buildInfoCard(
                    title: AppStrings.expiryInfo,
                    color: AppColors.info,
                    children: [
                      _buildInfoRow(
                        AppStrings.originalExpiryDate,
                        dateFormat.format(_product.expiryDate),
                        Icons.calendar_today,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        AppStrings.shelfLifeInfo,
                        '${_product.shelfLifeDays} gün önce',
                        Icons.access_time,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        AppStrings.adjustedExpiryDate,
                        dateFormat.format(adjustedExpiryDate),
                        Icons.event_available,
                        valueColor: riskColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock Info Card
                  _buildInfoCard(
                    title: AppStrings.stockInfo,
                    color: AppColors.success,
                    children: [
                      _buildInfoRow(
                        AppStrings.quantity,
                        '${_product.quantity} ${AppStrings.piece}',
                        Icons.inventory,
                      ),
                      if (_product.price != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          AppStrings.price,
                          '${_product.price!.toStringAsFixed(2)} ₺',
                          Icons.attach_money,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Toplam Değer',
                          '${(_product.price! * _product.quantity).toStringAsFixed(2)} ₺',
                          Icons.account_balance_wallet,
                          valueColor: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Details Card
                  _buildInfoCard(
                    title: AppStrings.productInfo,
                    color: AppColors.primary,
                    children: [
                      _buildInfoRow(
                        AppStrings.barcode,
                        _product.barcode,
                        Icons.qr_code_2,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        AppStrings.addedDate,
                        dateFormat.format(_product.addedDate),
                        Icons.add_circle_outline,
                      ),
                      if (_product.notes != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          AppStrings.notes,
                          _product.notes!,
                          Icons.note,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  const Text(
                    AppStrings.actions,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Update Date Button
                  _buildActionButton(
                    icon: Icons.calendar_month,
                    label: AppStrings.updateExpiryDate,
                    color: AppColors.info,
                    onPressed: _selectExpiryDate,
                  ),
                  const SizedBox(height: 12),

                  // Mark as Stock Out Button
                  _buildActionButton(
                    icon: Icons.remove_shopping_cart,
                    label: AppStrings.markAsStockOut,
                    color: AppColors.warning,
                    onPressed: _markAsStockOut,
                  ),
                  const SizedBox(height: 12),

                  // Initiate Return Button
                  _buildActionButton(
                    icon: Icons.keyboard_return,
                    label: AppStrings.initiateReturn,
                    color: AppColors.secondary,
                    onPressed: _initiateReturn,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.info_outline, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
