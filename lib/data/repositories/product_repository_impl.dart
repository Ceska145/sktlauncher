import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Product Repository Implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts(String storeId) async {
    try {
      final productModels = await remoteDataSource.getProducts(storeId);
      return productModels.map((model) => model.toEntity()).toList();
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
        quantity: product.quantity,
        price: product.price,
        notes: product.notes,
        storeId: product.storeId,
      );
      
      final updated = await remoteDataSource.updateProduct(productModel);
      return updated.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await remoteDataSource.deleteProduct(productId);
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
}
