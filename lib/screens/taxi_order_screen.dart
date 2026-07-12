import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'driver_coming_screen.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  final MapController _mapController = MapController();

  LatLng? _fromLatLng;
  LatLng? _toLatLng;
  String _fromAddress = "Joylashuv aniqlanmoqda...";
  String _toAddress = "";
  bool _locatingFrom = true;
  bool _locatingTo = false;

  int _selectedVehicle = 0;

  final _vehicles = const [
    {"name": "Start", "price": "~25 000 so'm"},
    {"name": "Komfort", "price": "~35 000 so'm"},
    {"name": "Biznes", "price": "~55 000 so'm"},
  ];

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
  }

  Future<void> _detectCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _fromAddress = "Joylashuv xizmati o'chirilgan";
          _locatingFrom = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _fromAddress = "Joylashuvga ruxsat berilmadi";
          _locatingFrom = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _fromLatLng = latLng);
      _mapController.move(latLng, 15);
      final address = await _reverseGeocode(latLng);
      setState(() {
        _fromAddress = address;
        _locatingFrom = false;
      });
    } catch (_) {
      setState(() {
        _fromAddress = "Joylashuvni aniqlab bo'lmadi";
        _locatingFrom = false;
      });
    }
  }

  Future<String> _reverseGeocode(LatLng point) async {
    try {
      final uri = Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}");
      final res = await http.get(uri, headers: {"User-Agent": "mijoz_app_flutter"});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data["display_name"] ?? "Noma'lum manzil";
      }
    } catch (_) {}
    return "Manzil: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
  }

  void _onMapTap(TapPosition tapPos, LatLng point) async {
    setState(() {
      _toLatLng = point;
      _toAddress = "";
      _locatingTo = true;
    });
    final address = await _reverseGeocode(point);
    if (!mounted) return;
    setState(() {
      _toAddress = address;
      _locatingTo = false;
    });
  }

  void _callDriver() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DriverComingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15181F),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _fromLatLng ?? const LatLng(41.311081, 69.240562),
                initialZoom: 13,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sizningkompaniya.mijozapp',
                ),
                MarkerLayer(
                  markers: [
                    if (_fromLatLng != null)
                      Marker(
                        point: _fromLatLng!,
                        width: 36,
                        height: 36,
                        child: const Icon(Icons.circle, color: Color(0xFF2E9E4F), size: 20),
                      ),
                    if (_toLatLng != null)
                      Marker(
                        point: _toLatLng!,
                        width: 36,
                        height: 36,
                        child: const Icon(Icons.location_on, color: Color(0xFFE13B3B), size: 34),
                      ),
                  ],
                ),
                if (_fromLatLng != null && _toLatLng != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: [_fromLatLng!, _toLatLng!], color: const Color(0xFFFFC800), strokeWidth: 4),
                    ],
                  ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _circleIconButton(Icons.arrow_back, () => Navigator.of(context).pop(), dark: true),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(10)),
                    child: const Text("Taksi chaqirish",
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  _circleIconButton(Icons.gps_fixed, _detectCurrentLocation, dark: true),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _toLatLng == null ? "Manzilni tanlash uchun xaritani bosing" : " ",
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  _AddressRow(dotColor: const Color(0xFF2E9E4F), label: "Qayerdan", loading: _locatingFrom, value: _fromAddress),
                  const Divider(color: Colors.white12, height: 20),
                  _AddressRow(
                    dotColor: const Color(0xFFE13B3B),
                    label: "Qayerga",
                    loading: _locatingTo,
                    value: _toLatLng == null ? "Xaritadan belgilang" : _toAddress,
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: List.generate(_vehicles.length, (i) {
                      final v = _vehicles[i];
                      final selected = _selectedVehicle == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedVehicle = i),
                          child: Container(
                            margin: EdgeInsets.only(right: i != _vehicles.length - 1 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFFFFC800).withOpacity(0.12) : const Color(0xFF23262F),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: selected ? const Color(0xFFFFC800) : Colors.transparent, width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.local_taxi, color: selected ? const Color(0xFFFFC800) : Colors.white70, size: 24),
                                const SizedBox(height: 6),
                                Text(v["name"]!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                Text(v["price"]!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _callDriver,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC800),
                        foregroundColor: const Color(0xFF1B1B1B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text("Haydovchini chaqirish (${_vehicles[_selectedVehicle]["name"]})",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {bool dark = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;
  final bool loading;

  const _AddressRow({required this.dotColor, required this.label, required this.value, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 2),
              loading
                  ? const Text("Aniqlanmoqda...", style: TextStyle(color: Colors.white38, fontSize: 13))
                  : Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
