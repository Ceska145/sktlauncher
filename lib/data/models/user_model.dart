import '../../domain/entities/user.dart';

/// User Model - Data layer (Backend entegrasyonu için hazır)
class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.storeName,
    super.storeId,
    required super.createdAt,
  });

  /// JSON'dan model oluştur (Backend API response için)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      storeName: json['store_name'] as String?,
      storeId: json['store_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Model'i JSON'a çevir (Backend API request için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'store_name': storeName,
      'store_id': storeId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Local storage için
  Map<String, dynamic> toLocalStorage() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'store_name': storeName,
      'store_id': storeId,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Local storage'dan oluştur
  factory UserModel.fromLocalStorage(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      storeName: json['store_name'] as String?,
      storeId: json['store_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
    );
  }

  /// Entity'ye dönüştür
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      storeName: storeName,
      storeId: storeId,
      createdAt: createdAt,
    );
  }
}
