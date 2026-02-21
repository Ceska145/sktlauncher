import '../../domain/entities/product.dart';

/// Product Repository Interface
abstract class ProductRepository {
  Future<List<Product>> getProducts(String storeId);
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
  Future<List<Product>> getProductsByRiskLevel(String storeId, RiskLevel riskLevel);
  Future<List<Product>> searchProducts(String query);
}
