import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../providers/batch_provider.dart';
import 'product_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = '7'; // 7, 30, 90 gün

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final productProvider = context.watch<ProductProvider>();
    final batchProvider = context.watch<BatchProvider>();
    final products = productProvider.products;

    // İstatistikleri hesapla
    final stats = _calculateStats(products, batchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Dashboard'),
        actions: [
          // Dönem seçici
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              underline: const SizedBox.shrink(),
              dropdownColor: colorScheme.surface,
              style: TextStyle(color: colorScheme.onSurface),
              items: const [
                DropdownMenuItem(value: '7', child: Text('Son 7 Gün')),
                DropdownMenuItem(value: '30', child: Text('Son 30 Gün')),
                DropdownMenuItem(value: '90', child: Text('Son 90 Gün')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value ?? '7';
                });
              },
            ),
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? _buildEmptyState(colorScheme)
              : RefreshIndicator(
                  onRefresh: () async {
                    await productProvider.loadProducts(
                      productProvider.products.first.storeId,
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Özet Kartlar
                        _buildSummaryCards(stats, colorScheme),
                        const SizedBox(height: 24),

                        // Risk Dağılımı Grafiği
                        _buildSectionTitle('Risk Dağılımı', Icons.pie_chart, colorScheme),
                        const SizedBox(height: 12),
                        _buildRiskPieChart(stats, colorScheme),
                        const SizedBox(height: 24),

                        // Kategori Analizi
                        _buildSectionTitle('Kategori Analizi', Icons.bar_chart, colorScheme),
                        const SizedBox(height: 12),
                        _buildCategoryBarChart(stats, colorScheme),
                        const SizedBox(height: 24),

                        // Son Eklenen Ürünler
                        _buildSectionTitle('Son Eklenen Ürünler', Icons.access_time, colorScheme),
                        const SizedBox(height: 12),
                        _buildRecentProducts(products, colorScheme),
                        const SizedBox(height: 24),

                        // Kritik Ürünler
                        _buildSectionTitle('Kritik Ürünler', Icons.warning_amber, colorScheme),
                        const SizedBox(height: 12),
                        _buildCriticalProducts(products, colorScheme),
                      ],
                    ),
                  ),
                ),
    );
  }

  Map<String, dynamic> _calculateStats(List<Product> products, BatchProvider batchProvider) {
    final now = DateTime.now();
    final periodDays = int.parse(_selectedPeriod);
    final periodStart = now.subtract(Duration(days: periodDays));

    // Toplam istatistikler
    int totalProducts = products.length;
    int expiredCount = 0;
    int criticalCount = 0;
    int highCount = 0;
    int mediumCount = 0;
    int lowCount = 0;
    int totalBatches = batchProvider.batches.length;

    // Risk dağılımı
    for (var product in products) {
      if (product.isStockOut) continue;
      
      switch (product.riskLevel) {
        case RiskLevel.expired:
          expiredCount++;
          break;
        case RiskLevel.critical:
          criticalCount++;
          break;
        case RiskLevel.high:
          highCount++;
          break;
        case RiskLevel.medium:
          mediumCount++;
          break;
        case RiskLevel.low:
          lowCount++;
          break;
        default:
          break;
      }
    }

    // Kategori dağılımı
    Map<String, int> categoryCount = {};
    for (var product in products) {
      final category = product.category ?? 'Diğer';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    // En çok kategori (ilk 5)
    var sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sortedCategories.length > 5) {
      sortedCategories = sortedCategories.take(5).toList();
    }

    // Son eklenen ürünler (dönem bazlı)
    final recentProducts = products
        .where((p) => p.addedDate.isAfter(periodStart))
        .toList()
      ..sort((a, b) => b.addedDate.compareTo(a.addedDate));

    return {
      'totalProducts': totalProducts,
      'expiredCount': expiredCount,
      'criticalCount': criticalCount,
      'highCount': highCount,
      'mediumCount': mediumCount,
      'lowCount': lowCount,
      'totalBatches': totalBatches,
      'categoryCount': sortedCategories,
      'recentProducts': recentProducts.take(5).toList(),
    };
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 80, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Henüz veri yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ürün ekleyerek dashboard\'u aktif edin',
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> stats, ColorScheme colorScheme) {
    return Column(
      children: [
        // İlk satır
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Toplam Ürün',
                value: '${stats['totalProducts']}',
                icon: Icons.inventory_2,
                color: colorScheme.primary,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Toplam Parti',
                value: '${stats['totalBatches']}',
                icon: Icons.dataset,
                color: colorScheme.secondary,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // İkinci satır
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Kritik',
                value: '${stats['criticalCount']}',
                icon: Icons.error,
                color: Colors.red,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Uyarı',
                value: '${stats['highCount']}',
                icon: Icons.warning_amber,
                color: Colors.orange,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskPieChart(Map<String, dynamic> stats, ColorScheme colorScheme) {
    final expired = stats['expiredCount'] as int;
    final critical = stats['criticalCount'] as int;
    final high = stats['highCount'] as int;
    final medium = stats['mediumCount'] as int;
    final low = stats['lowCount'] as int;

    final total = expired + critical + high + medium + low;
    if (total == 0) {
      return _buildNoDataCard('Risk verisi yok', colorScheme);
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Pasta grafiği
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (expired > 0)
                    PieChartSectionData(
                      value: expired.toDouble(),
                      title: '$expired',
                      color: Colors.black,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (critical > 0)
                    PieChartSectionData(
                      value: critical.toDouble(),
                      title: '$critical',
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (high > 0)
                    PieChartSectionData(
                      value: high.toDouble(),
                      title: '$high',
                      color: Colors.orange,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (medium > 0)
                    PieChartSectionData(
                      value: medium.toDouble(),
                      title: '$medium',
                      color: Colors.yellow.shade700,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (low > 0)
                    PieChartSectionData(
                      value: low.toDouble(),
                      title: '$low',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Legends
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expired > 0) _buildLegendItem('Süresi Geçmiş', Colors.black, expired, colorScheme),
                if (critical > 0) _buildLegendItem('Kritik', Colors.red, critical, colorScheme),
                if (high > 0) _buildLegendItem('Yüksek', Colors.orange, high, colorScheme),
                if (medium > 0) _buildLegendItem('Orta', Colors.yellow.shade700, medium, colorScheme),
                if (low > 0) _buildLegendItem('Düşük', Colors.green, low, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBarChart(Map<String, dynamic> stats, ColorScheme colorScheme) {
    final categories = stats['categoryCount'] as List<MapEntry<String, int>>;

    if (categories.isEmpty) {
      return _buildNoDataCard('Kategori verisi yok', colorScheme);
    }

    final maxValue = categories.first.value.toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxValue + 2,
          barGroups: categories.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  color: colorScheme.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= categories.length) return const SizedBox.shrink();
                  final category = categories[value.toInt()].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      category.length > 8 ? '${category.substring(0, 8)}...' : category,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.outline,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: colorScheme.outline.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRecentProducts(List<Product> products, ColorScheme colorScheme) {
    final recentProducts = products.toList()
      ..sort((a, b) => b.addedDate.compareTo(a.addedDate));
    final displayProducts = recentProducts.take(5).toList();

    if (displayProducts.isEmpty) {
      return _buildNoDataCard('Henüz ürün eklenmedi', colorScheme);
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayProducts.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final product = displayProducts[index];
          final dateFormat = DateFormat('dd.MM.yyyy');
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.inventory_2, color: colorScheme.onPrimaryContainer),
            ),
            title: Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'Eklendi: ${dateFormat.format(product.addedDate)}',
              style: TextStyle(fontSize: 12, color: colorScheme.outline),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
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
    );
  }

  Widget _buildCriticalProducts(List<Product> products, ColorScheme colorScheme) {
    final criticalProducts = products
        .where((p) => 
            !p.isStockOut &&
            (p.riskLevel == RiskLevel.expired || p.riskLevel == RiskLevel.critical))
        .toList()
      ..sort((a, b) => (a.daysUntilExpiry ?? 999).compareTo(b.daysUntilExpiry ?? 999));

    if (criticalProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              'Harika! Kritik ürün yok',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tüm ürünler güvenli durumda',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    final displayProducts = criticalProducts.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayProducts.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final product = displayProducts[index];
          final daysLeft = product.daysUntilExpiry ?? 0;
          final isExpired = daysLeft < 0;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isExpired ? Colors.black : Colors.red,
              child: Icon(
                isExpired ? Icons.dangerous : Icons.error,
                color: Colors.white,
              ),
            ),
            title: Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              isExpired
                  ? 'Süresi ${daysLeft.abs()} gün önce geçti!'
                  : '$daysLeft gün kaldı',
              style: TextStyle(
                fontSize: 12,
                color: isExpired ? Colors.black : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
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
    );
  }

  Widget _buildNoDataCard(String message, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: colorScheme.outline,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
