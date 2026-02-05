import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_strings.dart';
import 'package:intl/intl.dart';

/// Ürün kartı widget'ı
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  Color _getRiskColor() {
    switch (product.riskLevel) {
      case RiskLevel.expired:
        return AppColors.danger;
      case RiskLevel.critical:
        return AppColors.danger;
      case RiskLevel.high:
        return AppColors.warning;
      case RiskLevel.medium:
        return Color(0xFFFFA726);
      case RiskLevel.low:
        return AppColors.success;
    }
  }

  String _getRiskText() {
    final days = product.daysUntilExpiry;
    if (days < 0) {
      return AppStrings.expired;
    } else if (days == 0) {
      return AppStrings.expiringToday;
    } else if (days <= 3) {
      return '$days ${AppStrings.day}';
    } else if (days <= 7) {
      return '$days ${AppStrings.days}';
    } else if (days <= 14) {
      return '$days ${AppStrings.days}';
    } else {
      return '$days+ ${AppStrings.days}';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final riskColor = _getRiskColor();
    final isHighRisk = product.riskLevel == RiskLevel.expired ||
        product.riskLevel == RiskLevel.critical;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isHighRisk ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isHighRisk ? riskColor : Colors.transparent,
          width: isHighRisk ? 3 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün görseli (placeholder)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.inventory_2,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
              ),
              const SizedBox(width: 12),

              // Ürün bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün adı
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Marka
                    if (product.brand != null)
                      Text(
                        product.brand!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // SKT bilgisi
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(product.expiryDate),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Miktar ve fiyat
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.quantity} adet',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (product.price != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            '${product.price!.toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Risk göstergesi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRiskIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRiskText(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
