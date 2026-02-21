import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Mağaza Ayarları Ekranı
class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _storeAddressController;
  late TextEditingController _storePhoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    _storeNameController = TextEditingController(text: user?.storeName ?? '');
    _storeAddressController = TextEditingController(text: 'Merkez Mağaza, İstanbul');
    _storePhoneController = TextEditingController(text: '+90 555 123 4567');
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza Bilgileri'),
        elevation: 2,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Düzenle',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // === MAĞAZA HEADER === //
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Mağaza İkonu
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.store,
                      size: 50,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mağaza Adı
                  Text(
                    user?.storeName ?? 'Mağaza Adı',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Store ID
                  Text(
                    'ID: ${user?.storeId ?? 'store_001'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // === FORM === //
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mağaza Adı
                    _buildTextField(
                      controller: _storeNameController,
                      label: 'Mağaza Adı',
                      icon: Icons.store_outlined,
                      enabled: _isEditing,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    // Adres
                    _buildTextField(
                      controller: _storeAddressController,
                      label: 'Adres',
                      icon: Icons.location_on_outlined,
                      enabled: _isEditing,
                      maxLines: 2,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    // Telefon
                    _buildTextField(
                      controller: _storePhoneController,
                      label: 'Telefon',
                      icon: Icons.phone_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      theme: theme,
                    ),

                    const SizedBox(height: 32),

                    // === KAYDET/İPTAL BUTONLARI === //
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  // Reset form
                                  _storeNameController.text = user?.storeName ?? '';
                                  _storeAddressController.text = 'Merkez Mağaza, İstanbul';
                                  _storePhoneController.text = '+90 555 123 4567';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: colorScheme.outline),
                              ),
                              child: const Text('İptal'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveStoreInfo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Kaydet'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // === İSTATİSTİK KARTLARI === //
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mağaza İstatistikleri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.inventory_2,
                          title: 'Toplam Ürün',
                          value: '42',
                          color: colorScheme.primary,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.category,
                          title: 'Kategori',
                          value: '8',
                          color: Colors.blue,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.warning_amber,
                          title: 'Riskli',
                          value: '5',
                          color: Colors.orange,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.check_circle,
                          title: 'Güvenli',
                          value: '37',
                          color: Colors.green,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // === MAĞAZA AYARLARI === //
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mağaza Ayarları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSettingTile(
                    icon: Icons.notifications_active,
                    title: 'Otomatik Bildirimler',
                    subtitle: 'SKT yaklaşan ürünler için',
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement notification toggle
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bildirim ayarları güncellendi'),
                        ),
                      );
                    },
                    theme: theme,
                  ),
                  
                  _buildSettingTile(
                    icon: Icons.analytics,
                    title: 'Günlük Raporlar',
                    subtitle: 'Her gün rapor gönder',
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement daily reports
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rapor ayarları güncellendi'),
                        ),
                      );
                    },
                    theme: theme,
                  ),
                  
                  _buildSettingTile(
                    icon: Icons.auto_delete,
                    title: 'Otomatik Arşivleme',
                    subtitle: 'Eski ürünleri arşivle',
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement auto archive
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Arşivleme ayarları güncellendi'),
                        ),
                      );
                    },
                    theme: theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required ThemeData theme,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label boş bırakılamaz';
        }
        return null;
      },
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: ListTile(
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
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _saveStoreInfo() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save store info to backend
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mağaza bilgileri başarıyla güncellendi'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
