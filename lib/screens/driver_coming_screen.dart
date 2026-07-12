import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cancel_reason_screen.dart';
import 'sms_templates_screen.dart';
import 'trip_completed_screen.dart';

enum _Phase { arriving, inTrip }

class DriverComingScreen extends StatefulWidget {
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final String fromAddress;
  final String toAddress;
  final String tariffName;
  final String price;

  const DriverComingScreen({
    super.key,
    required this.fromLatLng,
    required this.toLatLng,
    required this.fromAddress,
    required this.toAddress,
    required this.tariffName,
    required this.price,
  });

  @override
  State<DriverComingScreen> createState() => _DriverComingScreenState();
}

class _DriverComingScreenState extends State<DriverComingScreen> {
  static const _driverPhone = "+998901234567"; // Namuna raqam
  static const _driverName = "Jasur";

  _Phase _phase = _Phase.arriving;
  late LatLng _driverPos; // haydovchi joriy holati (animatsiya uchun)
  late LatLng _tripStart; // joriy bosqich boshlanish nuqtasi
  late LatLng _tripEnd; // joriy bosqich tugash nuqtasi

  Timer? _timer;
  double _progress = 0; // 0..1
  static const _stepMs = 200;
  final int _arrivingDurationMs = 8000;
  late int _tripDurationMs;

  @override
  void initState() {
    super.initState();
    // Haydovchi mashinasi mijozdan ~600m uzoqlikda "boshlanadi"
    _driverPos = LatLng(widget.fromLatLng.latitude + 0.004, widget.fromLatLng.longitude - 0.003);
    _tripStart = _driverPos;
    _tripEnd = widget.fromLatLng;

    final distanceMeters = Geolocator.distanceBetween(
      widget.fromLatLng.latitude,
      widget.fromLatLng.longitude,
      widget.toLatLng.latitude,
      widget.toLatLng.longitude,
    );
    // Simulyatsiya tezligi: ~40 km/soat
    _tripDurationMs = ((distanceMeters / 1000) / 40 * 3600 * 1000).clamp(6000, 20000).toInt();

    _startTimer(_arrivingDurationMs);
  }

  void _startTimer(int durationMs) {
    _progress = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: _stepMs), (t) {
      setState(() {
        _progress += _stepMs / durationMs;
        if (_progress >= 1) {
          _progress = 1;
          _driverPos = _tripEnd;
          t.cancel();
          _onPhaseComplete();
        } else {
          _driverPos = LatLng(
            _tripStart.latitude + (_tripEnd.latitude - _tripStart.latitude) * _progress,
            _tripStart.longitude + (_tripEnd.longitude - _tripStart.longitude) * _progress,
          );
        }
      });
    });
  }

  void _onPhaseComplete() {
    if (_phase == _Phase.arriving) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Haydovchi yetib keldi! Safar boshlandi.")),
      );
      setState(() {
        _phase = _Phase.inTrip;
        _tripStart = widget.fromLatLng;
        _tripEnd = widget.toLatLng;
      });
      _startTimer(_tripDurationMs);
    } else {
      final distanceKm = (Geolocator.distanceBetween(
                widget.fromLatLng.latitude,
                widget.fromLatLng.longitude,
                widget.toLatLng.latitude,
                widget.toLatLng.longitude,
              ) /
              1000)
          .toStringAsFixed(1);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => TripCompletedScreen(distanceKm: distanceKm, price: widget.price, driverName: _driverName),
      ));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: _driverPhone);
    try {
      await launchUrl(uri);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Qo'ng'iroq qilib bo'lmadi")));
    }
  }

  void _openSms() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SmsTemplatesScreen(phoneNumber: _driverPhone)));
  }

  void _cancelOrder() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CancelReasonScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final etaMinutes = _phase == _Phase.arriving
        ? (((1 - _progress) * _arrivingDurationMs) / 60000).ceil().clamp(0, 99)
        : (((1 - _progress) * _tripDurationMs) / 60000).ceil().clamp(0, 99);

    return Scaffold(
      backgroundColor: const Color(0xFF15181F),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _driverPos,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sizningkompaniya.mijozapp',
                ),
                PolylineLayer(polylines: [
                  Polyline(points: [_tripStart, _tripEnd], color: const Color(0xFFFFC800), strokeWidth: 4),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: widget.fromLatLng,
                    width: 26,
                    height: 26,
                    child: const Icon(Icons.circle, color: Color(0xFF2E9E4F), size: 16),
                  ),
                  Marker(
                    point: widget.toLatLng,
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.location_on, color: Color(0xFFE13B3B), size: 28),
                  ),
                  Marker(
                    point: _driverPos,
                    width: 34,
                    height: 34,
                    child: const Icon(Icons.local_taxi, color: Color(0xFFFFC800), size: 30),
                  ),
                ]),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _circleIconButton(Icons.arrow_back, () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        _phase == _Phase.arriving ? "Haydovchi kelyapti" : "Safar davom etmoqda",
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1F27),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _phase == _Phase.arriving ? "$etaMinutes daqiqada yetib keladi" : "Manzilga $etaMinutes daqiqa qoldi",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(radius: 26, backgroundColor: Color(0xFF3B5BDB), child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Text(_driverName, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 6),
                                Icon(Icons.star, color: Color(0xFFFFC800), size: 14),
                                Text(" 4.9", style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                            Text("Chevrolet Cobalt • 01 123 ABC", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      _circleIconButton(Icons.call_outlined, _call),
                      const SizedBox(width: 8),
                      _circleIconButton(Icons.sms_outlined, _openSms),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statColumn("Tarif", widget.tariffName),
                      _statColumn("Narx", widget.price),
                      _statColumn("Holat", _phase == _Phase.arriving ? "Kelmoqda" : "Yo'lda"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE13B3B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _cancelOrder,
                      child: const Text("Bekor qilish", style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _statColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(color: Color(0xFF23262F), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
