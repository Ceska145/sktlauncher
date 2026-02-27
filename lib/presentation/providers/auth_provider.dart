import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth Provider - State Management
class AuthProvider with ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository}) {
    _checkLoginStatus();
  }

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  /// Login durumunu kontrol et - OFFLINE FIRST
  Future<void> _checkLoginStatus() async {
    try {
      // Sadece local cache kontrol et (backend'e sorma)
      _isLoggedIn = await authRepository.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await authRepository.getCurrentUser();
      }
    } catch (e) {
      // Hata durumunda offline mod
      if (kDebugMode) {
        print('Login status check error: $e');
      }
      _isLoggedIn = false;
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Login işlemi
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await authRepository.login(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Register işlemi
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String storeName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await authRepository.register(
        email: email,
        password: password,
        name: name,
        storeName: storeName,
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Logout işlemi
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.logout();
      _currentUser = null;
      _isLoggedIn = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
