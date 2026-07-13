import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'driver_coming_screen.dart';

class SearchingDriverScreen extends StatefulWidget {
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final String fromAddress;
  final String toAddress;
  final String tariffName;
  final String price;

  const SearchingDriverScreen({
    super.key,
    required this.fromLatLng,
    required this.toLatLng,
    required this.fromAddress,
    required this.toAddress,
    required this.tariffName,
    required this.price,
  });

  @override
  State<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends State<SearchingDriverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    // Haqiqiy tizimda shu yerda serverdan haydovchi qidiriladi.
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => DriverComingScreen(
          fromLatLng: widget.fromLatLng,
          toLatLng: widget.toLatLng,
          fromAddress: widget.fromAddress,
          toAddress: widget.toAddress,
          tariffName: widget.tariffName,
          price: widget.price,
        ),
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fon - haqiqiy xarita, mijoz manzili markazda
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(initialCenter: widget.fromLatLng, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sizningkompaniya.mijozapp',
                ),
              ],
            ),
          ),
          // Qorong'ilashtiruvchi yengil parda, matn o'qilishi uchun
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.25))),

          // Radar animatsiyasi + aylanib qidirayotgan taksi
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value; // 0..1
                return SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _radarRing(1 - t),
                      _radarRing((1 - t + 0.5) % 1),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(color: Color(0xFF2E9E4F), shape: BoxShape.circle),
                      ),
                      Transform.translate(
                        offset: Offset(70 * cos(t * 2 * pi), 70 * sin(t * 2 * pi)),
                        child: Transform.rotate(
                          angle: t * 2 * pi + pi / 2,
                          child: const Icon(Icons.local_taxi, color: Color(0xFFFFC800), size: 30,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 6)]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.4)),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1F27),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Haydovchi qidirilmoqda...",
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("${widget.tariffName} • ${widget.price}",
                      style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE13B3B)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Bekor qilish", style: TextStyle(color: Color(0xFFE13B3B), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radarRing(double progress) {
    return Container(
      width: 220 * progress,
      height: 220 * progress,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFC800).withOpacity(1 - progress), width: 2),
      ),
    );
  }
}
