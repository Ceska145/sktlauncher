import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/product.dart';
import 'barcode_scanner_screen.dart';

/// Hızlı Ürün Ekleme Ekranı - Minimal, süper hızlı
class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shelfLifeController = TextEditingController();
  
  String? _scannedBarcode;
  String? _productName;
  String? _productBrand;
  String? _productCategory;
  DateTime? _selectedExpiryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Hemen barkod taramaya başla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanBarcode();
    });
  }

  @override
  void dispose() {
    _shelfLifeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(returnBarcodeOnly: true),
      ),
    );

    if (barcode != null && mounted) {
      setState(() {
        _scannedBarcode = barcode;
      });
      
      // Ürünü ara
      await _searchProduct(barcode);
    } else {
      // İptal edildi, geri dön
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _searchProduct(String barcode) async {
    final productProvider = context.read<ProductProvider>();
    final products = productProvider.products;
    final matchingProduct = products.where((p) => p.barcode == barcode).firstOrNull;

    if (matchingProduct != null) {
      // Ürün bulundu!
      setState(() {
        _productName = matchingProduct.name;
        _productBrand = matchingProduct.brand;
        _productCategory = matchingProduct.category;
        _shelfLifeController.text = matchingProduct.shelfLifeDays.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ "${matchingProduct.name}" bilgileri yüklendi'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Yeni ürün
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠ Yeni ürün - Bilgileri manuel girmeniz gerekecek'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Normal ekleme ekranına yönlendir
        Navigator.pop(context);
        // Burada normal AddProductScreen'i açabilirsiniz
      }
    }
  }

  Future<void> _selectExpiryDate() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Son Kullanma Tarihi Seç',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Lütfen son kullanma tarihini seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final productProvider = context.read<ProductProvider>();
      
      final storeId = authProvider.currentUser?.storeId ?? 'store_001';
      final shelfLifeDays = int.parse(_shelfLifeController.text);

      // Product nesnesi oluştur
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _productName!,
        barcode: _scannedBarcode!,
        brand: _productBrand,
        category: _productCategory,
        expiryDate: _selectedExpiryDate!,
        addedDate: DateTime.now(),
        shelfLifeDays: shelfLifeDays,
        notes: 'Hızlı eklendi',
        storeId: storeId,
      );

      await productProvider.addProduct(newProduct);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $_productName başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Hızlı Ekle'),
        elevation: 2,
        actions: [
          if (_scannedBarcode != null)
            TextButton.icon(
              onPressed: _scanBarcode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Yeniden Tarat'),
            ),
        ],
      ),
      body: _scannedBarcode == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ürün Bilgisi Kartı
                    Card(
                      elevation: 2,
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  color: colorScheme.primary,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _productName ?? 'Bilinmeyen Ürün',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      if (_productBrand != null)
                                        Text(
                                          _productBrand!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.2)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 16,
                                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _scannedBarcode!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            if (_productCategory != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 16,
                                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _productCategory!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SKT Seçimi (Büyük Buton)
                    InkWell(
                      onTap: _selectExpiryDate,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedExpiryDate == null
                                ? Colors.red
                                : colorScheme.outline.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_month,
                                color: colorScheme.secondary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Son Kullanma Tarihi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedExpiryDate == null
                                        ? 'Tarih Seçin'
                                        : dateFormat.format(_selectedExpiryDate!),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Raf Ömrü
                    TextFormField(
                      controller: _shelfLifeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Raf Ömrü (gün)',
                        hintText: 'Örn: 3',
                        prefixIcon: const Icon(Icons.timeline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Raf ömrü gerekli';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Kaydet Butonu (Büyük)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Hızlı Kaydet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 16),

                    // İpucu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Hızlı Ekle modu sadece mevcut ürünler için çalışır. '
                              'Yeni ürünler için normal ekleme ekranını kullanın.',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
