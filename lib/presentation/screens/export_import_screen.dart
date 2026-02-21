import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../../core/utils/csv_helper.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/product.dart';

class ExportImportScreen extends StatefulWidget {
  const ExportImportScreen({super.key});

  @override
  State<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  bool _isProcessing = false;
  String? _statusMessage;
  int _processedCount = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📤📥 Export/Import'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Açıklama kartı
            _buildInfoCard(
              colorScheme: colorScheme,
              icon: Icons.info_outline,
              title: 'Export/Import Nedir?',
              description:
                  'Ürün verilerinizi CSV formatında dışa aktarabilir veya '
                  'başka bir kaynaktan CSV ile içe aktarabilirsiniz. '
                  'Excel, Google Sheets gibi programlarla uyumludur.',
            ),
            const SizedBox(height: 24),

            // EXPORT Bölümü
            _buildSectionTitle('📤 Dışa Aktarma', colorScheme),
            const SizedBox(height: 12),

            // Tüm ürünleri export et
            _buildActionCard(
              colorScheme: colorScheme,
              icon: Icons.file_download,
              title: 'Tüm Ürünleri Dışa Aktar',
              subtitle: '${productProvider.totalProductCount} ürün',
              buttonText: 'CSV İndir',
              buttonColor: Colors.green,
              onPressed: _isProcessing ? null : () => _exportAll(productProvider),
            ),
            const SizedBox(height: 12),

            // Sadece kritik ürünleri export et
            _buildActionCard(
              colorScheme: colorScheme,
              icon: Icons.warning_amber,
              title: 'Sadece Kritik Ürünleri Dışa Aktar',
              subtitle: '${productProvider.criticalCount + productProvider.expiredCount} ürün',
              buttonText: 'CSV İndir',
              buttonColor: Colors.orange,
              onPressed: _isProcessing ? null : () => _exportCritical(productProvider),
            ),
            const SizedBox(height: 24),

            // IMPORT Bölümü
            _buildSectionTitle('📥 İçe Aktarma', colorScheme),
            const SizedBox(height: 12),

            // CSV'den içe aktar
            _buildActionCard(
              colorScheme: colorScheme,
              icon: Icons.file_upload,
              title: 'CSV Dosyasından İçe Aktar',
              subtitle: 'Bilgisayarınızdan CSV dosyası seçin',
              buttonText: 'Dosya Seç',
              buttonColor: Colors.blue,
              onPressed: _isProcessing ? null : () => _importCsv(productProvider),
            ),
            const SizedBox(height: 12),

            // Template indir
            _buildActionCard(
              colorScheme: colorScheme,
              icon: Icons.download,
              title: 'Örnek CSV Şablonu İndir',
              subtitle: 'Boş şablon veya örnek verilerle',
              buttonText: 'Şablon İndir',
              buttonColor: Colors.purple,
              onPressed: _isProcessing ? null : _downloadTemplate,
            ),
            const SizedBox(height: 24),

            // İşlem durumu
            if (_isProcessing || _statusMessage != null)
              _buildStatusCard(colorScheme),

            const SizedBox(height: 16),

            // Kullanım talimatları
            _buildInstructionsCard(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInfoCard({
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: buttonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: buttonColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isProcessing
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : _statusMessage?.contains('✅') == true
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isProcessing
              ? colorScheme.primary.withValues(alpha: 0.3)
              : _statusMessage?.contains('✅') == true
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            Icon(
              _statusMessage?.contains('✅') == true
                  ? Icons.check_circle
                  : Icons.error,
              size: 48,
              color: _statusMessage?.contains('✅') == true
                  ? Colors.green
                  : Colors.red,
            ),
          const SizedBox(height: 12),
          Text(
            _isProcessing
                ? 'İşleniyor... ($_processedCount)'
                : _statusMessage ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Kullanım Talimatları',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            colorScheme,
            '1',
            'Export: CSV dosyasını Excel, Google Sheets ile açabilirsiniz',
          ),
          _buildInstructionItem(
            colorScheme,
            '2',
            'Import: CSV dosyasında değişiklik yapıp tekrar yükleyebilirsiniz',
          ),
          _buildInstructionItem(
            colorScheme,
            '3',
            'Şablon: Örnek CSV indirip kendi verilerinizle doldurun',
          ),
          _buildInstructionItem(
            colorScheme,
            '4',
            'Tarih formatı: GG.AA.YYYY (örn: 15.12.2026)',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(
    ColorScheme colorScheme,
    String number,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Export tüm ürünler
  Future<void> _exportAll(ProductProvider productProvider) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = null;
      _processedCount = 0;
    });

    try {
      final products = productProvider.products;
      final csvContent = CsvHelper.productsToCsv(products);
      final filename = CsvHelper.generateFilename(suffix: 'tum_urunler');
      
      await CsvHelper.downloadCsv(csvContent, filename);

      setState(() {
        _isProcessing = false;
        _statusMessage = '✅ ${products.length} ürün başarıyla dışa aktarıldı!';
        _processedCount = products.length;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '❌ Hata: $e';
      });
    }
  }

  // Export sadece kritik ürünler
  Future<void> _exportCritical(ProductProvider productProvider) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = null;
      _processedCount = 0;
    });

    try {
      final criticalProducts = productProvider.products
          .where((p) =>
              p.riskLevel == RiskLevel.expired ||
              p.riskLevel == RiskLevel.critical)
          .toList();

      if (criticalProducts.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '⚠️ Kritik ürün bulunamadı!';
        });
        return;
      }

      final csvContent = CsvHelper.productsToCsv(criticalProducts);
      final filename = CsvHelper.generateFilename(suffix: 'kritik_urunler');
      
      await CsvHelper.downloadCsv(csvContent, filename);

      setState(() {
        _isProcessing = false;
        _statusMessage =
            '✅ ${criticalProducts.length} kritik ürün başarıyla dışa aktarıldı!';
        _processedCount = criticalProducts.length;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '❌ Hata: $e';
      });
    }
  }

  // CSV'den içe aktar
  Future<void> _importCsv(ProductProvider productProvider) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = null;
      _processedCount = 0;
    });

    try {
      final csvContent = await CsvHelper.pickAndReadCsvFile();

      if (csvContent == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '⚠️ Dosya seçilmedi';
        });
        return;
      }

      final parsedData = CsvHelper.parseCsv(csvContent);

      if (parsedData.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '⚠️ CSV dosyası boş veya geçersiz';
        });
        return;
      }

      // Onay diyalogu
      final confirmed = await _showImportConfirmDialog(parsedData.length);
      if (confirmed != true) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '❌ İçe aktarma iptal edildi';
        });
        return;
      }

      // Ürünleri ekle
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final storeId = authProvider.currentUser?.storeId ?? 'store_001';

      int successCount = 0;
      for (var data in parsedData) {
        try {
          // Store ID'yi güncelle
          data['storeId'] = storeId;
          
          // Product entity oluştur ve ekle
          final product = Product(
            id: data['id'],
            barcode: data['barcode'],
            name: data['name'],
            brand: data['brand'],
            category: data['category'],
            expiryDate: data['expiryDate'] != null
                ? DateTime.parse(data['expiryDate'])
                : null,
            shelfLifeDays: data['shelfLifeDays'],
            addedDate: DateTime.parse(data['addedDate']),
            notes: data['notes'],
            storeId: data['storeId'],
            isStockOut: data['isStockOut'],
          );

          await productProvider.addProduct(product);
          successCount++;

          setState(() {
            _processedCount = successCount;
          });
        } catch (e) {
          // Hatalı satırı atla, devam et
          continue;
        }
      }

      setState(() {
        _isProcessing = false;
        _statusMessage =
            '✅ $successCount / ${parsedData.length} ürün başarıyla içe aktarıldı!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '❌ Hata: $e';
      });
    }
  }

  // Template indir
  Future<void> _downloadTemplate() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = null;
    });

    try {
      final templateCsv = CsvHelper.createTemplateCsv();
      final filename = CsvHelper.generateFilename(suffix: 'sablon_ornek');
      
      await CsvHelper.downloadCsv(templateCsv, filename);

      setState(() {
        _isProcessing = false;
        _statusMessage = '✅ Şablon dosyası başarıyla indirildi!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '❌ Hata: $e';
      });
    }
  }

  // Import onay diyalogu
  Future<bool?> _showImportConfirmDialog(int count) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İçe Aktarma Onayı'),
        content: Text(
          '$count ürün içe aktarılacak.\n\n'
          'Aynı barkod koduna sahip ürünler varsa yeni ürün olarak eklenecektir.\n\n'
          'Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('İçe Aktar'),
          ),
        ],
      ),
    );
  }
}
