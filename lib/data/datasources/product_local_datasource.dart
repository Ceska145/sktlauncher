import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';

/// Product Local Data Source - Hive ile kalıcı yerel depolama
class ProductLocalDataSource {
  static const String _boxName = 'products';
  Box<String>? _box;

  /// Hive box'ı aç
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(_boxName);
    }
  }

  /// Tüm ürünleri getir
  Future<List<ProductModel>> getAllProducts() async {
    await init();
    final products = <ProductModel>[];
    for (final key in _box!.keys) {
      try {
        final json = _box!.get(key);
        if (json != null) {
          final map = jsonDecode(json) as Map<String, dynamic>;
          products.add(ProductModel.fromLocalStorage(map));
        }
      } catch (_) {
        // Bozuk veri varsa atla
      }
    }
    return products;
  }

  /// Ürün kaydet
  Future<void> saveProduct(ProductModel product) async {
    await init();
    final json = jsonEncode(product.toLocalStorage());
    await _box!.put(product.id, json);
  }

  /// Birden fazla ürün kaydet
  Future<void> saveProducts(List<ProductModel> products) async {
    await init();
    final Map<String, String> entries = {};
    for (final product in products) {
      entries[product.id] = jsonEncode(product.toLocalStorage());
    }
    await _box!.putAll(entries);
  }

  /// Ürün sil
  Future<void> deleteProduct(String productId) async {
    await init();
    await _box!.delete(productId);
  }

  /// Tüm ürünleri sil
  Future<void> clearAll() async {
    await init();
    await _box!.clear();
  }

  /// Ürün var mı kontrol et
  Future<bool> hasProducts() async {
    await init();
    return _box!.isNotEmpty;
  }

  /// Ürün sayısı
  Future<int> getProductCount() async {
    await init();
    return _box!.length;
  }
}
