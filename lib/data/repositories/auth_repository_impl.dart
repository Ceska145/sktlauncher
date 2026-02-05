import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Auth Repository Implementation - Data layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      // Backend'den giriş yap
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // User ve token'ı parse et
      final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
      final token = response['token'] as String;

      // Local'e kaydet (offline access için)
      await localDataSource.cacheUser(user);
      await localDataSource.cacheToken(token);

      return user.toEntity();
    } catch (e) {
      // Hata yönetimi
      rethrow;
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required String storeName,
  }) async {
    try {
      final response = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        storeName: storeName,
      );

      final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
      final token = response['token'] as String;

      await localDataSource.cacheUser(user);
      await localDataSource.cacheToken(token);

      return user.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = localDataSource.getCachedToken();
      if (token != null) {
        await remoteDataSource.logout(token);
      }
      await localDataSource.clearCache();
    } catch (e) {
      // Logout hatası olsa bile local'i temizle
      await localDataSource.clearCache();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final user = localDataSource.getCachedUser();
    return user?.toEntity();
  }

  @override
  Future<bool> isLoggedIn() async {
    return localDataSource.isLoggedIn();
  }
}
