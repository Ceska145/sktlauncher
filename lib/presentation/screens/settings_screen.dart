import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'profile_screen.dart';
import 'store_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'export_import_screen.dart';

/// Ayarlar Ekranı
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        elevation: 2,
      ),
      body: ListView(
        children: [
          // === GÖRÜNÜM AYARLARI === //
          _SectionHeader(title: 'Görünüm', theme: theme),
          
          // Dark Mode Toggle
          _SettingsTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: 'Karanlık Mod',
            subtitle: isDark ? 'Açık' : 'Kapalı',
            trailing: Switch(
              value: isDark,
              onChanged: (_) => themeProvider.toggleDarkMode(),
              activeTrackColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),

          // View Mode Toggle (Liste/Grid)
          _SettingsTile(
            icon: themeProvider.viewMode == ViewMode.list
                ? Icons.view_list
                : Icons.grid_view,
            title: 'Görünüm Modu',
            subtitle: themeProvider.viewMode == ViewMode.list
                ? 'Liste Görünümü'
                : 'Grid Görünümü',
            trailing: IconButton(
              icon: Icon(
                themeProvider.viewMode == ViewMode.list
                    ? Icons.grid_view
                    : Icons.view_list,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => themeProvider.toggleViewMode(),
            ),
            onTap: () => themeProvider.toggleViewMode(),
            theme: theme,
          ),

          const Divider(),

          // === HESAP AYARLARI === //
          _SectionHeader(title: 'Hesap', theme: theme),

          // Profil
          _SettingsTile(
            icon: Icons.person,
            title: 'Profil',
            subtitle: authProvider.currentUser?.name ?? 'Kullanıcı',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            theme: theme,
          ),

          // Mağaza Bilgileri
          _SettingsTile(
            icon: Icons.store,
            title: 'Mağaza',
            subtitle: authProvider.currentUser?.storeName ?? 'Mağaza Adı',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoreSettingsScreen(),
                ),
              );
            },
            theme: theme,
          ),

          const Divider(),

          // === BİLDİRİM AYARLARI === //
          _SectionHeader(title: 'Bildirimler', theme: theme),

          _SettingsTile(
            icon: Icons.notifications,
            title: 'SKT Bildirimleri',
            subtitle: notificationProvider.settings.enabled 
                ? 'Bildirimler aktif' 
                : 'Bildirimler kapalı',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notificationProvider.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
            theme: theme,
          ),

          const Divider(),

          // === VERİ YÖNETİMİ === //
          _SectionHeader(title: 'Veri Yönetimi', theme: theme),

          _SettingsTile(
            icon: Icons.import_export,
            title: 'Dışa/İçe Aktar',
            subtitle: 'CSV formatında veri transferi',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportImportScreen(),
                ),
              );
            },
            theme: theme,
          ),

          _SettingsTile(
            icon: Icons.backup,
            title: 'Yedekleme',
            subtitle: 'Verilerinizi yedekleyin',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Yedekleme ekranı
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yedekleme özelliği yakında eklenecek')),
              );
            },
            theme: theme,
          ),

          _SettingsTile(
            icon: Icons.cloud_download,
            title: 'Geri Yükleme',
            subtitle: 'Yedekten geri yükle',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Geri yükleme ekranı
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geri yükleme özelliği yakında eklenecek')),
              );
            },
            theme: theme,
          ),

          _SettingsTile(
            icon: Icons.delete_forever,
            title: 'Verileri Temizle',
            subtitle: 'Tüm verileri sil',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showClearDataDialog(context, theme);
            },
            theme: theme,
          ),

          const Divider(),

          // === HAKKINDA === //
          _SectionHeader(title: 'Hakkında', theme: theme),

          _SettingsTile(
            icon: Icons.info,
            title: 'Uygulama Bilgisi',
            subtitle: 'Sürüm 1.0.0',
            theme: theme,
          ),

          _SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Gizlilik Politikası',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gizlilik politikası yakında eklenecek')),
              );
            },
            theme: theme,
          ),

          const SizedBox(height: 20),

          // === ÇIKIŞ === //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Temizle'),
        content: const Text(
          'Tüm ürün ve kullanıcı verileri silinecek. Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement clear data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Veriler temizlendi'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
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
