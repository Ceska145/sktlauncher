/// Ortak Ürün Kataloğu Entity
/// Tüm mağazalar için paylaşılan ürün bilgileri
class ProductCatalog {
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final String description;
  final String unit;
  final int defaultShelfLifeDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductCatalog({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl = '',
    this.description = '',
    this.unit = '',
    this.defaultShelfLifeDays = 7,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// JSON'dan ProductCatalog oluştur
  factory ProductCatalog.fromJson(Map<String, dynamic> json) {
    return ProductCatalog(
      barcode: json['barcode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      defaultShelfLifeDays: json['defaultShelfLifeDays'] as int? ?? 7,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// ProductCatalog'u JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
      'unit': unit,
      'defaultShelfLifeDays': defaultShelfLifeDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Kopya oluştur
  ProductCatalog copyWith({
    String? barcode,
    String? name,
    String? brand,
    String? category,
    String? imageUrl,
    String? description,
    String? unit,
    int? defaultShelfLifeDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductCatalog(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      defaultShelfLifeDays: defaultShelfLifeDays ?? this.defaultShelfLifeDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductCatalog(barcode: $barcode, name: $name, brand: $brand, category: $category)';
  }
}
