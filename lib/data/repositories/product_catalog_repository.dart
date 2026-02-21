import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_catalog.dart';

/// Firebase Firestore'dan ortak ürün kataloğunu yöneten repository
class ProductCatalogRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'product_catalog';

  ProductCatalogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Barkoda göre ürün katalog bilgilerini getir
  Future<ProductCatalog?> getProductByBarcode(String barcode) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(barcode).get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }

      return ProductCatalog.fromJson({
        'barcode': barcode,
        ...data,
      });
    } catch (e) {
      print('❌ Katalog getirme hatası: $e');
      return null;
    }
  }

  /// Tüm ürün kataloğunu getir (isteğe bağlı - admin paneli için)
  Future<List<ProductCatalog>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      return querySnapshot.docs.map((doc) {
        return ProductCatalog.fromJson({
          'barcode': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('❌ Katalog listesi getirme hatası: $e');
      return [];
    }
  }

  /// Kategoriye göre ürünleri getir
  Future<List<ProductCatalog>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        return ProductCatalog.fromJson({
          'barcode': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('❌ Kategori filtreleme hatası: $e');
      return [];
    }
  }

  /// Markaya göre ürünleri getir
  Future<List<ProductCatalog>> getProductsByBrand(String brand) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('brand', isEqualTo: brand)
          .get();

      return querySnapshot.docs.map((doc) {
        return ProductCatalog.fromJson({
          'barcode': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('❌ Marka filtreleme hatası: $e');
      return [];
    }
  }

  /// Ürün adına göre arama yap
  Future<List<ProductCatalog>> searchProducts(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      return querySnapshot.docs.map((doc) {
        return ProductCatalog.fromJson({
          'barcode': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('❌ Ürün arama hatası: $e');
      return [];
    }
  }

  /// Kataloga yeni ürün ekle (Admin kullanımı için)
  Future<bool> addProduct(ProductCatalog product) async {
    try {
      await _firestore.collection(_collectionName).doc(product.barcode).set({
        'name': product.name,
        'brand': product.brand,
        'category': product.category,
        'imageUrl': product.imageUrl,
        'description': product.description,
        'unit': product.unit,
        'defaultShelfLifeDays': product.defaultShelfLifeDays,
        'createdAt': product.createdAt.toIso8601String(),
        'updatedAt': product.updatedAt.toIso8601String(),
      });

      return true;
    } catch (e) {
      print('❌ Katalog ekleme hatası: $e');
      return false;
    }
  }

  /// Katalog ürününü güncelle
  Future<bool> updateProduct(ProductCatalog product) async {
    try {
      await _firestore.collection(_collectionName).doc(product.barcode).update({
        'name': product.name,
        'brand': product.brand,
        'category': product.category,
        'imageUrl': product.imageUrl,
        'description': product.description,
        'unit': product.unit,
        'defaultShelfLifeDays': product.defaultShelfLifeDays,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('❌ Katalog güncelleme hatası: $e');
      return false;
    }
  }

  /// Katalogdan ürün sil
  Future<bool> deleteProduct(String barcode) async {
    try {
      await _firestore.collection(_collectionName).doc(barcode).delete();
      return true;
    } catch (e) {
      print('❌ Katalog silme hatası: $e');
      return false;
    }
  }

  /// Katalogdaki toplam ürün sayısını getir
  Future<int> getProductCount() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.size;
    } catch (e) {
      print('❌ Katalog sayısı getirme hatası: $e');
      return 0;
    }
  }

  /// Tüm kategorileri getir
  Future<List<String>> getAllCategories() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      final categories = querySnapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .map((category) => category!)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      print('❌ Kategori listesi getirme hatası: $e');
      return [];
    }
  }

  /// Tüm markaları getir
  Future<List<String>> getAllBrands() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      final brands = querySnapshot.docs
          .map((doc) => doc.data()['brand'] as String?)
          .where((brand) => brand != null && brand.isNotEmpty)
          .map((brand) => brand!)
          .toSet()
          .toList();

      brands.sort();
      return brands;
    } catch (e) {
      print('❌ Marka listesi getirme hatası: $e');
      return [];
    }
  }
}
