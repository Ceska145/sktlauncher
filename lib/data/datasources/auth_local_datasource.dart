import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

/// Local Data Source - Offline-first için
class AuthLocalDataSource {
  static const String _keyUser = 'current_user';
  static const String _keyToken = 'auth_token';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSource({required this.sharedPreferences});

  /// Kullanıcıyı local'e kaydet
  Future<void> cacheUser(UserModel user) async {
    final userJson = jsonEncode(user.toLocalStorage());
    await sharedPreferences.setString(_keyUser, userJson);
  }

  /// Local'den kullanıcıyı getir
  UserModel? getCachedUser() {
    final userJson = sharedPreferences.getString(_keyUser);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromLocalStorage(userMap);
    }
    return null;
  }

  /// Token'ı kaydet
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(_keyToken, token);
  }

  /// Token'ı getir
  String? getCachedToken() {
    return sharedPreferences.getString(_keyToken);
  }

  /// Çıkış yap - tüm verileri temizle
  Future<void> clearCache() async {
    await sharedPreferences.remove(_keyUser);
    await sharedPreferences.remove(_keyToken);
  }

  /// Kullanıcı oturum açmış mı?
  bool isLoggedIn() {
    return getCachedUser() != null && getCachedToken() != null;
  }
}
