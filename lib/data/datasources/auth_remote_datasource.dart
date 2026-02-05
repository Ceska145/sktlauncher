import 'package:http/http.dart' as http;
import '../models/user_model.dart';

/// Remote Data Source - Backend API entegrasyonu için hazır
class AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSource({
    required this.client,
    this.baseUrl = 'https://api.example.com', // Backend URL'niz hazır olunca değiştirilecek
  });

  /// Login - Backend API call
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // ŞU AN: Mock data (Backend hazır olunca gerçek API call yapılacak)
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Mock login - Test için
    if (email.isNotEmpty && password.length >= 6) {
      return {
        'user': UserModel(
          id: 'user_001',
          email: email,
          name: 'Test Mağaza',
          storeName: 'Test Mağaza A.Ş.',
          storeId: 'store_001',
          createdAt: DateTime.now(),
        ).toJson(),
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      };
    } else {
      throw Exception('Invalid credentials');
    }

    /* Backend hazır olunca bu kod aktif edilecek:
    
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'user': UserModel.fromJson(data['user']).toJson(),
        'token': data['token'] as String,
      };
    } else if (response.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
    */
  }

  /// Register - Backend API call (gelecek için hazır)
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String storeName,
  }) async {
    // Mock register
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'user': UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        storeName: storeName,
        storeId: 'store_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      ).toJson(),
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  /// Logout - Backend API call
  Future<void> logout(String token) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Backend'e logout bildirimi yapılacak
  }
}
