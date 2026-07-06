import 'package:flutter/material.dart';
import 'screens/nearby_screen.dart';

void main() {
  runApp(const ScooterAggregatorApp());
}

class ScooterAggregatorApp extends StatelessWidget {
  const ScooterAggregatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scooter Bul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00B4A0),
        useMaterial3: true,
      ),
      home: const NearbyScreen(),
    );
  }
}
