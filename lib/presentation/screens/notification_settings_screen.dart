import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import 'notifications_screen.dart';

/// Bildirim Ayarları Ekranı
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final settings = notificationProvider.settings;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        elevation: 2,
        actions: [
          // Bildirim Geçmişi Butonu
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                tooltip: 'Bildirim Geçmişi',
              ),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          // === ANA AYARLAR === //
          _SectionHeader(title: 'Genel Ayarlar', theme: theme),

          _SettingsTile(
            icon: Icons.notifications_active,
            title: 'Bildirimleri Etkinleştir',
            subtitle: settings.enabled
                ? 'Bildirimler aktif'
                : 'Bildirimler kapalı',
            trailing: Switch(
              value: settings.enabled,
              onChanged: (value) {
                notificationProvider.toggleNotifications(value);
              },
              activeTrackColor: colorScheme.primary,
            ),
            theme: theme,
          ),

          if (settings.enabled) ...[
            _SettingsTile(
              icon: Icons.volume_up,
              title: 'Bildirim Sesi',
              subtitle: settings.soundEnabled ? 'Açık' : 'Kapalı',
              trailing: Switch(
                value: settings.soundEnabled,
                onChanged: (value) {
                  notificationProvider.toggleSound(value);
                },
                activeTrackColor: colorScheme.primary,
              ),
              theme: theme,
            ),

            _SettingsTile(
              icon: Icons.vibration,
              title: 'Titreşim',
              subtitle: settings.vibrationEnabled ? 'Açık' : 'Kapalı',
              trailing: Switch(
                value: settings.vibrationEnabled,
                onChanged: (value) {
                  notificationProvider.toggleVibration(value);
                },
                activeTrackColor: colorScheme.primary,
              ),
              theme: theme,
            ),
          ],

          const Divider(),

          // === UYARI ZAMANLARI === //
          _SectionHeader(title: 'SKT Uyarı Zamanları', theme: theme),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Son kullanma tarihinden kaç gün önce uyarı almak istiyorsunuz?',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),

          _AlertDayOption(
            days: 1,
            label: '1 Gün Önce',
            description: 'Kritik uyarı',
            isSelected: settings.alertDays.contains(1),
            onChanged: (selected) {
              _updateAlertDays(context, settings.alertDays, 1, selected);
            },
            theme: theme,
          ),

          _AlertDayOption(
            days: 3,
            label: '3 Gün Önce',
            description: 'Uyarı',
            isSelected: settings.alertDays.contains(3),
            onChanged: (selected) {
              _updateAlertDays(context, settings.alertDays, 3, selected);
            },
            theme: theme,
          ),

          _AlertDayOption(
            days: 7,
            label: '7 Gün Önce (1 hafta)',
            description: 'Bilgi',
            isSelected: settings.alertDays.contains(7),
            onChanged: (selected) {
              _updateAlertDays(context, settings.alertDays, 7, selected);
            },
            theme: theme,
          ),

          _AlertDayOption(
            days: 14,
            label: '14 Gün Önce (2 hafta)',
            description: 'Hatırlatma',
            isSelected: settings.alertDays.contains(14),
            onChanged: (selected) {
              _updateAlertDays(context, settings.alertDays, 14, selected);
            },
            theme: theme,
          ),

          _AlertDayOption(
            days: 30,
            label: '30 Gün Önce (1 ay)',
            description: 'Erken hatırlatma',
            isSelected: settings.alertDays.contains(30),
            onChanged: (selected) {
              _updateAlertDays(context, settings.alertDays, 30, selected);
            },
            theme: theme,
          ),

          const Divider(),

          // === GÜNLÜK RAPOR === //
          _SectionHeader(title: 'Günlük Rapor', theme: theme),

          _SettingsTile(
            icon: Icons.analytics,
            title: 'Günlük Rapor',
            subtitle: settings.dailyReport
                ? 'Her gün ${settings.dailyReportTime} \'da'
                : 'Kapalı',
            trailing: Switch(
              value: settings.dailyReport,
              onChanged: (value) {
                notificationProvider.toggleDailyReport(value);
              },
              activeTrackColor: colorScheme.primary,
            ),
            theme: theme,
          ),

          if (settings.dailyReport)
            _SettingsTile(
              icon: Icons.access_time,
              title: 'Rapor Saati',
              subtitle: settings.dailyReportTime,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showTimePickerDialog(context, settings.dailyReportTime);
              },
              theme: theme,
            ),

          const Divider(),

          // === BİLGİ === //
          _SectionHeader(title: 'Bilgi', theme: theme),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bildirimler Nasıl Çalışır?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seçtiğiniz günlerde, son kullanma tarihi yaklaşan ürünler için otomatik bildirim alırsınız. '
                          'Örneğin "3 Gün Önce" seçeneğini işaretlerseniz, SKT\'si 3 gün sonra bitecek ürünler için bildirim gelir.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _updateAlertDays(
    BuildContext context,
    List<int> currentDays,
    int day,
    bool selected,
  ) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final newDays = List<int>.from(currentDays);

    if (selected) {
      if (!newDays.contains(day)) {
        newDays.add(day);
      }
    } else {
      newDays.remove(day);
    }

    // En az bir gün seçili olmalı
    if (newDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir uyarı zamanı seçmelisiniz'),
        ),
      );
      return;
    }

    newDays.sort();
    notificationProvider.updateAlertDays(newDays);
  }

  Future<void> _showTimePickerDialog(BuildContext context, String currentTime) async {
    final parts = currentTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      final newTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      Provider.of<NotificationProvider>(context, listen: false)
          .updateDailyReportTime(newTime);
    }
  }
}

// === SECTION HEADER === //
class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// === SETTINGS TILE === //
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

// === ALERT DAY OPTION === //
class _AlertDayOption extends StatelessWidget {
  final int days;
  final String label;
  final String description;
  final bool isSelected;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;

  const _AlertDayOption({
    required this.days,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) => onChanged(value ?? false),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        activeColor: theme.colorScheme.primary,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
