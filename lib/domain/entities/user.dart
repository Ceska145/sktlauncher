/// User entity - Domain layer
class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? storeName;
  final String? storeId;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.storeName,
    this.storeId,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? storeName,
    String? storeId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      storeName: storeName ?? this.storeName,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
