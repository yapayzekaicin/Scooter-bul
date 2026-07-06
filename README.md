# Scooter Bul — Çoklu Sağlayıcı Scooter Agregatörü

Martı, BinBin, Tazı, HOP gibi farklı firmaların kiralık scooter'larını
tek uygulamada, mesafe/fiyat/şarj durumuna göre sıralayarak listeleyen
mobil uygulama.

## Şu anki durum: Mock (sahte) veri ile çalışan demo

Uygulama şu anda gerçek firmalara bağlı değil. Her firma için sahte
ama gerçekçi veri üreten bir "adapter" var (`lib/adapters/mock_adapters.dart`).
Bu, konsepti test etmen ve firmalarla/belediyelerle görüşürken
göstermen için hazır, çalışan bir prototip.

## Çalıştırma

1. [Flutter SDK](https://flutter.dev) kurulu olmalı (3.3+)
2. Proje klasöründe:
   ```
   flutter pub get
   flutter run
   ```
3. Harita özelliği için Google Maps API anahtarı gerekir (Android/iOS
   ayrı ayrı ayarlanır — Flutter dokümantasyonuna bakın).

## Scooter'a dokununca ne oluyor?

Uygulama artık scooter'ı kendi içinde açmıyor — bir scooter'a dokunduğunda
ilgili firmanın **kendi uygulamasına** yönlendiriyor (`lib/services/app_launch_service.dart`):

1. Önce firmanın web adresini (örn. `marti.tech`) açmayı dener. Eğer firma
   bu adresi "Universal Link / App Link" olarak kendi uygulamasına
   bağlamışsa (çoğu büyük firma yapar), telefonda uygulama kuruluysa
   **otomatik olarak o firmanın uygulaması açılır**.
2. Bu başarısız olursa Play Store / App Store'daki uygulama sayfasına yönlendirir.

**Doğrulanmış bilgi:** Martı'nın Android paket adı `com.martitech.marti`
olarak doğrulandı ve koda eklendi. BinBin, Tazı, HOP için kesin paket
adı/App Store ID'sini bulamadım — bu yüzden onlar için isimle *arama*
yapan güvenli bir fallback var. `lib/services/app_launch_service.dart`
içindeki `TODO` yorumlarını, ilgili uygulamayı Play Store/App Store'da
bulup gerçek ID'lerini girerek tamamlayabilirsin — kullanıcı böylece
arama yapmadan direkt doğru sayfaya düşer.

**Android için ek ayar gerekiyor:** `market://` linklerinin çalışması için
`android/app/src/main/AndroidManifest.xml` içine şu `<queries>` bloğunu eklemen lazım:
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="market" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```

## Gerçek bir firmaya bağlanmak istediğinde

1. `lib/adapters/real_api_adapter_template.dart` dosyasını kopyala
2. Firma ile yapılan API anlaşmasındaki endpoint ve API anahtarını doldur
3. `lib/screens/nearby_screen.dart` içindeki `MartiAdapter()` gibi bir
   satırı `RealApiAdapter(...)` ile değiştir
4. Başka hiçbir ekranı değiştirmene gerek yok — sıralama, listeleme,
   detay ekranı hepsi otomatik çalışır

## Önemli not: GBFS standardı

Dünya genelinde birçok mikromobilite firması "GBFS" (General Bikeshare
Feed Specification) adında ortak, açık bir veri formatı destekler.
Eğer görüştüğün firmalar GBFS destekliyorsa entegrasyon çok daha
kolay olur. Türkiye'deki firmaların GBFS desteği firma bazında
değişir — görüşme sırasında sormanı öneririz.

## Yapı

```
lib/
  models/scooter.dart              # Ortak veri modeli
  adapters/
    provider_adapter.dart          # Tüm sağlayıcıların uyduğu arayüz
    mock_adapters.dart             # Martı/BinBin/Tazı/HOP sahte veri
    real_api_adapter_template.dart # Gerçek API için şablon
  services/aggregator_service.dart # Birleştirme + sıralama mantığı
  screens/
    nearby_screen.dart             # Ana liste ekranı, dokununca firma uygulamasına geçiş
  services/
    app_launch_service.dart        # Firma uygulamasını açma / mağazaya yönlendirme
  main.dart
```

## Eksik / sonraki adımlar

- Gerçek GPS konumu (şu an sabit demo konum kullanılıyor)
- Google/Apple Maps görsel harita entegrasyonu (paket eklendi, UI'ye bağlanmadı)
- Kullanıcı hesabı, ödeme entegrasyonu
- Firma API anlaşmaları (bu, kod değil iş geliştirme gerektirir)
