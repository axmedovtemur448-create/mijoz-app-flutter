import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/routing_service.dart';
import 'cancel_reason_screen.dart';
import 'sms_templates_screen.dart';
import 'trip_completed_screen.dart';

enum _Phase { loading, arriving, inTrip }

class DriverComingScreen extends StatefulWidget {
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final String fromAddress;
  final String toAddress;
  final String tariffName;
  final String price;
  final LatLng? driverStart;

  const DriverComingScreen({
    super.key,
    required this.fromLatLng,
    required this.toLatLng,
    required this.fromAddress,
    required this.toAddress,
    required this.tariffName,
    required this.price,
    this.driverStart,
  });

  @override
  State<DriverComingScreen> createState() => _DriverComingScreenState();
}

class _DriverComingScreenState extends State<DriverComingScreen> {
  static const _driverPhone = "+998901234567";
  static const _driverName = "Jasur";

  _Phase _phase = _Phase.loading;
  late LatLng _driverStart;
  List<LatLng> _arrivingRoute = [];
  List<LatLng> _tripRoute = [];
  LatLng _driverPos = const LatLng(0, 0);

  Timer? _timer;
  double _progress = 0;
  static const _stepMs = 200;
  int _arrivingDurationMs = 8000;
  int _tripDurationMs = 10000;

  @override
  void initState() {
    super.initState();
    _driverStart = widget.driverStart ?? LatLng(widget.fromLatLng.latitude + 0.006, widget.fromLatLng.longitude - 0.004);
    _driverPos = _driverStart;
    _loadRoutesAndStart();
  }

  Future<void> _loadRoutesAndStart() async {
    final arrivingResult = await fetchRoute(_driverStart, widget.fromLatLng);
    final tripResult = await fetchRoute(widget.fromLatLng, widget.toLatLng);
    if (!mounted) return;

    setState(() {
      _arrivingRoute = arrivingResult.points;
      _tripRoute = tripResult.points;
      _arrivingDurationMs = ((arrivingResult.distanceMeters / 1000) / 35 * 3600 * 1000).clamp(5000, 15000).toInt();
      _tripDurationMs = ((tripResult.distanceMeters / 1000) / 40 * 3600 * 1000).clamp(6000, 25000).toInt();
      _phase = _Phase.arriving;
    });
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
          final route = _phase == _Phase.arriving ? _arrivingRoute : _tripRoute;
          _driverPos = route.isNotEmpty ? route.last : _driverPos;
          t.cancel();
          _onPhaseComplete();
        } else {
          final route = _phase == _Phase.arriving ? _arrivingRoute : _tripRoute;
          _driverPos = pointAlongRoute(route, _progress);
        }
      });
    });
  }

  void _onPhaseComplete() {
    if (_phase == _Phase.arriving) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Haydovchi yetib keldi! Safar boshlandi.")),
      );
      setState(() => _phase = _Phase.inTrip);
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
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CancelReasonScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF15181F),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC800))),
      );
    }

    final currentRoute = _phase == _Phase.arriving ? _arrivingRoute : _tripRoute;
    final trail = routeUpToProgress(currentRoute, _progress);
    final durationMs = _phase == _Phase.arriving ? _arrivingDurationMs : _tripDurationMs;
    final etaMinutes = (((1 - _progress) * durationMs) / 60000).ceil().clamp(0, 99);

    return Scaffold(
      backgroundColor: const Color(0xFF15181F),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(initialCenter: _driverPos, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sizningkompaniya.mijozapp',
                ),
                if (currentRoute.length > 1)
                  PolylineLayer(polylines: [
                    Polyline(points: currentRoute, color: Colors.white24, strokeWidth: 4),
                    Polyline(points: trail, color: const Color(0xFFFFC800), strokeWidth: 5),
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
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC800),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 3))],
                      ),
                      child: const Icon(Icons.local_taxi, color: Color(0xFF1B1B1B), size: 22),
                    ),
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
            child: SafeArea(
              top: false,
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
