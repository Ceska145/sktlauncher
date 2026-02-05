import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

/// Product Provider - State Management
class ProductProvider with ChangeNotifier {
  final ProductRepository productRepository;

  ProductProvider({required this.productRepository});

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filterRiskLevel = 'all'; // all, critical, high, medium, low, expired

  // Getters
  List<Product> get products {
    if (_filterRiskLevel == 'all') {
      return _products;
    }
    
    return _products.where((product) {
      switch (_filterRiskLevel) {
        case 'expired':
          return product.riskLevel == RiskLevel.expired;
        case 'critical':
          return product.riskLevel == RiskLevel.critical;
        case 'high':
          return product.riskLevel == RiskLevel.high;
        case 'medium':
          return product.riskLevel == RiskLevel.medium;
        case 'low':
          return product.riskLevel == RiskLevel.low;
        default:
          return true;
      }
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterRiskLevel => _filterRiskLevel;

  // Risk seviyesine göre ürün sayıları
  int get expiredCount => _products.where((p) => p.riskLevel == RiskLevel.expired).length;
  int get criticalCount => _products.where((p) => p.riskLevel == RiskLevel.critical).length;
  int get highCount => _products.where((p) => p.riskLevel == RiskLevel.high).length;
  int get mediumCount => _products.where((p) => p.riskLevel == RiskLevel.medium).length;
  int get lowCount => _products.where((p) => p.riskLevel == RiskLevel.low).length;

  /// Ürünleri yükle
  Future<void> loadProducts(String storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await productRepository.getProducts(storeId);
      // Risk seviyesine göre sırala (en riskli üstte)
      _products.sort((a, b) {
        final aRisk = a.riskLevel.index;
        final bRisk = b.riskLevel.index;
        return aRisk.compareTo(bRisk);
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Filtre değiştir
  void setFilter(String filter) {
    _filterRiskLevel = filter;
    notifyListeners();
  }

  /// Ürün güncelle
  Future<bool> updateProduct(Product product) async {
    try {
      await productRepository.updateProduct(product);
      // Local listeyi güncelle
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ürün sil
  Future<bool> deleteProduct(String productId) async {
    try {
      await productRepository.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
