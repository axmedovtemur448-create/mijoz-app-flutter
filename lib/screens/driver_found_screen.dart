import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'driver_coming_screen.dart';

// Haydovchi "topilgach", u buyurtmani qabul qilguncha bo'lgan bosqich:
// mijoz va haydovchi orasida pульslanuvchi yashil chiziq ko'rsatiladi.
class DriverFoundScreen extends StatefulWidget {
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final String fromAddress;
  final String toAddress;
  final String tariffName;
  final String price;

  const DriverFoundScreen({
    super.key,
    required this.fromLatLng,
    required this.toLatLng,
    required this.fromAddress,
    required this.toAddress,
    required this.tariffName,
    required this.price,
  });

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen> with SingleTickerProviderStateMixin {
  late final LatLng _driverStart;
  bool _accepted = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _driverStart = LatLng(widget.fromLatLng.latitude + 0.006, widget.fromLatLng.longitude - 0.004);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

    // "So'rov yuborildi" -> 2.5 soniyadan keyin "qabul qilindi"
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _accepted = true);
    });
    // Yana 1.2 soniyadan keyin haydovchi kelish sahifasiga o'tadi
    Future.delayed(const Duration(milliseconds: 3700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => DriverComingScreen(
          fromLatLng: widget.fromLatLng,
          toLatLng: widget.toLatLng,
          fromAddress: widget.fromAddress,
          toAddress: widget.toAddress,
          tariffName: widget.tariffName,
          price: widget.price,
          driverStart: _driverStart,
        ),
      ));
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: widget.fromLatLng,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sizningkompaniya.mijozapp',
                ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return PolylineLayer(polylines: [
                      Polyline(
                        points: [widget.fromLatLng, _driverStart],
                        color: const Color(0xFF2E9E4F).withOpacity(0.4 + 0.6 * _pulseController.value),
                        strokeWidth: 4,
                      ),
                    ]);
                  },
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: widget.fromLatLng,
                    width: 22,
                    height: 22,
                    child: const Icon(Icons.circle, color: Color(0xFF2E9E4F), size: 16),
                  ),
                  Marker(
                    point: _driverStart,
                    width: 34,
                    height: 34,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC800),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(Icons.local_taxi, color: Color(0xFF1B1B1B), size: 18),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.15))),

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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: const BoxDecoration(
                  color: Color(0xFF1C1F27),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _accepted ? Icons.check_circle : Icons.sync,
                      color: _accepted ? const Color(0xFF2E9E4F) : const Color(0xFFFFC800),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _accepted ? "Haydovchi qabul qildi!" : "Mashina topildi, so'rov yuborilmoqda...",
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text("${widget.tariffName} • ${widget.price}", style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
