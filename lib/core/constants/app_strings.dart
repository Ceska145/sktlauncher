class AppStrings {
  // Login Screen
  static const String appTitle = 'SKT Takip';
  static const String loginTitle = 'Giriş Yap';
  static const String loginSubtitle = 'Mağaza hesabınıza giriş yapın';
  static const String email = 'E-posta';
  static const String emailHint = 'ornek@magaza.com';
  static const String password = 'Şifre';
  static const String passwordHint = 'Şifrenizi girin';
  static const String forgotPassword = 'Şifremi Unuttum?';
  static const String login = 'Giriş Yap';
  static const String dontHaveAccount = 'Hesabınız yok mu?';
  static const String register = 'Kayıt Ol';
  static const String or = 'veya';
  
  // Validation Messages
  static const String emailRequired = 'E-posta adresi gereklidir';
  static const String emailInvalid = 'Geçerli bir e-posta adresi girin';
  static const String passwordRequired = 'Şifre gereklidir';
  static const String passwordTooShort = 'Şifre en az 6 karakter olmalıdır';
  
  // Error Messages
  static const String loginError = 'Giriş başarısız';
  static const String loginErrorMessage = 'E-posta veya şifre hatalı';
  static const String networkError = 'Bağlantı hatası';
  static const String unknownError = 'Bilinmeyen bir hata oluştu';
  
  // Success Messages
  static const String loginSuccess = 'Giriş başarılı';
  static const String welcomeBack = 'Tekrar hoş geldiniz!';
  
  // Home Screen
  static const String home = 'Ana Sayfa';
  static const String products = 'Ürünler';
  static const String totalProducts = 'Toplam Ürün';
  static const String riskProducts = 'Riskli Ürünler';
  static const String allProducts = 'Tüm Ürünler';
  static const String expiredProducts = 'Süresi Geçmiş';
  static const String criticalRisk = 'Kritik';
  static const String highRisk = 'Yüksek Risk';
  static const String mediumRisk = 'Orta Risk';
  static const String lowRisk = 'Düşük Risk';
  static const String scanBarcode = 'Barkod Tara';
  static const String addProduct = 'Ürün Ekle';
  static const String filter = 'Filtrele';
  static const String search = 'Ara';
  static const String logout = 'Çıkış Yap';
  
  // Search
  static const String searchHint = 'Ürün adı, marka veya barkod ara...';
  static const String noSearchResults = 'Aramanızla eşleşen ürün bulunamadı';
  static const String clearSearch = 'Aramayı Temizle';
  
  // Sorting
  static const String sortBy = 'Sırala';
  static const String sortByRisk = 'Risk Seviyesi';
  static const String sortByName = 'Ürün Adı (A-Z)';
  static const String sortByNameDesc = 'Ürün Adı (Z-A)';
  static const String sortByExpiry = 'SKT (Yakın → Uzak)';
  static const String sortByExpiryDesc = 'SKT (Uzak → Yakın)';
  static const String sortByAdded = 'Eklenme Tarihi (Yeni → Eski)';
  
  // Add Product Screen
  static const String addProductTitle = 'Yeni Ürün Ekle';
  static const String addProductSubtitle = 'Ürün bilgilerini girerek sisteme ekleyin';
  static const String editProductTitle = 'Ürünü Düzenle';
  static const String productNameLabel = 'Ürün Adı *';
  static const String productNameHintField = 'Örn: Süt 1L, Yoğurt 500g';
  static const String productNameRequired = 'Ürün adı gereklidir';
  static const String barcodeLabel = 'Barkod Numarası *';
  static const String barcodeHint = 'Örn: 8690632000011';
  static const String barcodeRequired = 'Barkod numarası gereklidir';
  static const String barcodeTooShort = 'Barkod en az 6 karakter olmalıdır';
  static const String brandLabel = 'Marka';
  static const String brandHintField = 'Örn: Pınar, Danone, Eker';
  static const String categoryLabel = 'Kategori';
  static const String categoryHintField = 'Örn: Süt Ürünleri, Unlu Mamuller';
  static const String expiryDateLabel = 'Son Kullanma Tarihi (SKT) *';
  static const String expiryDateRequired = 'SKT tarihi gereklidir';
  static const String expiryDateInPast = 'SKT tarihi geçmişte olamaz';
  static const String shelfLifeLabel = 'Raftan Kalkma Süresi (Gün) *';
  static const String shelfLifeHint = 'Örn: 3, 5, 7';
  static const String shelfLifeRequired = 'Raftan kalkma süresi gereklidir';
  static const String shelfLifeInvalid = 'Geçerli bir sayı girin';
  static const String shelfLifeInfo = 'Ürünün raftan çekilmesi gereken SKT öncesi gün sayısı';
  static const String quantityLabel = 'Miktar (Adet) *';
  static const String quantityHint = 'Örn: 10, 24, 48';
  static const String quantityRequired = 'Miktar gereklidir';
  static const String quantityInvalid = 'Geçerli bir miktar girin';
  static const String priceLabel = 'Birim Fiyat (₺)';
  static const String priceHint = 'Örn: 25.50';
  static const String priceInvalid = 'Geçerli bir fiyat girin';
  static const String notesLabel = 'Notlar';
  static const String notesHint = 'Opsiyonel not ekleyin...';
  static const String productAdded = 'Ürün başarıyla eklendi!';
  static const String productUpdated = 'Ürün başarıyla güncellendi!';
  static const String addAnotherProduct = 'Başka Ürün Ekle';
  static const String requiredFields = '* işaretli alanlar zorunludur';
  static const String scanToFill = 'Barkod Tara';
  static const String basicInfo = 'Temel Bilgiler';
  static const String dateAndShelfInfo = 'Tarih ve Raf Bilgisi';
  static const String stockAndPriceInfo = 'Stok ve Fiyat';
  static const String additionalInfo = 'Ek Bilgiler';
  static const String selectCategory = 'Kategori Seçin';
  static const String customCategory = 'Özel Kategori';
  
  // Categories
  static const String catDairy = 'Süt Ürünleri';
  static const String catCheese = 'Peynir';
  static const String catMeat = 'Et & Tavuk';
  static const String catBakery = 'Unlu Mamuller';
  static const String catBeverages = 'İçecekler';
  static const String catSnacks = 'Atıştırmalık';
  static const String catFrozen = 'Dondurulmuş';
  static const String catPasta = 'Makarna & Pirinç';
  static const String catLegumes = 'Bakliyat';
  static const String catSauces = 'Sos & Baharat';
  static const String catCanned = 'Konserve';
  static const String catOil = 'Yağ';
  static const String catCleaning = 'Temizlik';
  static const String catPersonalCare = 'Kişisel Bakım';
  static const String catOther = 'Diğer';
  
  // Product Details
  static const String expiryDate = 'Son Kullanma Tarihi';
  static const String daysLeft = 'Kalan Gün';
  static const String quantity = 'Miktar';
  static const String price = 'Fiyat';
  static const String brand = 'Marka';
  static const String category = 'Kategori';
  static const String barcode = 'Barkod';
  static const String shelfLifeDays = 'Raftan Kalkma Süresi';
  static const String addedDate = 'Eklenme Tarihi';
  static const String notes = 'Notlar';
  
  // Product Actions
  static const String updateDate = 'Tarih Güncelle';
  static const String markAsSold = 'Stok Sıfırlandı';
  static const String returnProduct = 'İade Süreci';
  static const String deleteProduct = 'Ürünü Sil';
  
  // Status Messages
  static const String expired = 'SÜRESİ GEÇMİŞ!';
  static const String expiringToday = 'BUGÜN BİTİYOR!';
  static const String expiringSoon = 'YAKINDA BİTİYOR!';
  static const String day = 'gün';
  static const String days = 'gün';
  static const String safe = 'Güvenli';
  
  // Loading & Empty States
  static const String loading = 'Yükleniyor...';
  static const String noProducts = 'Henüz ürün eklenmemiş';
  static const String noProductsFiltered = 'Bu filtrede ürün bulunamadı';
  static const String refreshing = 'Yenileniyor...';
  static const String addFirstProduct = 'İlk ürününüzü eklemek için + butonuna basın';
  
  // Barcode Scanner
  static const String scanBarcodeTitle = 'Barkod Tara';
  static const String scanBarcodeSubtitle = 'Ürün barkodunu kamera ile okutun';
  static const String barcodeDetected = 'Barkod Algılandı';
  static const String scanning = 'Taranıyor...';
  static const String flashOn = 'Flaş Açık';
  static const String flashOff = 'Flaş Kapalı';
  static const String switchCamera = 'Kamera Değiştir';
  static const String cancel = 'İptal';
  static const String productFound = 'Ürün Bulundu';
  static const String productNotFound = 'Ürün Bulunamadı';
  static const String addNewProduct = 'Yeni Ürün Ekle';
  static const String scanAnother = 'Başka Tara';
  static const String viewProduct = 'Ürünü Görüntüle';
  static const String cameraPermissionDenied = 'Kamera izni reddedildi';
  static const String cameraPermissionRequired = 'Barkod tarama için kamera izni gereklidir';
  static const String openSettings = 'Ayarları Aç';
  static const String invalidBarcode = 'Geçersiz barkod';
  static const String barcodeFormat = 'Barkod Formatı';
  
  // Product Detail Screen
  static const String productDetails = 'Ürün Detayları';
  static const String productInfo = 'Ürün Bilgileri';
  static const String expiryInfo = 'Son Kullanma Bilgisi';
  static const String stockInfo = 'Stok Bilgisi';
  static const String actions = 'İşlemler';
  static const String updateExpiryDate = 'SKT Tarihini Güncelle';
  static const String markAsStockOut = 'Stok Sıfırlandı';
  static const String initiateReturn = 'İade Süreci Başlat';
  static const String deleteProductConfirm = 'Ürünü Sil';
  static const String editProduct = 'Ürünü Düzenle';
  static const String save = 'Kaydet';
  static const String selectDate = 'Tarih Seç';
  static const String selectNewExpiryDate = 'Yeni SKT Tarihi Seçin';
  static const String dateUpdated = 'Tarih güncellendi';
  static const String stockMarkedAsZero = 'Stok sıfırlandı';
  static const String returnProcessStarted = 'İade süreci başlatıldı';
  static const String productDeleted = 'Ürün silindi';
  static const String confirmDelete = 'Silme Onayı';
  static const String confirmDeleteMessage = 'Bu ürünü silmek istediğinizden emin misiniz?';
  static const String confirmStockOut = 'Stok Sıfırlama Onayı';
  static const String confirmStockOutMessage = 'Bu ürünün stoku sıfırlanacak. Onaylıyor musunuz?';
  static const String confirmReturn = 'İade Onayı';
  static const String confirmReturnMessage = 'Bu ürün için iade süreci başlatılacak. Devam etmek istiyor musunuz?';
  static const String yes = 'Evet';
  static const String no = 'Hayır';
  static const String piece = 'adet';
  static const String riskStatus = 'Risk Durumu';
  static const String daysUntilExpiry = 'Kalan Süre';
  static const String adjustedExpiryDate = 'Düzeltilmiş SKT';
  static const String originalExpiryDate = 'Orijinal SKT';
  static const String calculationInfo = 'SKT Hesaplama';
  static const String criticalWarning = 'KRİTİK DURUM!';
  static const String expiredWarning = 'SÜRESİ GEÇMİŞ!';
  static const String takeAction = 'Hemen işlem yapın';
  
  // Scenario B - New Product Request
  static const String newProductRequest = 'Yeni Ürün Talebi';
  static const String newProductSubtitle = 'Sistemde olmayan ürün için talep oluştur';
  static const String productPhoto = 'Ürün Fotoğrafı';
  static const String takePhoto = 'Fotoğraf Çek';
  static const String retakePhoto = 'Yeniden Çek';
  static const String productName = 'Ürün Adı';
  static const String productNameHint = 'Örn: Süt 1L';
  static const String brandOptional = 'Marka (Opsiyonel)';
  static const String brandHint = 'Örn: Pınar';
  static const String categoryOptional = 'Kategori (Opsiyonel)';
  static const String categoryHint = 'Örn: Süt Ürünleri';
  static const String photoRequired = 'Ürün fotoğrafı gereklidir';
  static const String submitRequest = 'Talebi Gönder';
  static const String requestSubmitted = 'Talep gönderildi';
  static const String requestSubmittedMessage = 'Yeni ürün talebiniz admin onayına gönderildi';
  static const String adminWillReview = 'Admin onayından sonra ürün sisteme eklenecektir';
  static const String backToHome = 'Ana Sayfaya Dön';
  static const String cameraPermissionTitle = 'Kamera İzni Gerekli';
  static const String cameraPermissionMessage = 'Fotoğraf çekmek için kamera izni vermelisiniz';
  static const String requestInfo = 'Talep Bilgileri';
  static const String photoPreview = 'Fotoğraf Önizleme';
  static const String barcodeInfo = 'Barkod Bilgisi';
  static const String detectedBarcode = 'Algılanan Barkod';
  static const String requestStatus = 'Talep Durumu';
  static const String pendingApproval = 'Onay Bekliyor';
  static const String approved = 'Onaylandı';
  static const String rejected = 'Reddedildi';
}
