import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../providers/batch_provider.dart';
import 'add_product_screen.dart';
import 'update_expiry_screen.dart';
import 'batch_management_tab.dart';
import 'product_history_tab.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late Product _product;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _tabController = TabController(length: 3, vsync: this);
    
    // Load batches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().loadBatches(_product.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getRiskColor() {
    if (_product.isStockOut || _product.riskLevel == null) return AppColors.info;
    
    switch (_product.riskLevel!) {
      case RiskLevel.expired:
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
    if (_product.isStockOut) return 'Stok Sıfırlandı';
    if (_product.riskLevel == null) return 'Bilinmiyor';
    
    switch (_product.riskLevel!) {
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
    if (_product.isStockOut) return Icons.inventory_2;
    if (_product.riskLevel == null) return Icons.help_outline;
    
    switch (_product.riskLevel!) {
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
    // Yeni SKT Güncelleme ekranına git
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateExpiryScreen(product: _product),
      ),
    );

    // Eğer güncelleme başarılı olduysa, ürünü yeniden yükle
    if (result == true && mounted) {
      final productProvider = context.read<ProductProvider>();
      final storeId = _product.storeId;
      await productProvider.loadProducts(storeId);
      
      // Güncellenmiş ürünü bul
      final updatedProduct = productProvider.products
          .firstWhere((p) => p.id == _product.id, orElse: () => _product);
      
      setState(() {
        _product = updatedProduct;
      });
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
      // Stoku sıfırla - SKT'yi sil ve isStockOut'u true yap
      final updatedProduct = _product.copyWith(
        clearExpiryDate: true,
        isStockOut: true,
      );
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
              backgroundColor: AppColors.success,
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
    final adjustedExpiryDate = _product.expiryDate?.subtract(
            Duration(days: _product.shelfLifeDays),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.productDetails),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Bilgiler'),
            Tab(icon: Icon(Icons.inventory), text: 'Partiler'),
            Tab(icon: Icon(Icons.history), text: 'Geçmiş'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(editProduct: _product),
                ),
              );
              if (result != null && mounted) {
                // Reload product data
                setState(() {});
              }
            },
            tooltip: AppStrings.editProduct,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteProduct,
            tooltip: AppStrings.deleteProduct,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Product Info
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Risk Banner (sadece stok sıfırlanmamışsa ve kritik durumdaysa göster)
            if (!_product.isStockOut && 
                (_product.riskLevel == RiskLevel.expired ||
                _product.riskLevel == RiskLevel.critical))
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

                  // Stok Sıfırlandı Bildirimi
                  if (_product.isStockOut)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.info),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2, color: AppColors.info, size: 32),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stok Sıfırlandı',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Bu ürünün stoğu sıfırlanmıştır',
                                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_product.isStockOut)
                    const SizedBox(height: 16),

                  // Risk Status Card (sadece stok sıfırlanmamışsa göster)
                  if (!_product.isStockOut)
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
                                    '${_product.daysUntilExpiry?.abs() ?? 0} ${AppStrings.day} ${(_product.daysUntilExpiry ?? 0) < 0 ? "geçti" : "kaldı"}',
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
                  if (!_product.isStockOut)
                    const SizedBox(height: 16),

                  // Expiry Info Card (sadece stok sıfırlanmamışsa göster)
                  if (!_product.isStockOut && _product.expiryDate != null)
                    _buildInfoCard(
                      title: AppStrings.expiryInfo,
                      color: AppColors.info,
                      children: [
                        _buildInfoRow(
                          AppStrings.originalExpiryDate,
                          dateFormat.format(_product.expiryDate!),
                          Icons.calendar_today,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          AppStrings.shelfLifeInfo,
                          '${_product.shelfLifeDays} gün önce',
                          Icons.access_time,
                        ),
                        const Divider(height: 24),
                        if (adjustedExpiryDate != null)
                          _buildInfoRow(
                            AppStrings.adjustedExpiryDate,
                            dateFormat.format(adjustedExpiryDate),
                            Icons.event_available,
                            valueColor: riskColor,
                          ),
                      ],
                    ),
                  if (!_product.isStockOut && _product.expiryDate != null)
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
          
          // Tab 2: Batch Management
          BatchManagementTab(product: _product),
          
          // Tab 3: Product History
          ProductHistoryTab(product: _product),
        ],
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
