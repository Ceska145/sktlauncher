import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

/// Sıralama seçenekleri
enum SortOption {
  risk,       // Risk seviyesine göre (varsayılan)
  nameAsc,    // İsim A-Z
  nameDesc,   // İsim Z-A
  expiryAsc,  // SKT yakın → uzak
  expiryDesc, // SKT uzak → yakın
  addedDesc,  // Eklenme tarihi yeni → eski
}

/// Product Provider - State Management
class ProductProvider with ChangeNotifier {
  final ProductRepository productRepository;

  ProductProvider({required this.productRepository});

  List<Product> _allProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filterRiskLevel = 'all';
  String _searchQuery = '';
  SortOption _sortOption = SortOption.risk;
  bool _isSearching = false;

  // Getters
  List<Product> get products {
    List<Product> result = List.from(_allProducts);

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      result = result.where((product) {
        return product.name.toLowerCase().contains(lowerQuery) ||
            product.barcode.toLowerCase().contains(lowerQuery) ||
            (product.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
            (product.category?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Risk filtresi
    if (_filterRiskLevel != 'all') {
      result = result.where((product) {
        if (product.isStockOut) return false; // Stok sıfırlanmış ürünleri gösterme
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

    // Sıralama
    _applySorting(result);

    return result;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterRiskLevel => _filterRiskLevel;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  bool get isSearching => _isSearching;
  int get totalProductCount => _allProducts.length;

  // Risk seviyesine göre ürün sayıları (tüm ürünlerden hesapla - stok sıfırlanmış hariç)
  int get expiredCount => _allProducts.where((p) => !p.isStockOut && p.riskLevel == RiskLevel.expired).length;
  int get criticalCount => _allProducts.where((p) => !p.isStockOut && p.riskLevel == RiskLevel.critical).length;
  int get highCount => _allProducts.where((p) => !p.isStockOut && p.riskLevel == RiskLevel.high).length;
  int get mediumCount => _allProducts.where((p) => !p.isStockOut && p.riskLevel == RiskLevel.medium).length;
  int get lowCount => _allProducts.where((p) => !p.isStockOut && p.riskLevel == RiskLevel.low).length;

  /// Sıralama uygula
  void _applySorting(List<Product> list) {
    switch (_sortOption) {
      case SortOption.risk:
        // Stok sıfırlanmış ürünleri sona at, sonra risk seviyesine göre sırala
        list.sort((a, b) {
          if (a.isStockOut && !b.isStockOut) return 1;
          if (!a.isStockOut && b.isStockOut) return -1;
          if (a.riskLevel == null && b.riskLevel != null) return 1;
          if (a.riskLevel != null && b.riskLevel == null) return -1;
          if (a.riskLevel == null && b.riskLevel == null) return 0;
          return a.riskLevel!.index.compareTo(b.riskLevel!.index);
        });
        break;
      case SortOption.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.expiryAsc:
        list.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
      case SortOption.expiryDesc:
        list.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return b.expiryDate!.compareTo(a.expiryDate!);
        });
        break;
      case SortOption.addedDesc:
        list.sort((a, b) => b.addedDate.compareTo(a.addedDate));
        break;
    }
  }

  /// Ürünleri yükle
  Future<void> loadProducts(String storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts = await productRepository.getProducts(storeId);
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

  /// Arama sorgusu
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Arama modunu aç/kapa
  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  /// Sıralama seçeneğini değiştir
  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  /// Yeni ürün ekle
  Future<bool> addProduct(Product product) async {
    try {
      final addedProduct = await productRepository.addProduct(product);
      _allProducts.add(addedProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ürün güncelle
  Future<bool> updateProduct(Product product) async {
    try {
      await productRepository.updateProduct(product);
      final index = _allProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _allProducts[index] = product;
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
      _allProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Barkod ile ürün bul
  Product? findByBarcode(String barcode) {
    try {
      return _allProducts.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
