/// User entity - Domain layer
class User {
  final String id;
  final String email;
  final String name;
  final String? storeName;
  final String? storeId;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.storeName,
    this.storeId,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? storeName,
    String? storeId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      storeName: storeName ?? this.storeName,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
