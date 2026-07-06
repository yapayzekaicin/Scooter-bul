import '../models/scooter.dart';

/// Her scooter firması (Martı, BinBin, Tazı, HOP...) için bu arayüzü
/// uygulayan bir adapter yazılır. Gerçek API anlaşması yapıldığında
/// sadece MockXAdapter -> RealXAdapter değişimi yapılır; uygulamanın
/// geri kalanı (ekranlar, sıralama, harita) hiç değişmez.
abstract class ProviderAdapter {
  /// Sağlayıcının benzersiz kısa kodu, örn: 'marti'
  String get providerId;

  /// Ekranda gösterilecek isim, örn: 'Martı'
  String get providerName;

  /// Verilen konum etrafındaki [radiusMeters] içindeki araçları döndürür.
  /// Gerçek entegrasyonda burası firmanın REST/GraphQL API'sine
  /// bir HTTP isteği atar (bkz. adapters/real_api_adapter_template.dart).
  Future<List<Scooter>> fetchNearbyVehicles({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });

  /// Bir aracın kilidini açma isteği gönderir.
  /// Gerçek entegrasyonda firmanın "unlock" endpoint'ine POST atılır.
  Future<UnlockResult> unlock(String scooterId);
}

class UnlockResult {
  final bool success;
  final String message;
  const UnlockResult({required this.success, required this.message});
}
