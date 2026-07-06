import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bir sağlayıcının kendi uygulamasına geçiş yapmak için gereken bilgiler.
///
/// ÖNEMLİ NOT: `androidPackage` sadece Martı için doğrulanmış durumda
/// (com.martitech.marti). Diğerleri için kesin paket adı/App Store ID'si
/// bende yok, bu yüzden onlar için Play Store / App Store'da isimle
/// ARAMA yapan güvenli bir fallback kullanıyorum. Kesin ID'leri
/// öğrendiğinde (Play Store/App Store linklerinden) aşağıyı güncelle,
/// böylece kullanıcı doğrudan doğru uygulama sayfasına düşer.
class ProviderLaunchConfig {
  final String providerId;
  final String displayName;
  final String? androidPackage;   // örn: 'com.martitech.marti'
  final String? iosAppStoreId;    // örn: '1459430671' (numeric id)
  final String websiteUrl;        // Universal link denemesi için

  const ProviderLaunchConfig({
    required this.providerId,
    required this.displayName,
    this.androidPackage,
    this.iosAppStoreId,
    required this.websiteUrl,
  });
}

const Map<String, ProviderLaunchConfig> providerLaunchConfigs = {
  'marti': ProviderLaunchConfig(
    providerId: 'marti',
    displayName: 'Martı',
    androidPackage: 'com.martitech.marti', // doğrulandı
    iosAppStoreId: null, // TODO: App Store'dan doğrulayıp ekle
    websiteUrl: 'https://www.marti.tech',
  ),
  'binbin': ProviderLaunchConfig(
    providerId: 'binbin',
    displayName: 'BinBin',
    androidPackage: null, // TODO: Play Store'dan doğrulayıp ekle
    iosAppStoreId: null,
    websiteUrl: 'https://www.binbin.com.tr',
  ),
  'tazi': ProviderLaunchConfig(
    providerId: 'tazi',
    displayName: 'Tazı',
    androidPackage: null, // TODO
    iosAppStoreId: null,
    websiteUrl: 'https://www.tazi.com.tr',
  ),
  'hop': ProviderLaunchConfig(
    providerId: 'hop',
    displayName: 'HOP!',
    androidPackage: null, // TODO
    iosAppStoreId: null,
    websiteUrl: 'https://www.hop.com.tr',
  ),
};

class AppLaunchService {
  /// Verilen sağlayıcının uygulamasına geçmeyi dener.
  /// Sırasıyla: (1) firmanın web adresi -> kuruluysa Universal/App Link
  /// sayesinde otomatik uygulamaya düşer, kurulu değilse tarayıcıda açılır.
  /// (2) android/iOS paket bilgisi varsa doğrudan mağaza sayfası.
  static Future<LaunchOutcome> openProviderApp(String providerId) async {
    final config = providerLaunchConfigs[providerId];
    if (config == null) {
      return LaunchOutcome(success: false, message: 'Sağlayıcı bulunamadı');
    }

    // 1) Universal link dene: uygulama kuruluysa OS bunu doğrudan
    // ilgili uygulamaya yönlendirir (firma bu domaini App/Universal Link
    // olarak kendi tarafında tanımlamışsa).
    //
    // BUG NOTU: launchUrl(...) bir https adresi için, uygulama kurulu
    // OLMASA BİLE, adres tarayıcıda açılabildiği sürece `true` döner.
    // Yani "launched == true" ASLA "provider'ın uygulaması açıldı"
    // anlamına gelmez - sadece "bir şey (uygulama ya da tarayıcı) bu
    // linki işledi" anlamına gelir. Flutter'ın url_launcher paketi bu
    // ikisini ayırt etmemizi sağlamıyor. Bu yüzden kullanıcıya "uygulama
    // açılıyor" gibi kesin bir mesaj yerine, gerçeği yansıtan daha
    // temkinli bir mesaj gösteriyoruz.
    final siteUri = Uri.parse(config.websiteUrl);
    try {
      final launched = await launchUrl(
        siteUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return LaunchOutcome(
          success: true,
          message: '${config.displayName} açılıyor',
        );
      }
    } catch (_) {
      // devam et, mağaza linkine düş
    }

    // 2) Platforma göre mağaza linkine düş
    Uri storeUri;
    if (defaultTargetPlatform == TargetPlatform.android) {
      storeUri = config.androidPackage != null
          ? Uri.parse('market://details?id=${config.androidPackage}')
          : Uri.parse(
              'market://search?q=${Uri.encodeComponent(config.displayName)}');
    } else {
      storeUri = config.iosAppStoreId != null
          ? Uri.parse('https://apps.apple.com/tr/app/id${config.iosAppStoreId}')
          : Uri.parse(
              'https://apps.apple.com/tr/search?term=${Uri.encodeComponent(config.displayName)}');
    }

    final storeLaunched = await _tryLaunch(storeUri);

    return LaunchOutcome(
      success: storeLaunched,
      message: storeLaunched
          ? '${config.displayName} mağaza sayfası açıldı'
          : '${config.displayName} açılamadı, uygulama kurulu olmayabilir',
    );
  }

  /// launchUrl çağrısını güvenli şekilde sarmalar - platform istisnası
  /// fırlatırsa (bazı cihazlarda market:// şeması hiç tanımlı değilse
  /// olabilir) bunu yutup false döner, çağıran taraf zaten bunu
  /// "başarısız" olarak ele alıp kullanıcıya nazik bir mesaj gösteriyor.
  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

class LaunchOutcome {
  final bool success;
  final String message;
  const LaunchOutcome({required this.success, required this.message});
}
