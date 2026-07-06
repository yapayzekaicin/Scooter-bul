import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/scooter.dart';
import 'provider_adapter.dart';

/// ŞABLON: Bir firmayla (örn. Martı) gerçek API ortaklığı kurulduğunda
/// bu dosyayı kopyalayıp doldur, sonra main.dart'ta
/// MartiAdapter() yerine RealApiAdapter(...) kullan. Başka hiçbir
/// ekranı değiştirmene gerek yok.
///
/// GÜVENLİK NOTU: `apiKey`'i asla kaynak koda yazıp Git'e commit etme.
/// Üretimde bunu --dart-define ile derleme zamanında enjekte et veya
/// flutter_secure_storage ile cihazda şifreli sakla. Bu şablonda alan
/// olarak tutulması sadece örnekleme amaçlıdır.
class RealApiAdapter implements ProviderAdapter {
  final String baseUrl;   // örn: 'https://api.marti.com.tr/v1'
  final String apiKey;    // Firma ile yapılan anlaşma sonrası verilen anahtar

  RealApiAdapter({
    required this.providerId,
    required this.providerName,
    required this.baseUrl,
    required this.apiKey,
  }) {
    // GÜVENLİK: yanlışlıkla http (şifresiz) bir adrese kimlik bilgisi
    // göndermeyi engelle - API anahtarı düz metin olarak ağda akmasın.
    assert(baseUrl.startsWith('https://'),
        'baseUrl mutlaka https:// ile başlamalı, aksi halde API anahtarı şifresiz iletilir.');
  }

  @override
  final String providerId;

  @override
  final String providerName;

  static const _requestTimeout = Duration(seconds: 10);

  @override
  Future<List<Scooter>> fetchNearbyVehicles({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    // TODO: Firmanın gerçek endpoint'ine ve response formatına göre düzenle.
    // Çoğu mikromobilite firması GBFS (General Bikeshare Feed Specification)
    // standardını destekler: https://github.com/MobilityData/gbfs
    // Eğer firma GBFS destekliyorsa bu kısım neredeyse değişmeden çalışır.
    final uri = Uri.parse('$baseUrl/vehicles/nearby').replace(queryParameters: {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'radius': radiusMeters.toString(),
    });

    // BUG FIX: timeout yoktu -> sunucu yanıt vermezse istek sonsuza kadar
    // asılı kalıp ekranı sürekli "yükleniyor" durumunda bırakabilirdi.
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $apiKey',
    }).timeout(_requestTimeout, onTimeout: () {
      throw TimeoutException('$providerName API zaman aşımına uğradı');
    });

    if (response.statusCode != 200) {
      throw Exception('$providerName API hatası: ${response.statusCode}');
    }

    // BUG FIX: ham JSON'u tip güvenliği/null kontrolü olmadan doğrudan
    // modele geçiriyordu -> firma API'si beklenmedik bir alan eksik
    // bıraktığında veya farklı bir tip döndürdüğünde (örn. id bir int
    // olarak gelirse) uygulama o sağlayıcı için sessizce çökerdi.
    // Artık her alan güvenli şekilde ayrıştırılıyor ve eksik/bozuk kayıt
    // atlanıyor (tüm listeyi çökertmek yerine).
    List<dynamic> data;
    try {
      data = jsonDecode(response.body) as List<dynamic>;
    } catch (_) {
      throw Exception('$providerName API beklenmeyen bir formatta yanıt döndürdü');
    }

    final scooters = <Scooter>[];
    for (final raw in data) {
      final scooter = _tryParseScooter(raw);
      if (scooter != null) {
        scooters.add(scooter);
      } else {
        if (kDebugMode) {
          debugPrint('[$providerName] Ayrıştırılamayan kayıt atlandı: $raw');
        }
      }
    }
    return scooters;
  }

  Scooter? _tryParseScooter(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final id = raw['id'];
    final lat = raw['lat'];
    final lng = raw['lng'];
    // id/lat/lng olmadan bir scooter anlamsız - bunları zorunlu tut,
    // geri kalan alanlar için makul varsayılanlara düş.
    if (id == null || lat == null || lng == null) return null;

    double? asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    final latitude = asDouble(lat);
    final longitude = asDouble(lng);
    if (latitude == null || longitude == null) return null;

    return Scooter(
      id: id.toString(),
      providerId: providerId,
      providerName: providerName,
      latitude: latitude,
      longitude: longitude,
      batteryPercent: asDouble(raw['battery']) ?? 0,
      unlockFee: asDouble(raw['unlock_fee']) ?? 0,
      perMinuteFee: asDouble(raw['per_minute_fee']) ?? 0,
      isAvailable: raw['available'] == true,
      vehicleType: raw['type']?.toString() ?? 'scooter',
    );
  }

  @override
  Future<UnlockResult> unlock(String scooterId) async {
    final uri = Uri.parse('$baseUrl/vehicles/$scooterId/unlock');
    try {
      final response = await http.post(uri, headers: {
        'Authorization': 'Bearer $apiKey',
      }).timeout(_requestTimeout, onTimeout: () {
        throw TimeoutException('$providerName kilit açma isteği zaman aşımına uğradı');
      });

      // BUG FIX: sunucudan gelen ham hata gövdesi (response.body) doğrudan
      // kullanıcıya gösteriliyordu. Bu, sunucu hata sayfası/stack trace
      // içeriyorsa kullanıcıya iç sistem bilgisi sızdırabilir. Artık
      // kullanıcıya sadece genel bir mesaj gösteriyoruz, detayı sadece
      // logluyoruz.
      if (response.statusCode == 200) {
        return UnlockResult(success: true, message: '$providerName kilidi açıldı');
      }
      if (kDebugMode) {
        debugPrint('[$providerName] Kilit açma hatası (${response.statusCode}): ${response.body}');
      }
      return UnlockResult(
        success: false,
        message: '$providerName kilidi açılamadı, lütfen tekrar deneyin.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$providerName] Kilit açma isteği başarısız: $e');
      }
      return UnlockResult(
        success: false,
        message: '$providerName ile bağlantı kurulamadı, lütfen tekrar deneyin.',
      );
    }
  }
}
