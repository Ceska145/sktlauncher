import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/product_batch.dart';

/// Parti/Batch Yönetimi Provider
class BatchProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  
  List<ProductBatch> _batches = [];
  bool _isLoading = false;
  String? _errorMessage;

  BatchProvider(this._prefs) {
    _loadBatches();
  }

  // Getters
  List<ProductBatch> get batches => _batches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Belirli bir ürüne ait partileri getir
  List<ProductBatch> getBatchesByProductId(String productId) {
    return _batches
        .where((batch) => batch.productId == productId)
        .toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate)); // SKT'ye göre sırala
  }

  /// En yakın SKT'li partiyi getir
  ProductBatch? getEarliestBatch(String productId) {
    final productBatches = getBatchesByProductId(productId);
    return productBatches.isEmpty ? null : productBatches.first;
  }

  /// Toplam adet hesapla
  int getTotalQuantity(String productId) {
    return getBatchesByProductId(productId)
        .fold(0, (sum, batch) => sum + batch.quantity);
  }

  /// Partileri yükle (public - UI'dan çağrılabilir)
  Future<void> loadBatches(String productId) async {
    await _loadBatches();
  }

  /// Partileri yükle (private - internal kullanım)
  Future<void> _loadBatches() async {
    final jsonString = _prefs.getString('product_batches');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _batches = jsonList.map((json) => ProductBatch.fromJson(json)).toList();
      notifyListeners();
    }
  }

  /// Partileri kaydet
  Future<void> _saveBatches() async {
    final jsonList = _batches.map((batch) => batch.toJson()).toList();
    await _prefs.setString('product_batches', jsonEncode(jsonList));
    notifyListeners();
  }

  /// Yeni parti ekle
  Future<void> addBatch({
    required String productId,
    required DateTime expiryDate,
    required int quantity,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBatch = ProductBatch(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        expiryDate: expiryDate,
        quantity: quantity,
        addedDate: DateTime.now(),
        notes: notes,
      );

      _batches.add(newBatch);
      await _saveBatches();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parti güncelle
  Future<void> updateBatch(ProductBatch batch) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _batches.indexWhere((b) => b.id == batch.id);
      if (index != -1) {
        _batches[index] = batch;
        await _saveBatches();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parti sil
  Future<void> deleteBatch(String batchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _batches.removeWhere((b) => b.id == batchId);
      await _saveBatches();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parti adedini güncelle (azalt/arttır)
  Future<void> updateQuantity(String batchId, int newQuantity) async {
    if (newQuantity < 0) return;

    final index = _batches.indexWhere((b) => b.id == batchId);
    if (index != -1) {
      if (newQuantity == 0) {
        // Adet 0 ise partiyi sil
        await deleteBatch(batchId);
      } else {
        _batches[index] = _batches[index].copyWith(quantity: newQuantity);
        await _saveBatches();
      }
    }
  }

  /// Belirli bir üründeki tüm partileri sil
  Future<void> deleteAllBatchesForProduct(String productId) async {
    _batches.removeWhere((b) => b.productId == productId);
    await _saveBatches();
  }
}
