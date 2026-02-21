import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_history.dart';
import '../providers/history_provider.dart';

class ProductHistoryTab extends StatefulWidget {
  final Product product;

  const ProductHistoryTab({super.key, required this.product});

  @override
  State<ProductHistoryTab> createState() => _ProductHistoryTabState();
}

class _ProductHistoryTabState extends State<ProductHistoryTab> {
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final historyProvider = context.watch<HistoryProvider>();
    
    var histories = historyProvider.getHistoriesByProductId(widget.product.id);
    
    // Filtre uygula
    if (_filterType != 'all') {
      final type = ProductHistoryType.values.firstWhere(
        (e) => e.name == _filterType,
        orElse: () => ProductHistoryType.other,
      );
      histories = histories.where((h) => h.type == type).toList();
    }

    return Column(
      children: [
        // Filtre bar
        _buildFilterBar(colorScheme, histories.length),
        
        // Timeline
        Expanded(
          child: histories.isEmpty
              ? _buildEmptyState(colorScheme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final history = histories[index];
                    final isLast = index == histories.length - 1;
                    return _buildTimelineItem(
                      history,
                      colorScheme,
                      isLast: isLast,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(ColorScheme colorScheme, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Filtre:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tümü', 'all', count, colorScheme),
                  _buildFilterChip(
                    'Oluşturma',
                    ProductHistoryType.created.name,
                    null,
                    colorScheme,
                  ),
                  _buildFilterChip(
                    'Güncelleme',
                    ProductHistoryType.updated.name,
                    null,
                    colorScheme,
                  ),
                  _buildFilterChip(
                    'SKT',
                    ProductHistoryType.expiryUpdated.name,
                    null,
                    colorScheme,
                  ),
                  _buildFilterChip(
                    'Parti',
                    ProductHistoryType.batchAdded.name,
                    null,
                    colorScheme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    int? count,
    ColorScheme colorScheme,
  ) {
    final isSelected = _filterType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          count != null ? '$label ($count)' : label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterType = value;
          });
        },
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz geçmiş kaydı yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterType != 'all'
                ? 'Bu filtre için kayıt bulunamadı'
                : 'Ürün üzerinde yapılan değişiklikler burada görünecek',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    ProductHistory history,
    ColorScheme colorScheme, {
    required bool isLast,
  }) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');
    final color = _getColorForType(history.type, colorScheme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            // Icon bubble
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  history.type.icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            
            // Vertical line
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color,
                      color.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
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
                // Type badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        history.type.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(history.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  history.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                // Old/New values
                if (history.oldValue != null || history.newValue != null) ...[
                  const SizedBox(height: 12),
                  _buildValueChanges(history, colorScheme),
                ],
                
                // User name
                if (history.userName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        history.userName!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueChanges(
    ProductHistory history,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.oldValue != null) ...[
            Row(
              children: [
                Icon(
                  Icons.remove_circle_outline,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Eski: ${_formatValue(history.oldValue!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (history.newValue != null)
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yeni: ${_formatValue(history.newValue!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatValue(Map<String, dynamic> value) {
    return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  Color _getColorForType(ProductHistoryType type, ColorScheme colorScheme) {
    switch (type) {
      case ProductHistoryType.created:
        return Colors.green;
      case ProductHistoryType.updated:
        return Colors.blue;
      case ProductHistoryType.expiryUpdated:
        return Colors.orange;
      case ProductHistoryType.stockedOut:
        return Colors.grey;
      case ProductHistoryType.batchAdded:
        return Colors.purple;
      case ProductHistoryType.batchUpdated:
        return Colors.teal;
      case ProductHistoryType.batchDeleted:
        return Colors.red;
      case ProductHistoryType.riskChanged:
        return Colors.amber;
      case ProductHistoryType.deleted:
        return Colors.red;
      case ProductHistoryType.other:
        return colorScheme.outline;
    }
  }
}
