import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/product.dart';

/// Bildirim Yönetimi Provider
class NotificationProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  
  NotificationSettings _settings = NotificationSettings();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._prefs) {
    _loadSettings();
    _loadNotifications();
  }

  // Getters
  NotificationSettings get settings => _settings;
  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;

  // === AYARLAR === //

  /// Ayarları yükle
  Future<void> _loadSettings() async {
    final jsonString = _prefs.getString('notification_settings');
    if (jsonString != null) {
      _settings = NotificationSettings.fromJson(jsonDecode(jsonString));
      notifyListeners();
    }
  }

  /// Ayarları kaydet
  Future<void> _saveSettings() async {
    await _prefs.setString('notification_settings', jsonEncode(_settings.toJson()));
    notifyListeners();
  }

  /// Bildirimleri aç/kapa
  Future<void> toggleNotifications(bool enabled) async {
    _settings = _settings.copyWith(enabled: enabled);
    await _saveSettings();
  }

  /// Uyarı günlerini güncelle
  Future<void> updateAlertDays(List<int> days) async {
    _settings = _settings.copyWith(alertDays: days);
    await _saveSettings();
  }

  /// Günlük rapor ayarını güncelle
  Future<void> toggleDailyReport(bool enabled) async {
    _settings = _settings.copyWith(dailyReport: enabled);
    await _saveSettings();
  }

  /// Günlük rapor saatini güncelle
  Future<void> updateDailyReportTime(String time) async {
    _settings = _settings.copyWith(dailyReportTime: time);
    await _saveSettings();
  }

  /// Ses ayarını güncelle
  Future<void> toggleSound(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  /// Titreşim ayarını güncelle
  Future<void> toggleVibration(bool enabled) async {
    _settings = _settings.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
  }

  // === BİLDİRİMLER === //

  /// Bildirimleri yükle
  Future<void> _loadNotifications() async {
    final jsonString = _prefs.getString('notifications');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _notifications = jsonList.map((json) => _notificationFromJson(json)).toList();
      notifyListeners();
    }
  }

  /// Bildirimleri kaydet
  Future<void> _saveNotifications() async {
    final jsonList = _notifications.map((n) => _notificationToJson(n)).toList();
    await _prefs.setString('notifications', jsonEncode(jsonList));
    notifyListeners();
  }

  /// Ürünler için bildirim oluştur
  Future<void> checkAndCreateNotifications(List<Product> products) async {
    if (!_settings.enabled) return;

    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final newNotifications = <AppNotification>[];

    for (final product in products) {
      if (product.expiryDate == null) continue;

      final daysUntilExpiry = product.expiryDate!.difference(now).inDays;

      // Uyarı günlerinden birinde mi?
      if (_settings.alertDays.contains(daysUntilExpiry)) {
        // Bu ürün için bugün zaten bildirim var mı?
        final existingNotification = _notifications.firstWhere(
          (n) => n.productId == product.id && 
                 n.createdAt.day == now.day &&
                 n.createdAt.month == now.month &&
                 n.createdAt.year == now.year,
          orElse: () => AppNotification(
            id: '',
            productId: '',
            productName: '',
            title: '',
            message: '',
            type: NotificationType.info,
            createdAt: DateTime.now(),
            daysUntilExpiry: 0,
          ),
        );

        if (existingNotification.id.isEmpty) {
          // Yeni bildirim oluştur
          final notification = _createNotification(product, daysUntilExpiry);
          newNotifications.add(notification);
        }
      }
    }

    if (newNotifications.isNotEmpty) {
      _notifications.insertAll(0, newNotifications);
      await _saveNotifications();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Bildirim oluştur
  AppNotification _createNotification(Product product, int daysUntilExpiry) {
    NotificationType type;
    String title;
    String message;

    if (daysUntilExpiry <= 1) {
      type = NotificationType.critical;
      title = 'Kritik SKT Uyarısı!';
      message = '${product.name} ürününün son kullanma tarihi ${daysUntilExpiry == 0 ? "bugün" : "yarın"} sona eriyor!';
    } else if (daysUntilExpiry <= 7) {
      type = NotificationType.warning;
      title = 'SKT Uyarısı';
      message = '${product.name} ürününün son kullanma tarihine $daysUntilExpiry gün kaldı.';
    } else if (daysUntilExpiry <= 14) {
      type = NotificationType.info;
      title = 'SKT Hatırlatması';
      message = '${product.name} ürününün SKT\'sine $daysUntilExpiry gün kaldı.';
    } else {
      type = NotificationType.reminder;
      title = 'SKT Bilgisi';
      message = '${product.name} ürününün SKT\'sine $daysUntilExpiry gün kaldı.';
    }

    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: product.id,
      productName: product.name,
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      daysUntilExpiry: daysUntilExpiry,
    );
  }

  /// Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  /// Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
  }

  /// Bildirimi sil
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  /// Tüm bildirimleri sil
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  /// Okunmuş bildirimleri sil
  Future<void> clearReadNotifications() async {
    _notifications.removeWhere((n) => n.isRead);
    await _saveNotifications();
  }

  // === JSON İŞLEMLERİ === //

  Map<String, dynamic> _notificationToJson(AppNotification notification) {
    return {
      'id': notification.id,
      'product_id': notification.productId,
      'product_name': notification.productName,
      'title': notification.title,
      'message': notification.message,
      'type': notification.type.index,
      'created_at': notification.createdAt.millisecondsSinceEpoch,
      'is_read': notification.isRead,
      'days_until_expiry': notification.daysUntilExpiry,
    };
  }

  AppNotification _notificationFromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values[json['type'] as int],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      isRead: json['is_read'] as bool,
      daysUntilExpiry: json['days_until_expiry'] as int,
    );
  }
}
