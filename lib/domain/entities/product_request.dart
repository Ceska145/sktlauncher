/// Product Request entity - Scenario B
enum RequestStatus {
  pending,   // Onay bekliyor
  approved,  // Onaylandı
  rejected,  // Reddedildi
}

class ProductRequest {
  final String id;
  final String barcode;
  final String name;
  final String? brand;
  final String? category;
  final String photoUrl;
  final String storeId;
  final String userId;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewNote;

  ProductRequest({
    required this.id,
    required this.barcode,
    required this.name,
    this.brand,
    this.category,
    required this.photoUrl,
    required this.storeId,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewNote,
  });

  ProductRequest copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    String? category,
    String? photoUrl,
    String? storeId,
    String? userId,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewNote,
  }) {
    return ProductRequest(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      photoUrl: photoUrl ?? this.photoUrl,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNote: reviewNote ?? this.reviewNote,
    );
  }
}
