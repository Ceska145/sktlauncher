import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

/// Product Repository Implementation with local persistence
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Product>> getProducts(String storeId) async {
    try {
      // Önce local'den oku
      final hasLocal = await localDataSource.hasProducts();
      
      if (hasLocal) {
        // Local'de veri varsa onu kullan
        final localProducts = await localDataSource.getAllProducts();
        return localProducts.map((model) => model.toEntity()).toList();
      } else {
        // Local'de yoksa remote'dan al ve local'e kaydet
        final remoteProducts = await remoteDataSource.getProducts(storeId);
        await localDataSource.saveProducts(remoteProducts);
        return remoteProducts.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      // Remote hata verirse local'den dene
      try {
        final localProducts = await localDataSource.getAllProducts();
        if (localProducts.isNotEmpty) {
          return localProducts.map((model) => model.toEntity()).toList();
        }
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        barcode: product.barcode,
        name: product.name,
        brand: product.brand,
        category: product.category,
        imageUrl: product.imageUrl,
        expiryDate: product.expiryDate,
        addedDate: product.addedDate,
        shelfLifeDays: product.shelfLifeDays,
        notes: product.notes,
        storeId: product.storeId,
      );

      // Local'e kaydet
      await localDataSource.saveProduct(productModel);
      
      return productModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        barcode: product.barcode,
        name: product.name,
        brand: product.brand,
        category: product.category,
        imageUrl: product.imageUrl,
        expiryDate: product.expiryDate,
        addedDate: product.addedDate,
        shelfLifeDays: product.shelfLifeDays,
        notes: product.notes,
        storeId: product.storeId,
      );
      
      // Local'i güncelle
      await localDataSource.saveProduct(productModel);
      
      return productModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await localDataSource.deleteProduct(productId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByRiskLevel(
    String storeId,
    RiskLevel riskLevel,
  ) async {
    try {
      final allProducts = await getProducts(storeId);
      return allProducts.where((p) => p.riskLevel == riskLevel).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final allProducts = await localDataSource.getAllProducts();
      final lowerQuery = query.toLowerCase();
      return allProducts
          .where((p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.barcode.toLowerCase().contains(lowerQuery) ||
              (p.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
              (p.category?.toLowerCase().contains(lowerQuery) ?? false))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
