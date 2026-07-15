import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'driver_found_screen.dart';

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

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => DriverFoundScreen(
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
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.2))),

          // Qora signal - dumaloq bo'lib tarqaladi (radar effekti)
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _pulseCircle(_controller.value),
                      _pulseCircle((_controller.value + 0.5) % 1),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E9E4F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
            child: SafeArea(
              top: false,
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
          ),
        ],
      ),
    );
  }

  Widget _pulseCircle(double progress) {
    return Opacity(
      opacity: (1 - progress).clamp(0, 1),
      child: Container(
        width: 220 * progress,
        height: 220 * progress,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
      ),
    );
  }
}
