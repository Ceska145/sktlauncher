/// Batch/Parti entity - Aynı üründen farklı SKT'lerde stok takibi
class ProductBatch {
  final String id;
  final String productId; // Hangi ürüne ait
  final DateTime expiryDate; // Bu partinin SKT'si
  final int quantity; // Bu partideki adet
  final DateTime addedDate; // Ne zaman eklendi
  final String? notes; // Parti notu (isteğe bağlı)

  ProductBatch({
    required this.id,
    required this.productId,
    required this.expiryDate,
    required this.quantity,
    required this.addedDate,
    this.notes,
  });

  ProductBatch copyWith({
    String? id,
    String? productId,
    DateTime? expiryDate,
    int? quantity,
    DateTime? addedDate,
    String? notes,
  }) {
    return ProductBatch(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      addedDate: addedDate ?? this.addedDate,
      notes: notes ?? this.notes,
    );
  }

  /// JSON'a çevir (Hive için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'expiry_date': expiryDate.millisecondsSinceEpoch,
      'quantity': quantity,
      'added_date': addedDate.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  /// JSON'dan oluştur
  factory ProductBatch.fromJson(Map<String, dynamic> json) {
    return ProductBatch(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      expiryDate: DateTime.fromMillisecondsSinceEpoch(json['expiry_date'] as int),
      quantity: json['quantity'] as int,
      addedDate: DateTime.fromMillisecondsSinceEpoch(json['added_date'] as int),
      notes: json['notes'] as String?,
    );
  }
}
