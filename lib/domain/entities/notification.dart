/// Notification entity - Domain layer
class AppNotification {
  final String id;
  final String productId;
  final String productName;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final int daysUntilExpiry;

  AppNotification({
    required this.id,
    required this.productId,
    required this.productName,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    required this.daysUntilExpiry,
  });

  AppNotification copyWith({
    String? id,
    String? productId,
    String? productName,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    int? daysUntilExpiry,
  }) {
    return AppNotification(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
    );
  }
}

/// Bildirim Tipleri
enum NotificationType {
  critical,  // 0-1 gün kala - Kritik
  warning,   // 2-7 gün kala - Uyarı
  info,      // 8-14 gün kala - Bilgi
  reminder,  // 15-30 gün kala - Hatırlatma
}

/// Bildirim Tipi Extension
extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.critical:
        return 'Kritik';
      case NotificationType.warning:
        return 'Uyarı';
      case NotificationType.info:
        return 'Bilgi';
      case NotificationType.reminder:
        return 'Hatırlatma';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.critical:
        return '🚨';
      case NotificationType.warning:
        return '⚠️';
      case NotificationType.info:
        return 'ℹ️';
      case NotificationType.reminder:
        return '🔔';
    }
  }
}
