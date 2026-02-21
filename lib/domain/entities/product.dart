/// Product entity - Domain layer
class Product {
  final String id;
  final String barcode;
  final String name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final DateTime? expiryDate; // Nullable - stok sıfırlandığında null olacak
  final DateTime addedDate;
  final int shelfLifeDays; // Raftan kalkma süresi (gün)
  final String? notes;
  final String storeId;
  final bool isStockOut; // Stok sıfırlandı mı?

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.expiryDate,
    required this.addedDate,
    required this.shelfLifeDays,
    this.notes,
    required this.storeId,
    this.isStockOut = false,
  });

  /// SKT risk hesaplama: (SKT - Raftan Kalkma Süresi) <= Bugün
  /// Kalan gün sayısını döner
  int? get daysUntilExpiry {
    if (expiryDate == null || isStockOut) return null;
    final today = DateTime.now();
    final adjustedExpiryDate = expiryDate!.subtract(Duration(days: shelfLifeDays));
    return adjustedExpiryDate.difference(today).inDays;
  }

  /// Risk seviyesi
  RiskLevel? get riskLevel {
    if (isStockOut || expiryDate == null) return null; // Stok sıfırlandıysa risk yok
    
    final days = daysUntilExpiry;
    if (days == null) return null;
    
    if (days < 0) {
      return RiskLevel.expired; // Süresi geçmiş
    } else if (days <= 3) {
      return RiskLevel.critical; // Kritik (0-3 gün)
    } else if (days <= 7) {
      return RiskLevel.high; // Yüksek risk (4-7 gün)
    } else if (days <= 14) {
      return RiskLevel.medium; // Orta risk (8-14 gün)
    } else {
      return RiskLevel.low; // Düşük risk (14+ gün)
    }
  }

  Product copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    String? category,
    String? imageUrl,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
    DateTime? addedDate,
    int? shelfLifeDays,
    String? notes,
    String? storeId,
    bool? isStockOut,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
      addedDate: addedDate ?? this.addedDate,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      notes: notes ?? this.notes,
      storeId: storeId ?? this.storeId,
      isStockOut: isStockOut ?? this.isStockOut,
    );
  }
}

/// Risk seviyeleri
enum RiskLevel {
  expired,  // Süresi geçmiş
  critical, // Kritik (0-3 gün)
  high,     // Yüksek (4-7 gün)
  medium,   // Orta (8-14 gün)
  low,      // Düşük (14+ gün)
}
