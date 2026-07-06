import 'dart:math';
import '../models/scooter.dart';
import 'provider_adapter.dart';

/// Tüm mock adapter'lar için ortak sahte veri üretim mantığı.
/// Gerçek konum etrafında rastgele ama tutarlı (seed'li) noktalar üretir,
/// böylece harita üzerinde gerçekçi bir dağılım görürsün.
abstract class BaseMockAdapter implements ProviderAdapter {
  int get vehicleCount;
  double get baseUnlockFee;
  double get basePerMinuteFee;
  String get vehicleType => 'scooter';

  @override
  Future<List<Scooter>> fetchNearbyVehicles({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    // Gerçek bir ağ isteğini simüle etmek için küçük bir gecikme
    await Future.delayed(const Duration(milliseconds: 300));

    final random = Random(providerId.hashCode);
    final List<Scooter> result = [];

    for (int i = 0; i < vehicleCount; i++) {
      // Rastgele bir yön ve mesafe seçip merkeze göre yeni koordinat üret
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radiusMeters;
      // Kabaca metre -> derece dönüşümü
      final dLat = (distance * cos(angle)) / 111320.0;
      final dLng = (distance * sin(angle)) /
          (111320.0 * cos(latitude * pi / 180));

      result.add(Scooter(
        id: '$providerId-${i + 1}',
        providerId: providerId,
        providerName: providerName,
        latitude: latitude + dLat,
        longitude: longitude + dLng,
        batteryPercent: 20 + random.nextInt(80).toDouble(),
        unlockFee: baseUnlockFee,
        perMinuteFee: basePerMinuteFee,
        isAvailable: random.nextDouble() > 0.1, // %90 müsait
        vehicleType: vehicleType,
      ));
    }
    return result;
  }

  @override
  Future<UnlockResult> unlock(String scooterId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UnlockResult(
      success: true,
      message: '$providerName scooter kilidi açıldı (simülasyon). '
          'Gerçek entegrasyonda burası $providerName API\'sine istek atacak.',
    );
  }
}

class MartiAdapter extends BaseMockAdapter {
  @override
  String get providerId => 'marti';
  @override
  String get providerName => 'Martı';
  @override
  int get vehicleCount => 8;
  @override
  double get baseUnlockFee => 1.99;
  @override
  double get basePerMinuteFee => 0.79;
}

class BinBinAdapter extends BaseMockAdapter {
  @override
  String get providerId => 'binbin';
  @override
  String get providerName => 'BinBin';
  @override
  int get vehicleCount => 6;
  @override
  double get baseUnlockFee => 1.75;
  @override
  double get basePerMinuteFee => 0.69;
}

class TaziAdapter extends BaseMockAdapter {
  @override
  String get providerId => 'tazi';
  @override
  String get providerName => 'Tazı';
  @override
  int get vehicleCount => 4;
  @override
  double get baseUnlockFee => 2.00;
  @override
  double get basePerMinuteFee => 0.75;
}

class HopAdapter extends BaseMockAdapter {
  @override
  String get providerId => 'hop';
  @override
  String get providerName => 'HOP!';
  @override
  int get vehicleCount => 5;
  @override
  double get baseUnlockFee => 1.90;
  @override
  double get basePerMinuteFee => 0.72;
}
