import '../../domain/entities/product.dart';

/// Product Model - Data layer
class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.barcode,
    required super.name,
    super.brand,
    super.category,
    super.imageUrl,
    super.expiryDate,
    required super.addedDate,
    required super.shelfLifeDays,
    super.notes,
    required super.storeId,
    super.isStockOut,
  });

  /// JSON'dan model oluştur (Backend API response için)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      addedDate: DateTime.parse(json['added_date'] as String),
      shelfLifeDays: json['shelf_life_days'] as int,
      notes: json['notes'] as String?,
      storeId: json['store_id'] as String,
      isStockOut: json['is_stock_out'] as bool? ?? false,
    );
  }

  /// Model'i JSON'a çevir (Backend API request için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'category': category,
      'image_url': imageUrl,
      'expiry_date': expiryDate?.toIso8601String(),
      'added_date': addedDate.toIso8601String(),
      'shelf_life_days': shelfLifeDays,
      'notes': notes,
      'store_id': storeId,
      'is_stock_out': isStockOut,
    };
  }

  /// Local storage için
  Map<String, dynamic> toLocalStorage() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'category': category,
      'image_url': imageUrl,
      'expiry_date': expiryDate?.millisecondsSinceEpoch,
      'added_date': addedDate.millisecondsSinceEpoch,
      'shelf_life_days': shelfLifeDays,
      'notes': notes,
      'store_id': storeId,
      'is_stock_out': isStockOut,
    };
  }

  /// Local storage'dan oluştur
  factory ProductModel.fromLocalStorage(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      expiryDate: json['expiry_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expiry_date'] as int)
          : null,
      addedDate: DateTime.fromMillisecondsSinceEpoch(json['added_date'] as int),
      shelfLifeDays: json['shelf_life_days'] as int,
      notes: json['notes'] as String?,
      storeId: json['store_id'] as String,
      isStockOut: json['is_stock_out'] as bool? ?? false,
    );
  }

  /// Entity'ye dönüştür
  Product toEntity() {
    return Product(
      id: id,
      barcode: barcode,
      name: name,
      brand: brand,
      category: category,
      imageUrl: imageUrl,
      expiryDate: expiryDate,
      addedDate: addedDate,
      shelfLifeDays: shelfLifeDays,
      notes: notes,
      storeId: storeId,
      isStockOut: isStockOut,
    );
  }
}
