import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import 'package:intl/intl.dart';

/// Grid görünümü için optimize edilmiş ürün kartı
class GridProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const GridProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  Color _getRiskColor() {
    switch (product.riskLevel) {
      case RiskLevel.expired:
        return Colors.black;
      case RiskLevel.critical:
        return Colors.red;
      case RiskLevel.high:
        return Colors.orange;
      case RiskLevel.medium:
        return Colors.yellow.shade700;
      case RiskLevel.low:
        return Colors.green;
      case null:
        return Colors.grey;
    }
  }

  String _getRiskText() {
    if (product.isStockOut) return 'Sıfır';
    if (product.riskLevel == null) return '-';
    
    final days = product.daysUntilExpiry;
    if (days == null) return '-';
    
    if (days < 0) {
      return 'Geçti';
    } else if (days == 0) {
      return 'Bugün';
    } else if (days <= 3) {
      return '$days gün';
    } else if (days <= 7) {
      return '$days gün';
    } else if (days <= 14) {
      return '$days gün';
    } else {
      return '$days+ gün';
    }
  }

  IconData _getRiskIcon() {
    switch (product.riskLevel) {
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
      case null:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yy');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final riskColor = _getRiskColor();
    final isHighRisk = product.riskLevel == RiskLevel.expired ||
        product.riskLevel == RiskLevel.critical;

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isHighRisk ? riskColor : Colors.transparent,
          width: isHighRisk ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ürün görseli
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Görsel
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.inventory_2,
                                  size: 48,
                                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.inventory_2,
                              size: 48,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                    ),
                  ),
                  
                  // Risk badge (sağ üst)
                  if (product.riskLevel != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getRiskIcon(),
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getRiskText(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Ürün bilgileri
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ürün adı
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),

                    // Alt bilgiler
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Marka (varsa)
                        if (product.brand != null)
                          Text(
                            product.brand!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                        const SizedBox(height: 4),

                        // SKT tarih (varsa)
                        if (product.expiryDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(product.expiryDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),

                        // Kategori (varsa)
                        if (product.category != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.category!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
