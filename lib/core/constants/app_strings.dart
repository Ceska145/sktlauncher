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
  static const String shelfLifeInfo = 'Raftan kalkma süresi';
  static const String criticalWarning = 'KRİTİK DURUM!';
  static const String expiredWarning = 'SÜRESİ GEÇMİŞ!';
  static const String takeAction = 'Hemen işlem yapın';
}
