import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'driver_coming_screen.dart';

// Backend'da "accept" atomar (birinchi bosgan haydovchi darhol
// biriktiriladi), shuning uchun bu sahifa faqat qisqa
// "Haydovchi topildi!" animatsiyasi sifatida ishlaydi.
class DriverFoundScreen extends StatefulWidget {
  final int orderId;
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final String fromAddress;
  final String toAddress;
  final String tariffName;
  final String price;
  final String driverName;
  final String driverPhone;
  final String driverCar;
  final String driverPlate;

  const DriverFoundScreen({
    super.key,
    required this.orderId,
    required this.fromLatLng,
    required this.toLatLng,
    required this.fromAddress,
    required this.toAddress,
    required this.tariffName,
    required this.price,
    required this.driverName,
    required this.driverPhone,
    required this.driverCar,
    required this.driverPlate,
  });

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen> {
  LatLng? _driverStart;

  @override
  void initState() {
    super.initState();
    _loadDriverPosAndContinue();
  }

  Future<void> _loadDriverPosAndContinue() async {
    final order = await ApiService.getOrderStatus(widget.orderId);
    LatLng start = LatLng(widget.fromLatLng.latitude + 0.006, widget.fromLatLng.longitude - 0.004);
    if (order != null && order["driver_lat"] != null && order["driver_lng"] != null) {
      start = LatLng((order["driver_lat"] as num).toDouble(), (order["driver_lng"] as num).toDouble());
    }
    if (mounted) setState(() => _driverStart = start);

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => DriverComingScreen(
        orderId: widget.orderId,
        fromLatLng: widget.fromLatLng,
        toLatLng: widget.toLatLng,
        fromAddress: widget.fromAddress,
        toAddress: widget.toAddress,
        tariffName: widget.tariffName,
        price: widget.price,
        driverStart: start,
        driverName: widget.driverName,
        driverPhone: widget.driverPhone,
        driverCar: widget.driverCar,
        driverPlate: widget.driverPlate,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(initialCenter: widget.fromLatLng, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sizningkompaniya.mijozapp',
                ),
                if (_driverStart != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: widget.fromLatLng,
                      width: 22,
                      height: 22,
                      child: const Icon(Icons.circle, color: Color(0xFF2E9E4F), size: 16),
                    ),
                    Marker(
                      point: _driverStart!,
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
                    const Icon(Icons.check_circle, color: Color(0xFF2E9E4F), size: 40),
                    const SizedBox(height: 12),
                    Text("Haydovchi topildi: ${widget.driverName}!",
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
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
