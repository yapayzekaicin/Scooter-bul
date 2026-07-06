import 'package:flutter/material.dart';
import '../adapters/mock_adapters.dart';
import '../models/scooter.dart';
import '../services/aggregator_service.dart';
import 'scooter_detail_screen.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  // Şimdilik sabit bir konum kullanıyoruz (İstanbul, Kadıköy civarı).
  // Gerçek uygulamada geolocator paketiyle kullanıcının GPS konumu alınır.
  static const double _demoLat = 40.9909;
  static const double _demoLng = 29.0303;

  late final AggregatorService _service;
  List<Scooter> _scooters = [];
  bool _loading = true;
  SortBy _sortBy = SortBy.distance;

  @override
  void initState() {
    super.initState();
    _service = AggregatorService([
      MartiAdapter(),
      BinBinAdapter(),
      TaziAdapter(),
      HopAdapter(),
    ]);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final scooters = await _service.fetchAllNearby(
      latitude: _demoLat,
      longitude: _demoLng,
      radiusMeters: 800,
      sortBy: _sortBy,
    );
    setState(() {
      _scooters = scooters;
      _loading = false;
    });
  }

  Color _providerColor(String providerId) {
    switch (providerId) {
      case 'marti':
        return const Color(0xFF00B4A0);
      case 'binbin':
        return const Color(0xFFFF6B35);
      case 'tazi':
        return const Color(0xFF6C5CE7);
      case 'hop':
        return const Color(0xFFE63946);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakındaki Scooter\'lar'),
        actions: [
          PopupMenuButton<SortBy>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _load();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: SortBy.distance, child: Text('Mesafeye göre')),
              PopupMenuItem(value: SortBy.price, child: Text('Fiyata göre')),
              PopupMenuItem(value: SortBy.battery, child: Text('Şarja göre')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _scooters.length,
                itemBuilder: (context, index) {
                  final s = _scooters[index];
                  final distance = _service.distanceInMeters(_demoLat, _demoLng, s);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _providerColor(s.providerId),
                        child: const Icon(Icons.electric_scooter, color: Colors.white),
                      ),
                      title: Text('${s.providerName} · ${distance.toStringAsFixed(0)} m'),
                      subtitle: Text(
                        'Açılış ${s.unlockFee.toStringAsFixed(2)} TL + '
                        '${s.perMinuteFee.toStringAsFixed(2)} TL/dk · '
                        '🔋 %${s.batteryPercent.toStringAsFixed(0)}',
                      ),
                      trailing: Text(
                        '${s.estimateFareForMinutes(10).toStringAsFixed(2)} TL\n(10 dk)',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScooterDetailScreen(scooter: s, distanceMeters: distance),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
