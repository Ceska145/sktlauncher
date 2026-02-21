# 🛒 Expiry Alert - SKT Takip ve Mağaza Yönetim Platformu

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Son Kullanma Tarihi (SKT) takibi ve stok yönetimi için geliştirilmiş profesyonel mobil uygulama ve web admin paneli.

## 📱 Özellikler

### Mobil Uygulama (Flutter)
- 📷 **Barkod Okuma**: Hızlı ürün ekleme
- 🗓️ **SKT Takibi**: Otomatik bildirimler
- 📊 **Dashboard**: Gerçek zamanlı istatistikler
- 🔔 **Bildirimler**: SKT yaklaşan ürünler için uyarılar
- 📦 **Batch Yönetimi**: Parti/lot bazlı takip
- 📤 **CSV Export/Import**: Toplu veri aktarımı
- 🎨 **Grid/List Görünüm**: Esnek görüntüleme
- ⚡ **Hızlı Ekleme**: Quick add özelliği
- 🔥 **Firebase Entegrasyonu**: Bulut senkronizasyonu
- 🌐 **Ortak Ürün Kataloğu**: Tüm mağazalar için paylaşımlı katalog

### Admin Panel v2 (Web)
- 👑 **Modern Dashboard**: Gerçek zamanlı istatistikler
- 📦 **Ürün Kataloğu Yönetimi**: CRUD operasyonları
- ✅ **Talep Onay Sistemi**: Kullanıcı ürün taleplerini yönetme
- 👥 **Hesap Yönetimi**: Mağaza hesapları oluşturma ve yönetme
- 📤 **Toplu Yükleme**: CSV ile toplu ürün import
- 📊 **Analytics**: Detaylı raporlama ve analiz
- 🖼️ **Fotoğraf Yükleme**: Progress bar ile takip
- ⏱️ **Timeout Tespiti**: Otomatik hata yönetimi
- 🟢 **Bağlantı Durumu**: Firebase connection indicator

## 🚀 Hızlı Başlangıç

### Gereksinimler
- Flutter 3.35.4
- Dart 3.9.2
- Firebase hesabı
- Android Studio / VS Code

### Kurulum

```bash
# Repository'yi klonlayın
git clone https://github.com/Ceska145/sktlauncher.git
cd sktlauncher

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

### Firebase Kurulumu

1. **Firestore Database Oluştur**:
   - https://console.firebase.google.com/project/sktlauncer/firestore
   - "Create database" → "Test mode" → "europe-west3 (Frankfurt)"

2. **Firebase Storage Aktifleştir**:
   - https://console.firebase.google.com/project/sktlauncer/storage
   - "Get started" → "Test mode"

3. **Admin Hesabını Kaydet**:
   ```bash
   python3 create_admin_account.py
   ```

4. **Test Verilerini Yükle**:
   ```bash
   python3 test_admin_panel.py
   ```

## 📦 APK Build

```bash
# Release APK oluştur
flutter build apk --release

# APK konumu
build/app/outputs/flutter-apk/app-release.apk
```

**Build Bilgileri**:
- **Versiyon**: 1.0.0+1
- **Package**: com.expiryalert.alert
- **Target SDK**: Android 15 (API 35)
- **Min SDK**: Android 5.0 (API 21)
- **APK Boyutu**: 66 MB

## 🌐 Admin Panel

### Canlı Demo
🔗 Admin Panel v2: [Demo Link](https://8080-iw8w70pbb9up1vr4hqi4p-2b54fc91.sandbox.novita.ai/admin_panel_v2.html)

### Admin Giriş Bilgileri
- **Email**: test@magaza.com
- **Şifre**: admin123

### Admin Yetkileri
- ✅ Ürün kataloğu yönetimi
- ✅ Ürün taleplerini onaylama/reddetme
- ✅ Mağaza hesapları oluşturma
- ✅ Dashboard istatistikleri görüntüleme
- ✅ Toplu ürün yükleme

## 🔥 Firebase Konfigürasyonu

### Firebase Bilgileri
```yaml
Project ID: sktlauncer
API Key: AIzaSyAlrVDFi-BiXnCSPzOrpAPxsfcBxLJwTo0
Database: Firestore (Test mode)
Storage: Firebase Storage (Test mode)
Region: europe-west3 (Frankfurt)
```

### Firestore Koleksiyonları
- `product_catalog`: Ortak ürün kataloğu
- `store_products`: Mağaza özel ürünler
- `product_requests`: Kullanıcı ürün talepleri
- `accounts`: Mağaza hesapları

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── constants/        # Sabitler ve yapılandırma
│   ├── theme/            # Tema ve renkler
│   └── utils/            # Yardımcı fonksiyonlar
├── data/
│   ├── datasources/      # Veri kaynakları
│   ├── models/           # Data modelleri
│   └── repositories/     # Repository implementasyonları
├── domain/
│   ├── entities/         # Domain varlıkları
│   └── repositories/     # Repository arayüzleri
└── presentation/
    ├── providers/        # State management
    ├── screens/          # Uygulama ekranları
    └── widgets/          # Yeniden kullanılabilir widget'lar

web/
├── admin_panel_v2.html       # Admin panel
├── product_uploader.html     # Toplu yükleme aracı
└── firebase_live_setup.html  # Kurulum rehberi
```

## 🛠️ Teknolojiler

### Flutter Paketleri
```yaml
dependencies:
  firebase_core: 3.6.0
  cloud_firestore: 5.4.3
  firebase_storage: 12.3.2
  provider: 6.1.5+1
  shared_preferences: 2.5.3
  hive: 2.2.3
  hive_flutter: 1.1.0
  http: 1.5.0
  mobile_scanner: 5.2.3
  intl: 0.19.0
  fl_chart: 0.69.0
  email_validator: 2.1.17
```

## 🎯 Kullanım Senaryosu

### 1. Kullanıcı (Mağaza Sahibi)
- Mobil uygulamada barkod okutup ürün ekler
- Ürün bulunamazsa "Yeni Ürün Talebi" oluşturur

### 2. Admin (Yönetici)
- Admin panele giriş yapar
- Bekleyen talepleri görüntüler ve onaylar
- Ürün kataloğuna yeni ürünler ekler

### 3. Sistem
- Kullanıcı tekrar barkod okutunca bilgiler otomatik dolar
- Sadece SKT girilerek ürün eklenir

## 📊 Dashboard İstatistikleri

- 📦 Toplam ürün sayısı
- ⚠️ SKT yaklaşan ürünler
- 🔴 SKT geçmiş ürünler
- 📈 Haftalık eklenen ürünler
- 💰 Tahmini kayıp

## 🧪 Test

```bash
# Unit testler
flutter test

# Widget testler
flutter test test/widget_test.dart

# Integration testler
flutter test integration_test/
```

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakınız.

## 👥 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📞 İletişim

**Proje Sahibi**: Ceska145  
**GitHub**: [@Ceska145](https://github.com/Ceska145)  
**Repository**: [sktlauncher](https://github.com/Ceska145/sktlauncher)

## 🙏 Teşekkürler

- [Flutter](https://flutter.dev) - UI framework
- [Firebase](https://firebase.google.com) - Backend services
- [Provider](https://pub.dev/packages/provider) - State management
- [Mobile Scanner](https://pub.dev/packages/mobile_scanner) - Barcode scanning
- [Hive](https://pub.dev/packages/hive) - Local storage

---

**⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!**

**Made with ❤️ in Turkey**
