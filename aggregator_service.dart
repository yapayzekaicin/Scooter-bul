import 'dart:math';
import 'package:flutter/foundation.dart';
import '../adapters/provider_adapter.dart';
import '../models/scooter.dart';

enum SortBy { distance, price, battery }

class AggregatorService {
  final List<ProviderAdapter> providers;

  AggregatorService(this.providers);

  /// Tüm sağlayıcılardan paralel olarak veri çeker, birleştirir ve
  /// istenen kritere göre sıralar. Bir sağlayıcının API'si hata verirse
  /// diğerleri etkilenmez (Future.wait ile hata izolasyonu).
  Future<List<Scooter>> fetchAllNearby({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    SortBy sortBy = SortBy.distance,
  }) async {
    final results = await Future.wait(
      providers.map((p) async {
        try {
          return await p.fetchNearbyVehicles(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters,
          );
        } catch (e, stackTrace) {
          // Bir sağlayıcı çökerse (API down, auth hatası vb.) kullanıcıya
          // sessizce boş liste döndür ki diğer sağlayıcılar etkilenmesin,
          // ama hatayı MUTLAKA logla - aksi halde üretimde firma API'si
          // bozulduğunda bunu asla fark edemeyiz.
          // GÜVENLİK: debugPrint release modda da çalışır (Flutter bunu
          // otomatik kaldırmaz) - bu yüzden kDebugMode kontrolüyle
          // sarmalıyoruz, aksi halde ham hata detayları üretimde cihaz
          // loglarına sızabilir.
          // TODO: Gerçek üründe burada Sentry/Crashlytics gibi bir hata
          // izleme servisine gönder.
          if (kDebugMode) {
            debugPrint('[AggregatorService] ${p.providerName} sağlayıcısı başarısız oldu: $e\n$stackTrace');
          }
          return <Scooter>[];
        }
      }),
    );

    final allScooters = results
        .expand((list) => list)
        .where((s) => s.isAvailable) // BUG FIX: müsait olmayan araçlar listeye/tıklamaya hiç girmemeli
        .toList();

    switch (sortBy) {
      case SortBy.distance:
        allScooters.sort((a, b) => _distance(latitude, longitude, a)
            .compareTo(_distance(latitude, longitude, b)));
        break;
      case SortBy.price:
        allScooters.sort((a, b) => a
            .estimateFareForMinutes(10)
            .compareTo(b.estimateFareForMinutes(10)));
        break;
      case SortBy.battery:
        allScooters.sort((a, b) => b.batteryPercent.compareTo(a.batteryPercent));
        break;
    }

    return allScooters;
  }

  double _distance(double lat, double lng, Scooter s) {
    // Haversine formülü ile metre cinsinden mesafe
    const R = 6371000.0;
    final dLat = _toRad(s.latitude - lat);
    final dLng = _toRad(s.longitude - lng);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat)) * cos(_toRad(s.latitude)) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  double distanceInMeters(double lat, double lng, Scooter s) =>
      _distance(lat, lng, s);
}
