import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import 'barcode_scanner_screen.dart';
import '../../data/repositories/product_catalog_repository.dart';

class AddProductScreen extends StatefulWidget {
  final String? initialBarcode;
  final Product? editProduct;

  const AddProductScreen({
    super.key,
    this.initialBarcode,
    this.editProduct,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _brandController = TextEditingController();
  final _categoryController = TextEditingController();
  final _shelfLifeController = TextEditingController();

  final _notesController = TextEditingController();

  DateTime? _selectedExpiryDate;
  String? _selectedCategory;
  bool _isSubmitting = false;
  bool _isEditMode = false;

  final List<String> _categories = [
    AppStrings.catDairy,
    AppStrings.catCheese,
    AppStrings.catMeat,
    AppStrings.catBakery,
    AppStrings.catBeverages,
    AppStrings.catSnacks,
    AppStrings.catFrozen,
    AppStrings.catPasta,
    AppStrings.catLegumes,
    AppStrings.catSauces,
    AppStrings.catCanned,
    AppStrings.catOil,
    AppStrings.catCleaning,
    AppStrings.catPersonalCare,
    AppStrings.catOther,
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }

    if (widget.editProduct != null) {
      _isEditMode = true;
      final p = widget.editProduct!;
      _nameController.text = p.name;
      _barcodeController.text = p.barcode;
      _brandController.text = p.brand ?? '';
      _selectedCategory = p.category;
      _categoryController.text = p.category ?? '';
      _selectedExpiryDate = p.expiryDate;
      _shelfLifeController.text = p.shelfLifeDays.toString();

      _notesController.text = p.notes ?? '';
    }
    
    // Barkod değişikliklerini dinle (manuel giriş için)
    _barcodeController.addListener(_onBarcodeChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _shelfLifeController.dispose();

    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: AppStrings.selectDate,
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.save,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme,
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

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category != null && category != AppStrings.catOther) {
        _categoryController.text = category;
      } else if (category == AppStrings.catOther) {
        _categoryController.clear();
      }
    });
  }

  /// Barkod değişikliğini dinle (manuel giriş için)
  void _onBarcodeChanged() {
    final barcode = _barcodeController.text.trim();
    
    // En az 8 karakter ve edit mode değilse kontrol et
    if (barcode.length >= 8 && !_isEditMode) {
      // Debounce için küçük gecikme
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_barcodeController.text.trim() == barcode && mounted) {
          _searchProductByBarcode(barcode);
        }
      });
    }
  }

  /// Barkod tarama fonksiyonu
  Future<void> _scanBarcode() async {
    // BarcodeScannerScreen'e git (sadece barkod return et)
    final scannedBarcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(returnBarcodeOnly: true),
      ),
    );

    if (scannedBarcode != null && mounted) {
      // Barkodu text field'a yaz
      _barcodeController.text = scannedBarcode;
      
      // Database'de bu barkoda sahip ürün var mı kontrol et
      await _searchProductByBarcode(scannedBarcode);
    }
  }

  /// Barkod ile ürün arama ve otomatik doldurma
  /// 1. Önce ortak katalogda ara (product_catalog)
  /// 2. Bulunamazsa yerel ürünlerde ara
  Future<void> _searchProductByBarcode(String barcode) async {
    if (!mounted) return;
    
    // Loading indicator göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Ürün bilgileri aranıyor...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 1. ADIM: Ortak katalogda ara
      final catalogRepo = ProductCatalogRepository();
      final catalogProduct = await catalogRepo.getProductByBarcode(barcode);

      if (!mounted) return;
      Navigator.of(context).pop(); // Loading dialog kapat

      if (catalogProduct != null) {
        // ✅ KATALOGDA BULUNDU!
        setState(() {
          _nameController.text = catalogProduct.name;
          _brandController.text = catalogProduct.brand;
          _selectedCategory = catalogProduct.category;
          _categoryController.text = catalogProduct.category;
          _shelfLifeController.text = catalogProduct.defaultShelfLifeDays.toString();
          // NOT: SKT'yi doldurmuyoruz, kullanıcı her parti için girsin
        });

        // Başarı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✅ Ürün bilgileri katalogdan yüklendi:\n${catalogProduct.name}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // 2. ADIM: Katalogda bulunamadı, yerel ürünlerde ara
      final productProvider = context.read<ProductProvider>();
      final products = productProvider.products;
      final matchingProduct = products.where((p) => p.barcode == barcode).firstOrNull;

      if (matchingProduct != null) {
        // ✅ YEREL ÜRÜNLERDE BULUNDU!
        setState(() {
          _nameController.text = matchingProduct.name;
          _brandController.text = matchingProduct.brand ?? '';
          _selectedCategory = matchingProduct.category;
          _categoryController.text = matchingProduct.category ?? '';
          _shelfLifeController.text = matchingProduct.shelfLifeDays.toString();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('ℹ️ Daha önce eklediğiniz ürün bilgileri yüklendi'),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // ❌ HİÇBİR YERDE BULUNAMADI
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('⚠️ Ürün katalogda bulunamadı, manuel olarak doldurun'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Loading dialog kapat (hata durumunda)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.expiryDateRequired),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = context.read<AuthProvider>();
    final productProvider = context.read<ProductProvider>();
    final storeId = authProvider.currentUser?.storeId ?? 'store_001';

    final category = _selectedCategory == AppStrings.catOther
        ? _categoryController.text.trim()
        : _selectedCategory ?? _categoryController.text.trim();

    final product = Product(
      id: _isEditMode
          ? widget.editProduct!.id
          : 'prod_${DateTime.now().millisecondsSinceEpoch}',
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      category: category.isEmpty ? null : category,
      imageUrl: _isEditMode ? widget.editProduct!.imageUrl : null,
      expiryDate: _selectedExpiryDate!,
      addedDate: _isEditMode ? widget.editProduct!.addedDate : DateTime.now(),
      shelfLifeDays: int.parse(_shelfLifeController.text.trim()),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      storeId: storeId,
    );

    bool success;
    if (_isEditMode) {
      success = await productProvider.updateProduct(product);
    } else {
      success = await productProvider.addProduct(product);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.errorMessage ?? AppStrings.unknownError),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isEditMode ? AppStrings.productUpdated : AppStrings.productAdded,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(Icons.inventory_2, 'Ürün', _nameController.text),
                  if (_brandController.text.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildSummaryRow(Icons.business, 'Marka', _brandController.text),
                  ],
                  const Divider(height: 16),
                  _buildSummaryRow(
                    Icons.calendar_today,
                    'SKT',
                    _selectedExpiryDate != null
                        ? DateFormat('dd.MM.yyyy').format(_selectedExpiryDate!)
                        : '-',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!_isEditMode)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addAnotherProduct),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // screen
            },
            icon: const Icon(Icons.home),
            label: const Text(AppStrings.backToHome),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _barcodeController.clear();
    _brandController.clear();
    _categoryController.clear();
    _shelfLifeController.clear();

    _notesController.clear();
    setState(() {
      _selectedExpiryDate = null;
      _selectedCategory = null;
    });
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isEditMode ? AppStrings.editProductTitle : AppStrings.addProductTitle),
            Text(
              _isEditMode ? '' : AppStrings.addProductSubtitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Required fields note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.requiredFields,
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // === SECTION 1: Temel Bilgiler ===
                _buildSectionHeader(Icons.info_outline, AppStrings.basicInfo, theme.colorScheme.primary),
                const SizedBox(height: 12),

                // Ürün Adı
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.productNameLabel,
                    hintText: AppStrings.productNameHintField,
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.productNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Barkod
                TextFormField(
                  controller: _barcodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: AppStrings.barcodeLabel,
                    hintText: AppStrings.barcodeHint,
                    prefixIcon: const Icon(Icons.qr_code_2),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                      tooltip: 'Barkod Tara',
                      onPressed: _scanBarcode,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.barcodeRequired;
                    }
                    if (value.trim().length < 6) {
                      return AppStrings.barcodeTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Marka
                TextFormField(
                  controller: _brandController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.brandLabel,
                    hintText: AppStrings.brandHintField,
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 14),

                // Kategori
                _buildCategorySelector(),

                const SizedBox(height: 24),

                // === SECTION 2: Tarih ve Raf Bilgisi ===
                _buildSectionHeader(Icons.calendar_month, AppStrings.dateAndShelfInfo, theme.colorScheme.primary),
                const SizedBox(height: 12),

                // SKT Tarihi
                InkWell(
                  onTap: _selectExpiryDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppStrings.expiryDateLabel,
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _selectedExpiryDate != null
                          ? dateFormat.format(_selectedExpiryDate!)
                          : AppStrings.selectDate,
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedExpiryDate != null
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Raftan Kalkma Süresi
                TextFormField(
                  controller: _shelfLifeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: AppStrings.shelfLifeLabel,
                    hintText: AppStrings.shelfLifeHint,
                    prefixIcon: const Icon(Icons.access_time),
                    helperText: AppStrings.shelfLifeInfo,
                    helperMaxLines: 2,
                    helperStyle: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.shelfLifeRequired;
                    }
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return AppStrings.shelfLifeInvalid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // === SECTION 3: Ek Bilgiler ===
                _buildSectionHeader(Icons.note_add, AppStrings.additionalInfo, theme.colorScheme.primary),
                const SizedBox(height: 12),

                // Notlar
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: AppStrings.notesLabel,
                    hintText: AppStrings.notesHint,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.note),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Ürün Önizleme Kartı
                if (_nameController.text.isNotEmpty && _selectedExpiryDate != null)
                  _buildPreviewCard(),

                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(_isEditMode ? Icons.save : Icons.add_circle),
                    label: Text(
                      _isSubmitting
                          ? AppStrings.loading
                          : (_isEditMode ? AppStrings.save : AppStrings.addProduct),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            labelText: AppStrings.categoryLabel,
            prefixIcon: Icon(Icons.category),
          ),
          hint: const Text(AppStrings.selectCategory),
          isExpanded: true,
          items: _categories.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat),
            );
          }).toList(),
          onChanged: _onCategorySelected,
        ),
        if (_selectedCategory == AppStrings.catOther) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _categoryController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: AppStrings.customCategory,
              hintText: AppStrings.categoryHintField,
              prefixIcon: Icon(Icons.edit),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewCard() {
    final daysUntil = _selectedExpiryDate != null
        ? _selectedExpiryDate!
            .subtract(Duration(days: int.tryParse(_shelfLifeController.text) ?? 0))
            .difference(DateTime.now())
            .inDays
        : 0;

    Color riskColor;
    String riskText;
    IconData riskIcon;

    if (daysUntil < 0) {
      riskColor = AppColors.danger;
      riskText = 'Süresi Geçmiş';
      riskIcon = Icons.dangerous;
    } else if (daysUntil <= 3) {
      riskColor = AppColors.danger;
      riskText = 'Kritik';
      riskIcon = Icons.error;
    } else if (daysUntil <= 7) {
      riskColor = AppColors.warning;
      riskText = 'Yüksek Risk';
      riskIcon = Icons.warning_amber;
    } else if (daysUntil <= 14) {
      riskColor = const Color(0xFFFFA726);
      riskText = 'Orta Risk';
      riskIcon = Icons.access_time;
    } else {
      riskColor = AppColors.success;
      riskText = 'Güvenli';
      riskIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, size: 18, color: riskColor),
              const SizedBox(width: 8),
              Text(
                'Ürün Önizleme',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: riskColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_brandController.text.isNotEmpty)
                      Text(
                        _brandController.text,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(riskIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      riskText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kalan: ${daysUntil.abs()} gün ${daysUntil < 0 ? "geçti" : ""}',
            style: TextStyle(
              fontSize: 13,
              color: riskColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
