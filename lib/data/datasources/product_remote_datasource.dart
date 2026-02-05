import '../models/product_model.dart';

/// Product Remote Data Source - Mock data (Backend hazır olunca gerçek API)
class ProductRemoteDataSource {
  /// Mock ürün listesi (Test için)
  Future<List<ProductModel>> getProducts(String storeId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    
    return [
      // Kritik ürünler (0-3 gün)
      ProductModel(
        id: 'prod_001',
        barcode: '8690632000011',
        name: 'Süt 1L',
        brand: 'Pınar',
        category: 'Süt Ürünleri',
        imageUrl: null,
        expiryDate: now.add(const Duration(days: 5)), // SKT: 5 gün sonra
        addedDate: now.subtract(const Duration(days: 2)),
        shelfLifeDays: 3, // Raftan kalkma: 3 gün önce
        quantity: 12,
        price: 25.50,
        notes: null,
        storeId: storeId,
      ),
      ProductModel(
        id: 'prod_002',
        barcode: '8690632000022',
        name: 'Yoğurt 500g',
        brand: 'Danone',
        category: 'Süt Ürünleri',
        imageUrl: null,
        expiryDate: now.add(const Duration(days: 4)),
        addedDate: now.subtract(const Duration(days: 1)),
        shelfLifeDays: 2,
        quantity: 24,
        price: 15.00,
        notes: null,
        storeId: storeId,
      ),
      
      // Yüksek riskli ürünler (4-7 gün)
      ProductModel(
        id: 'prod_003',
        barcode: '8690632000033',
        name: 'Peynir Beyaz 500g',
        brand: 'Eker',
        category: 'Peynir',
        imageUrl: null,
        expiryDate: now.add(const Duration(days: 10)),
        addedDate: now.subtract(const Duration(days: 5)),
        shelfLifeDays: 5,
        quantity: 8,
        price: 85.00,
        notes: null,
        storeId: storeId,
      ),
      ProductModel(
        id: 'prod_004',
        barcode: '8690632000044',
        name: 'Tereyağı 250g',
        brand: 'Sütaş',
        category: 'Süt Ürünleri',
        imageUrl: null,
        expiryDate: now.add(const Duration(days: 12)),
        addedDate: now.subtract(const Duration(days: 3)),
        shelfLifeDays: 6,
        quantity: 15,
        price: 45.00,
        notes: null,
        storeId: storeId,
      ),

      // Orta riskli ürünler (8-14 gün)
      ProductModel(
        id: 'prod_005',
        barcode: '8690632000055',
        name: 'Ekmek Tam Buğday',
        brand: 'Uno',
        category: 'Unlu Mamuller',
        imageUrl: null,
        expiryDate: now.add(const Duration(days: 15)),
        addedDate: now.subtract(const Duration(days: 1)),
        shelfLifeDays: 5,
        quantity: 30,
        price: 12.00,
        notes: null,
        storeId: storeId,
      ),
      ProductModel(
        id: 'prod_006',
        barcode: '8690632000066',
        name: 'Ayran 250ml',
        brand: 'Pınar',
        category: 'İçecekler',
        imageUrl: null,
        expiryDate: now.add(const Duration(days: 18)),
        addedDate: now.subtract(const Duration(days: 2)),
        shelfLifeDays: 7,
        quantity: 48,
        price: 8.50,
        notes: null,
        storeId: storeId,
      ),

      // Düşük riskli ürünler (14+ gün)
      ProductModel(
        id: 'prod_007',
        barcode: '8690632000077',
        name: 'Makarna Burgu 500g',
        brand: 'Ülker Bizim',
        category: 'Makarna',
        imageUrl: null,
        expiryDate: now.add(const Duration(days: 180)),
        addedDate: now.subtract(const Duration(days: 10)),
        shelfLifeDays: 30,
        quantity: 25,
        price: 18.00,
        notes: null,
        storeId: storeId,
      ),
      ProductModel(
        id: 'prod_008',
        barcode: '8690632000088',
        name: 'Pirinç 1kg',
        brand: 'Baldo',
        category: 'Bakliyat',
        imageUrl: null,
        expiryDate: now.add(const Duration(days: 365)),
        addedDate: now.subtract(const Duration(days: 5)),
        shelfLifeDays: 60,
        quantity: 20,
        price: 35.00,
        notes: null,
        storeId: storeId,
      ),

      // Süresi geçmiş (test için)
      ProductModel(
        id: 'prod_009',
        barcode: '8690632000099',
        name: 'Krema 200ml',
        brand: 'Pınar',
        category: 'Süt Ürünleri',
        imageUrl: null,
        expiryDate: now.subtract(const Duration(days: 2)), // Geçmiş
        addedDate: now.subtract(const Duration(days: 15)),
        shelfLifeDays: 3,
        quantity: 5,
        price: 22.00,
        notes: 'Acil işlem gerekli',
        storeId: storeId,
      ),
    ];
  }

  /// Ürün güncelle
  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return product;
  }

  /// Ürün sil
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
