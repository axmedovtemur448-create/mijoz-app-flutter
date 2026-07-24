import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/routing_service.dart';
import '../services/api_service.dart';
import 'cancel_reason_screen.dart';
import 'sms_templates_screen.dart';
import 'trip_completed_screen.dart';

enum _Phase { arriving, inTrip }

class DriverComingScreen extends StatefulWidget {
  final int orderId;
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final String fromAddress;
  final String toAddress;
  final String tariffName;
  final String price;
  final LatLng driverStart;
  final String driverName;
  final String driverPhone;
  final String driverCar;
  final String driverPlate;

  const DriverComingScreen({
    super.key,
    required this.orderId,
    required this.fromLatLng,
    required this.toLatLng,
    required this.fromAddress,
    required this.toAddress,
    required this.tariffName,
    required this.price,
    required this.driverStart,
    required this.driverName,
    required this.driverPhone,
    required this.driverCar,
    required this.driverPlate,
  });

  @override
  State<DriverComingScreen> createState() => _DriverComingScreenState();
}

class _DriverComingScreenState extends State<DriverComingScreen> with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.arriving;
  List<LatLng> _arrivingRoute = [];
  List<LatLng> _tripRoute = [];

  late LatLng _driverPos;
  LatLng? _lastPolledPos;
  late AnimationController _moveController;
  Timer? _pollTimer;
  bool _routesLoaded = false;

  @override
  void initState() {
    super.initState();
    _driverPos = widget.driverStart;
    _moveController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _loadRoutes();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
    _poll();
  }

  Future<void> _loadRoutes() async {
    final arriving = await fetchRoute(widget.driverStart, widget.fromLatLng);
    final trip = await fetchRoute(widget.fromLatLng, widget.toLatLng);
    if (!mounted) return;
    setState(() {
      _arrivingRoute = arriving.points;
      _tripRoute = trip.points;
      _routesLoaded = true;
    });
  }

  Future<void> _poll() async {
    final order = await ApiService.getOrderStatus(widget.orderId);
    if (!mounted || order == null) return;

    final status = order["status"];
    if (status == "ongoing" && _phase == _Phase.arriving) {
      setState(() => _phase = _Phase.inTrip);
    } else if (status == "done") {
      _pollTimer?.cancel();
      final distanceKm = (Geolocator.distanceBetween(
                widget.fromLatLng.latitude,
                widget.fromLatLng.longitude,
                widget.toLatLng.latitude,
                widget.toLatLng.longitude,
              ) /
              1000)
          .toStringAsFixed(1);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => TripCompletedScreen(distanceKm: distanceKm, price: widget.price, driverName: widget.driverName),
      ));
      return;
    } else if (status == "cancelled") {
      _pollTimer?.cancel();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }

    if (order["driver_lat"] != null && order["driver_lng"] != null) {
      final newPos = LatLng((order["driver_lat"] as num).toDouble(), (order["driver_lng"] as num).toDouble());
      _animateTo(newPos);
    }
  }

  void _animateTo(LatLng newPos) {
    final oldPos = _driverPos;
    _lastPolledPos = newPos;
    _moveController.reset();
    void listener() {
      if (!mounted) return;
      final t = _moveController.value;
      setState(() {
        _driverPos = LatLng(
          oldPos.latitude + (newPos.latitude - oldPos.latitude) * t,
          oldPos.longitude + (newPos.longitude - oldPos.longitude) * t,
        );
      });
    }

    _moveController.addListener(listener);
    _moveController.forward().whenCompleteOrCancel(() => _moveController.removeListener(listener));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _moveController.dispose();
    super.dispose();
  }

  Future<void> _call() async {
    final phone = widget.driverPhone.isNotEmpty ? widget.driverPhone : "+998901234567";
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Qo'ng'iroq qilib bo'lmadi")));
    }
  }

  void _openSms() {
    final phone = widget.driverPhone.isNotEmpty ? widget.driverPhone : "+998901234567";
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SmsTemplatesScreen(phoneNumber: phone)));
  }

  void _cancelOrder() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CancelReasonScreen(orderId: widget.orderId)));
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _phase == _Phase.arriving ? _arrivingRoute : _tripRoute;
    List<LatLng> trail = [];
    if (currentRoute.length > 1) {
      // Mashinaga eng yaqin nuqtagacha bo'lgan yo'lni chizamiz (taxminiy)
      double best = double.infinity;
      int bestIdx = 0;
      for (int i = 0; i < currentRoute.length; i++) {
        final d = Geolocator.distanceBetween(
            currentRoute[i].latitude, currentRoute[i].longitude, _driverPos.latitude, _driverPos.longitude);
        if (d < best) {
          best = d;
          bestIdx = i;
        }
      }
      trail = [...currentRoute.sublist(0, bestIdx + 1), _driverPos];
    }

    return Scaffold(
      backgroundColor: const Color(0xFF15181F),
      body: Stack(
        children: [
          if (!_routesLoaded)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFFC800)))
          else
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
                      _phase == _Phase.arriving ? "Haydovchi yo'lda" : "Safar davom etmoqda",
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
                            children: [
                              Row(
                                children: [
                                  Text(widget.driverName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star, color: Color(0xFFFFC800), size: 14),
                                  const Text(" 4.9", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                              Text(
                                widget.driverCar.isNotEmpty || widget.driverPlate.isNotEmpty
                                    ? "${widget.driverCar} • ${widget.driverPlate}"
                                    : "Ma'lumot yuklanmoqda...",
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
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
