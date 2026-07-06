/// Tüm scooter sağlayıcılarının (Martı, BinBin, Tazı, HOP...) ortak
/// veri formatına çevrildiği model. Yeni bir sağlayıcı eklendiğinde
/// tek yapılması gereken bu modele doğru bir "adapter" yazmaktır.
class Scooter {
  final String id;              // Sağlayıcıya özel benzersiz kimlik
  final String providerId;      // 'marti' | 'binbin' | 'tazi' | 'hop' ...
  final String providerName;    // Ekranda gösterilecek isim
  final double latitude;
  final double longitude;
  final double batteryPercent;  // 0-100
  final double unlockFee;       // TL, açılış ücreti
  final double perMinuteFee;    // TL, dakika ücreti
  final bool isAvailable;
  final String? vehicleType;    // 'scooter' | 'ebike' | 'moped'

  const Scooter({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.latitude,
    required this.longitude,
    required this.batteryPercent,
    required this.unlockFee,
    required this.perMinuteFee,
    this.isAvailable = true,
    this.vehicleType = 'scooter',
  });

  /// 10 dakikalık tahmini sürüş ücreti - listede karşılaştırma için kullanılır
  double estimateFareForMinutes(int minutes) {
    return unlockFee + (perMinuteFee * minutes);
  }
}
