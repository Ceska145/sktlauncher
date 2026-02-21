import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/grid_product_card.dart';
import 'barcode_scanner_screen.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'quick_add_screen.dart';
import 'settings_screen.dart';
import 'dashboard_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final storeId = authProvider.currentUser?.storeId ?? 'store_001';
      
      // Ürünleri yükle
      await context.read<ProductProvider>().loadProducts(storeId);
      
      // Bildirim kontrolü yap (arka planda)
      if (!mounted) return;
      final productProvider = context.read<ProductProvider>();
      final notificationProvider = context.read<NotificationProvider>();
      await notificationProvider.checkAndCreateNotifications(productProvider.products);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _FilterOption(
              title: AppStrings.allProducts,
              count: productProvider.totalProductCount,
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

  void _showSortBottomSheet(BuildContext context) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.sort, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  AppStrings.sortBy,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SortOption(
              title: AppStrings.sortByRisk,
              icon: Icons.warning_amber,
              value: SortOption.risk,
              currentValue: productProvider.sortOption,
              onTap: () {
                productProvider.setSortOption(SortOption.risk);
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: AppStrings.sortByExpiry,
              icon: Icons.calendar_today,
              value: SortOption.expiryAsc,
              currentValue: productProvider.sortOption,
              onTap: () {
                productProvider.setSortOption(SortOption.expiryAsc);
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: AppStrings.sortByExpiryDesc,
              icon: Icons.calendar_today,
              value: SortOption.expiryDesc,
              currentValue: productProvider.sortOption,
              onTap: () {
                productProvider.setSortOption(SortOption.expiryDesc);
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: AppStrings.sortByName,
              icon: Icons.sort_by_alpha,
              value: SortOption.nameAsc,
              currentValue: productProvider.sortOption,
              onTap: () {
                productProvider.setSortOption(SortOption.nameAsc);
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: AppStrings.sortByNameDesc,
              icon: Icons.sort_by_alpha,
              value: SortOption.nameDesc,
              currentValue: productProvider.sortOption,
              onTap: () {
                productProvider.setSortOption(SortOption.nameDesc);
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: AppStrings.sortByAdded,
              icon: Icons.schedule,
              value: SortOption.addedDesc,
              currentValue: productProvider.sortOption,
              onTap: () {
                productProvider.setSortOption(SortOption.addedDesc);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: productProvider.isSearching
          ? _buildSearchAppBar(productProvider)
          : _buildNormalAppBar(authProvider, productProvider),
      body: RefreshIndicator(
        onRefresh: () async {
          final storeId = authProvider.currentUser?.storeId ?? 'store_001';
          await productProvider.loadProducts(storeId);
        },
        child: productProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : productProvider.errorMessage != null
                ? _buildErrorState(authProvider, productProvider)
                : productProvider.totalProductCount == 0
                    ? _buildEmptyState()
                    : _buildProductList(productProvider, themeProvider),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildSearchAppBar(ProductProvider productProvider) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    productProvider.setSearchQuery('');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          productProvider.setSearchQuery(value);
          setState(() {}); // clear button visibility
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _searchController.clear();
            productProvider.toggleSearch();
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildNormalAppBar(
    AuthProvider authProvider,
    ProductProvider productProvider,
  ) {
    return AppBar(
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
        // Arama butonu
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => productProvider.toggleSearch(),
          tooltip: AppStrings.search,
        ),
        // Sıralama butonu
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.sort),
              if (productProvider.sortOption != SortOption.risk)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showSortBottomSheet(context),
          tooltip: AppStrings.sortBy,
        ),
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
        // Bildirim butonu
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  tooltip: 'Bildirimler',
                ),
                if (notificationProvider.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${notificationProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        // Dashboard butonu (Belirgin)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
            tooltip: '📊 Dashboard',
          ),
        ),
        // Ayarlar butonu
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          tooltip: 'Ayarlar',
        ),
        // Çıkış butonu
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await authProvider.logout();
            navigator.pushReplacementNamed('/login');
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(AuthProvider authProvider, ProductProvider productProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noProducts,
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.addFirstProduct,
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addProduct),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(ProductProvider productProvider, ThemeProvider themeProvider) {
    final products = productProvider.products;

    return Column(
      children: [
        // Active filters / search info bar
        if (productProvider.searchQuery.isNotEmpty ||
            productProvider.filterRiskLevel != 'all' ||
            productProvider.sortOption != SortOption.risk)
          _buildActiveFiltersBar(productProvider),

        // Dashboard Hızlı Erişim Kartı
        if (!productProvider.isSearching)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.dashboard,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📊 Dashboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'İstatistikler, grafikler ve raporlar',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue.shade400,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // İstatistik kartları
        if (!productProvider.isSearching)
          _StatisticsBar(
            expiredCount: productProvider.expiredCount,
            criticalCount: productProvider.criticalCount,
            highCount: productProvider.highCount,
            totalCount: productProvider.totalProductCount,
          ),

        // Ürün sayısı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${products.length} ürün',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (products.length != productProvider.totalProductCount)
                Text(
                  ' / ${productProvider.totalProductCount} toplam',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
        ),

        // Ürün listesi
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text(
                        productProvider.searchQuery.isNotEmpty
                            ? AppStrings.noSearchResults
                            : AppStrings.noProductsFiltered,
                        style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : themeProvider.viewMode == ViewMode.list
                  ? ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GridProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersBar(ProductProvider productProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (productProvider.searchQuery.isNotEmpty)
              _buildChip(
                label: '"${productProvider.searchQuery}"',
                icon: Icons.search,
                color: AppColors.info,
                onDelete: () {
                  _searchController.clear();
                  productProvider.setSearchQuery('');
                },
              ),
            if (productProvider.filterRiskLevel != 'all')
              _buildChip(
                label: _getFilterLabel(productProvider.filterRiskLevel),
                icon: Icons.filter_list,
                color: AppColors.warning,
                onDelete: () => productProvider.setFilter('all'),
              ),
            if (productProvider.sortOption != SortOption.risk)
              _buildChip(
                label: _getSortLabel(productProvider.sortOption),
                icon: Icons.sort,
                color: AppColors.primary,
                onDelete: () => productProvider.setSortOption(SortOption.risk),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
        deleteIcon: Icon(Icons.close, size: 16, color: color),
        onDeleted: onDelete,
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'expired': return AppStrings.expiredProducts;
      case 'critical': return AppStrings.criticalRisk;
      case 'high': return AppStrings.highRisk;
      case 'medium': return AppStrings.mediumRisk;
      case 'low': return AppStrings.lowRisk;
      default: return AppStrings.allProducts;
    }
  }

  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.nameAsc: return 'A-Z';
      case SortOption.nameDesc: return 'Z-A';
      case SortOption.expiryAsc: return 'SKT ↑';
      case SortOption.expiryDesc: return 'SKT ↓';
      case SortOption.addedDesc: return 'Yeni';
      default: return 'Risk';
    }
  }

  Widget _buildFAB(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barkod tara mini FAB
        FloatingActionButton.small(
          heroTag: 'scan',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
            );
          },
          backgroundColor: AppColors.secondary,
          child: const Icon(Icons.qr_code_scanner, size: 20),
        ),
        const SizedBox(height: 12),
        // Ürün ekle ana FAB (uzun basınca Quick Add)
        GestureDetector(
          onLongPress: () {
            // Hızlı ekleme modu
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuickAddScreen()),
            );
          },
          child: FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductScreen()),
              );
            },
            backgroundColor: AppColors.success,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addProduct),
          ),
        ),
      ],
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
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
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

/// Sıralama seçeneği widget'ı
class _SortOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final SortOption value;
  final SortOption currentValue;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
