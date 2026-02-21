import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/product_history.dart';

/// Ürün geçmişi yönetimi provider
class HistoryProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  
  List<ProductHistory> _histories = [];
  bool _isLoading = false;
  String? _errorMessage;

  HistoryProvider(this._prefs) {
    _loadHistories();
  }

  // Getters
  List<ProductHistory> get histories => _histories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Belirli bir ürüne ait geçmişi getir
  List<ProductHistory> getHistoriesByProductId(String productId) {
    return _histories
        .where((h) => h.productId == productId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Yeniden eskiye
  }

  /// Son N günlük geçmişi getir
  List<ProductHistory> getRecentHistories({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _histories
        .where((h) => h.timestamp.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Belirli tip geçmişleri getir
  List<ProductHistory> getHistoriesByType(ProductHistoryType type) {
    return _histories
        .where((h) => h.type == type)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Geçmişleri yükle
  Future<void> _loadHistories() async {
    final jsonString = _prefs.getString('product_histories');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _histories = jsonList.map((json) => ProductHistory.fromJson(json)).toList();
      notifyListeners();
    }
  }

  /// Geçmişleri kaydet
  Future<void> _saveHistories() async {
    final jsonList = _histories.map((h) => h.toJson()).toList();
    await _prefs.setString('product_histories', jsonEncode(jsonList));
    notifyListeners();
  }

  /// Yeni geçmiş kaydı ekle
  Future<void> addHistory({
    required String productId,
    required String productName,
    required ProductHistoryType type,
    required String description,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? userName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newHistory = ProductHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        productName: productName,
        type: type,
        description: description,
        oldValue: oldValue,
        newValue: newValue,
        timestamp: DateTime.now(),
        userName: userName,
      );

      _histories.add(newHistory);
      await _saveHistories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ürün oluşturma geçmişi
  Future<void> addCreatedHistory({
    required String productId,
    required String productName,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.created,
      description: 'Ürün sisteme eklendi',
      userName: userName,
    );
  }

  /// Ürün güncelleme geçmişi
  Future<void> addUpdatedHistory({
    required String productId,
    required String productName,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.updated,
      description: 'Ürün bilgileri güncellendi',
      oldValue: oldValue,
      newValue: newValue,
      userName: userName,
    );
  }

  /// SKT güncelleme geçmişi
  Future<void> addExpiryUpdatedHistory({
    required String productId,
    required String productName,
    required String oldDate,
    required String newDate,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.expiryUpdated,
      description: 'Son kullanma tarihi güncellendi: $oldDate → $newDate',
      oldValue: {'expiryDate': oldDate},
      newValue: {'expiryDate': newDate},
      userName: userName,
    );
  }

  /// Stok sıfırlama geçmişi
  Future<void> addStockedOutHistory({
    required String productId,
    required String productName,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.stockedOut,
      description: 'Ürün stoğu sıfırlandı',
      userName: userName,
    );
  }

  /// Parti ekleme geçmişi
  Future<void> addBatchAddedHistory({
    required String productId,
    required String productName,
    required String batchInfo,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.batchAdded,
      description: 'Yeni parti eklendi: $batchInfo',
      userName: userName,
    );
  }

  /// Parti güncelleme geçmişi
  Future<void> addBatchUpdatedHistory({
    required String productId,
    required String productName,
    required String batchInfo,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.batchUpdated,
      description: 'Parti güncellendi: $batchInfo',
      userName: userName,
    );
  }

  /// Parti silme geçmişi
  Future<void> addBatchDeletedHistory({
    required String productId,
    required String productName,
    required String batchInfo,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.batchDeleted,
      description: 'Parti silindi: $batchInfo',
      userName: userName,
    );
  }

  /// Risk değişikliği geçmişi
  Future<void> addRiskChangedHistory({
    required String productId,
    required String productName,
    required String oldRisk,
    required String newRisk,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.riskChanged,
      description: 'Risk durumu değişti: $oldRisk → $newRisk',
      oldValue: {'risk': oldRisk},
      newValue: {'risk': newRisk},
      userName: userName,
    );
  }

  /// Ürün silme geçmişi
  Future<void> addDeletedHistory({
    required String productId,
    required String productName,
    String? userName,
  }) async {
    await addHistory(
      productId: productId,
      productName: productName,
      type: ProductHistoryType.deleted,
      description: 'Ürün sistemden silindi',
      userName: userName,
    );
  }

  /// Belirli ürüne ait tüm geçmişi sil
  Future<void> deleteHistoriesForProduct(String productId) async {
    _histories.removeWhere((h) => h.productId == productId);
    await _saveHistories();
  }

  /// Tüm geçmişi temizle
  Future<void> clearAllHistories() async {
    _histories.clear();
    await _saveHistories();
  }

  /// Belirli tarihten eski geçmişleri temizle
  Future<void> clearOldHistories({int olderThanDays = 90}) async {
    final cutoff = DateTime.now().subtract(Duration(days: olderThanDays));
    _histories.removeWhere((h) => h.timestamp.isBefore(cutoff));
    await _saveHistories();
  }
}
