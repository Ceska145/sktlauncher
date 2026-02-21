import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../providers/product_provider.dart';
import '../../domain/entities/notification.dart';
import 'product_detail_screen.dart';

/// Bildirim Geçmişi Ekranı
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final notifications = notificationProvider.notifications;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        elevation: 2,
        actions: [
          // Okunmamış sayısı
          if (notificationProvider.unreadCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Chip(
                  label: Text(
                    '${notificationProvider.unreadCount} yeni',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  labelStyle: const TextStyle(color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          // Menü
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  notificationProvider.markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tüm bildirimler okundu olarak işaretlendi'),
                    ),
                  );
                  break;
                case 'clear_read':
                  _showConfirmDialog(
                    context,
                    'Okunmuş Bildirimleri Sil',
                    'Okunmuş tüm bildirimler silinecek. Emin misiniz?',
                    () {
                      notificationProvider.clearReadNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Okunmuş bildirimler silindi'),
                        ),
                      );
                    },
                  );
                  break;
                case 'clear_all':
                  _showConfirmDialog(
                    context,
                    'Tüm Bildirimleri Sil',
                    'Tüm bildirimler silinecek. Bu işlem geri alınamaz!',
                    () {
                      notificationProvider.clearAllNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tüm bildirimler silindi'),
                        ),
                      );
                    },
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 12),
                    Text('Tümünü Okundu İşaretle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_read',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 12),
                    Text('Okunmuşları Sil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Tümünü Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () async {
                    // Okundu olarak işaretle
                    await notificationProvider.markAsRead(notification.id);

                    // Ürün detayına git
                    final product = productProvider.products.firstWhere(
                      (p) => p.id == notification.productId,
                      orElse: () => productProvider.products.first,
                    );

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    }
                  },
                  onDelete: () {
                    _showConfirmDialog(
                      context,
                      'Bildirimi Sil',
                      'Bu bildirim silinecek. Emin misiniz?',
                      () {
                        notificationProvider.deleteNotification(notification.id);
                      },
                    );
                  },
                  theme: theme,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz Bildirim Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SKT yaklaşan ürünler için bildirim alacaksınız',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

// === NOTIFICATION CARD === //
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ThemeData theme;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case NotificationType.critical:
        typeColor = Colors.red;
        typeIcon = Icons.error;
        break;
      case NotificationType.warning:
        typeColor = Colors.orange;
        typeIcon = Icons.warning_amber;
        break;
      case NotificationType.info:
        typeColor = Colors.blue;
        typeIcon = Icons.info;
        break;
      case NotificationType.reminder:
        typeColor = Colors.green;
        typeIcon = Icons.notifications;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bildirimi Sil'),
            content: const Text('Bu bildirimi silmek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Sil'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Footer
                      Row(
                        children: [
                          // Date
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(notification.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              notification.type.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
