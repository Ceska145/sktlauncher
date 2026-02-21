/// Ürün geçmişi entity'si
class ProductHistory {
  final String id;
  final String productId;
  final String productName;
  final ProductHistoryType type;
  final String description;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final DateTime timestamp;
  final String? userName;

  const ProductHistory({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.description,
    this.oldValue,
    this.newValue,
    required this.timestamp,
    this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type.name,
      'description': description,
      'oldValue': oldValue,
      'newValue': newValue,
      'timestamp': timestamp.toIso8601String(),
      'userName': userName,
    };
  }

  factory ProductHistory.fromJson(Map<String, dynamic> json) {
    return ProductHistory(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: ProductHistoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProductHistoryType.other,
      ),
      description: json['description'] as String,
      oldValue: json['oldValue'] as Map<String, dynamic>?,
      newValue: json['newValue'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userName: json['userName'] as String?,
    );
  }

  ProductHistory copyWith({
    String? id,
    String? productId,
    String? productName,
    ProductHistoryType? type,
    String? description,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    DateTime? timestamp,
    String? userName,
  }) {
    return ProductHistory(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      description: description ?? this.description,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      timestamp: timestamp ?? this.timestamp,
      userName: userName ?? this.userName,
    );
  }
}

/// Ürün geçmişi tipleri
enum ProductHistoryType {
  created,      // Ürün oluşturuldu
  updated,      // Ürün güncellendi
  expiryUpdated, // SKT güncellendi
  stockedOut,   // Stok sıfırlandı
  batchAdded,   // Parti eklendi
  batchUpdated, // Parti güncellendi
  batchDeleted, // Parti silindi
  riskChanged,  // Risk seviyesi değişti
  deleted,      // Ürün silindi
  other,        // Diğer
}

/// ProductHistoryType extension - UI için
extension ProductHistoryTypeExtension on ProductHistoryType {
  String get displayName {
    switch (this) {
      case ProductHistoryType.created:
        return 'Ürün Eklendi';
      case ProductHistoryType.updated:
        return 'Ürün Güncellendi';
      case ProductHistoryType.expiryUpdated:
        return 'SKT Güncellendi';
      case ProductHistoryType.stockedOut:
        return 'Stok Sıfırlandı';
      case ProductHistoryType.batchAdded:
        return 'Parti Eklendi';
      case ProductHistoryType.batchUpdated:
        return 'Parti Güncellendi';
      case ProductHistoryType.batchDeleted:
        return 'Parti Silindi';
      case ProductHistoryType.riskChanged:
        return 'Risk Durumu Değişti';
      case ProductHistoryType.deleted:
        return 'Ürün Silindi';
      case ProductHistoryType.other:
        return 'Diğer';
    }
  }

  String get icon {
    switch (this) {
      case ProductHistoryType.created:
        return '➕';
      case ProductHistoryType.updated:
        return '✏️';
      case ProductHistoryType.expiryUpdated:
        return '📅';
      case ProductHistoryType.stockedOut:
        return '📦';
      case ProductHistoryType.batchAdded:
        return '🏷️';
      case ProductHistoryType.batchUpdated:
        return '🔄';
      case ProductHistoryType.batchDeleted:
        return '🗑️';
      case ProductHistoryType.riskChanged:
        return '⚠️';
      case ProductHistoryType.deleted:
        return '❌';
      case ProductHistoryType.other:
        return '📝';
    }
  }

  String get color {
    switch (this) {
      case ProductHistoryType.created:
        return 'green';
      case ProductHistoryType.updated:
        return 'blue';
      case ProductHistoryType.expiryUpdated:
        return 'orange';
      case ProductHistoryType.stockedOut:
        return 'grey';
      case ProductHistoryType.batchAdded:
        return 'purple';
      case ProductHistoryType.batchUpdated:
        return 'teal';
      case ProductHistoryType.batchDeleted:
        return 'red';
      case ProductHistoryType.riskChanged:
        return 'amber';
      case ProductHistoryType.deleted:
        return 'red';
      case ProductHistoryType.other:
        return 'grey';
    }
  }
}
