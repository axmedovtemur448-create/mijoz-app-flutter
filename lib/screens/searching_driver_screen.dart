import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'driver_found_screen.dart';

class SearchingDriverScreen extends StatefulWidget {
  final int orderId;
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final String fromAddress;
  final String toAddress;
  final String tariffName;
  final String price;

  const SearchingDriverScreen({
    super.key,
    required this.orderId,
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
  Timer? _pollTimer;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final order = await ApiService.getOrderStatus(widget.orderId);
    if (!mounted || order == null) return;
    final status = order["status"];
    if (status == "assigned") {
      _pollTimer?.cancel();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => DriverFoundScreen(
          orderId: widget.orderId,
          fromLatLng: widget.fromLatLng,
          toLatLng: widget.toLatLng,
          fromAddress: widget.fromAddress,
          toAddress: widget.toAddress,
          tariffName: widget.tariffName,
          price: widget.price,
          driverName: order["driver_name"] ?? "Haydovchi",
          driverPhone: order["driver_phone"] ?? "",
          driverCar: order["driver_car"] ?? "",
          driverPlate: order["driver_plate"] ?? "",
        ),
      ));
    } else if (status == "cancelled") {
      _pollTimer?.cancel();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _cancel() async {
    if (_cancelling) return;
    setState(() => _cancelling = true);
    await ApiService.cancelOrder(widget.orderId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pollTimer?.cancel();
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
                        onPressed: _cancelling ? null : _cancel,
                        child: Text(_cancelling ? "Bekor qilinmoqda..." : "Bekor qilish",
                            style: const TextStyle(color: Color(0xFFE13B3B), fontWeight: FontWeight.w600)),
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
