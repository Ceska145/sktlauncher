import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'barcode_scanner_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ürünleri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final storeId = authProvider.currentUser?.storeId ?? 'store_001';
      context.read<ProductProvider>().loadProducts(storeId);
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrele',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FilterOption(
              title: AppStrings.allProducts,
              count: productProvider.products.length,
              color: AppColors.primary,
              icon: Icons.inventory_2,
              value: 'all',
              currentValue: productProvider.filterRiskLevel,
              onTap: () {
                productProvider.setFilter('all');
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: AppStrings.expiredProducts,
              count: productProvider.expiredCount,
              color: AppColors.danger,
              icon: Icons.dangerous,
              value: 'expired',
              currentValue: productProvider.filterRiskLevel,
              onTap: () {
                productProvider.setFilter('expired');
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: AppStrings.criticalRisk,
              count: productProvider.criticalCount,
              color: AppColors.danger,
              icon: Icons.error,
              value: 'critical',
              currentValue: productProvider.filterRiskLevel,
              onTap: () {
                productProvider.setFilter('critical');
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: AppStrings.highRisk,
              count: productProvider.highCount,
              color: AppColors.warning,
              icon: Icons.warning_amber,
              value: 'high',
              currentValue: productProvider.filterRiskLevel,
              onTap: () {
                productProvider.setFilter('high');
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: AppStrings.mediumRisk,
              count: productProvider.mediumCount,
              color: const Color(0xFFFFA726),
              icon: Icons.access_time,
              value: 'medium',
              currentValue: productProvider.filterRiskLevel,
              onTap: () {
                productProvider.setFilter('medium');
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: AppStrings.lowRisk,
              count: productProvider.lowCount,
              color: AppColors.success,
              icon: Icons.check_circle,
              value: 'low',
              currentValue: productProvider.filterRiskLevel,
              onTap: () {
                productProvider.setFilter('low');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.appTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (authProvider.currentUser?.storeName != null)
              Text(
                authProvider.currentUser!.storeName!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          // Filtre butonu
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(context),
              ),
              if (productProvider.filterRiskLevel != 'all')
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          // Çıkış butonu
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                // Login ekranına dön
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final storeId = authProvider.currentUser?.storeId ?? 'store_001';
          await productProvider.loadProducts(storeId);
        },
        child: productProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : productProvider.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.danger,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          productProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            final storeId = authProvider.currentUser?.storeId ?? 'store_001';
                            productProvider.loadProducts(storeId);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : productProvider.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              productProvider.filterRiskLevel == 'all'
                                  ? AppStrings.noProducts
                                  : AppStrings.noProductsFiltered,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // İstatistik kartları
                          _StatisticsBar(
                            expiredCount: productProvider.expiredCount,
                            criticalCount: productProvider.criticalCount,
                            highCount: productProvider.highCount,
                            totalCount: productProvider.products.length,
                          ),
                          
                          // Ürün listesi
                          Expanded(
                            child: ListView.builder(
                              itemCount: productProvider.products.length,
                              itemBuilder: (context, index) {
                                final product = productProvider.products[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailScreen(
                                          product: product,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BarcodeScannerScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text(AppStrings.scanBarcode),
      ),
    );
  }
}

/// İstatistik çubuğu widget'ı
class _StatisticsBar extends StatelessWidget {
  final int expiredCount;
  final int criticalCount;
  final int highCount;
  final int totalCount;

  const _StatisticsBar({
    required this.expiredCount,
    required this.criticalCount,
    required this.highCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final riskCount = expiredCount + criticalCount + highCount;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: AppStrings.totalProducts,
              count: totalCount,
              color: AppColors.info,
              icon: Icons.inventory_2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: AppStrings.riskProducts,
              count: riskCount,
              color: riskCount > 0 ? AppColors.danger : AppColors.success,
              icon: riskCount > 0 ? Icons.warning : Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// İstatistik kartı widget'ı
class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filtre seçeneği widget'ı
class _FilterOption extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final String value;
  final String currentValue;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.value,
    required this.currentValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == currentValue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: color, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
