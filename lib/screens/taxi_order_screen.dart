import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'searching_driver_screen.dart';

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

  // Xaritadan qaysi maydon uchun manzil tanlanayotganini bildiradi
  String _pickTarget = "to"; // "from" yoki "to"

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
    setState(() {
      _locatingFrom = true;
      _fromAddress = "Joylashuv aniqlanmoqda...";
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _fromAddress = "Joylashuv xizmati o'chirilgan (GPS'ni yoqing)";
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

      // Tezkor: oxirgi ma'lum joylashuv (agar bo'lsa) darhol ko'rsatiladi
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final quickLatLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        setState(() => _fromLatLng = quickLatLng);
        _mapController.move(quickLatLng, 15);
      }

      // Aniq joylashuv - bir necha marta urinib ko'ramiz (GPS "sovuq" bo'lishi mumkin)
      Position? pos;
      for (int attempt = 0; attempt < 3 && pos == null; attempt++) {
        try {
          pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
          ).timeout(const Duration(seconds: 15));
        } catch (_) {
          pos = null;
        }
      }

      pos ??= lastKnown;
      if (pos == null) {
        setState(() {
          _fromAddress = "Joylashuvni aniqlab bo'lmadi, qayta urinib ko'ring";
          _locatingFrom = false;
        });
        return;
      }

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
        _locatingFrom = false;
        if (_fromLatLng == null) _fromAddress = "Joylashuvni aniqlab bo'lmadi";
      });
    }
  }

  Future<String> _reverseGeocode(LatLng point) async {
    try {
      final uri = Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}");
      final res = await http.get(uri, headers: {"User-Agent": "mijoz_app_flutter"}).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data["display_name"] ?? "Noma'lum manzil";
      }
    } catch (_) {}
    return "Manzil: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
  }

  void _onMapTap(TapPosition tapPos, LatLng point) async {
    if (_pickTarget == "from") {
      setState(() {
        _fromLatLng = point;
        _fromAddress = "";
        _locatingFrom = true;
      });
      final address = await _reverseGeocode(point);
      if (!mounted) return;
      setState(() {
        _fromAddress = address;
        _locatingFrom = false;
        _pickTarget = "to";
      });
    } else {
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
  }

  void _startPicking(String target) {
    setState(() => _pickTarget = target);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(target == "from" ? "Xaritadan \"Qayerdan\" manzilini bosing" : "Xaritadan \"Qayerga\" manzilini bosing"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _callDriver() {
    final from = _fromLatLng ?? const LatLng(41.311081, 69.240562);
    final to = _toLatLng ?? LatLng(from.latitude + 0.01, from.longitude + 0.01);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SearchingDriverScreen(
        fromLatLng: from,
        toLatLng: to,
        fromAddress: _fromAddress,
        toAddress: _toLatLng == null ? "Belgilanmagan" : _toAddress,
        tariffName: _vehicles[_selectedVehicle]["name"]!,
        price: _vehicles[_selectedVehicle]["price"]!,
      ),
    ));
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
                        width: 46,
                        height: 46,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF3B9DE8).withOpacity(0.25),
                          ),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B9DE8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
                            ),
                          ),
                        ),
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
                  _circleIconButton(Icons.arrow_back, () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(10)),
                    child: const Text("Taksi chaqirish",
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  _circleIconButton(Icons.gps_fixed, _detectCurrentLocation),
                ],
              ),
            ),
          ),

          if (_pickTarget != "")
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 56),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      _pickTarget == "from" ? "Xaritani bosib \"Qayerdan\"ni belgilang" : "Xaritani bosib \"Qayerga\"ni belgilang",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
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
                  _AddressRow(
                    dotColor: const Color(0xFF2E9E4F),
                    label: "Qayerdan",
                    loading: _locatingFrom,
                    value: _fromAddress,
                    onPickFromMap: () => _startPicking("from"),
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  _AddressRow(
                    dotColor: const Color(0xFFE13B3B),
                    label: "Qayerga",
                    loading: _locatingTo,
                    value: _toLatLng == null ? "Xaritadan belgilang" : _toAddress,
                    onPickFromMap: () => _startPicking("to"),
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
                      child: const Text("Taksi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
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
  final VoidCallback onPickFromMap;

  const _AddressRow({
    required this.dotColor,
    required this.label,
    required this.value,
    required this.onPickFromMap,
    this.loading = false,
  });

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
        GestureDetector(
          onTap: onPickFromMap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF23262F), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.map_outlined, color: Color(0xFFFFC800), size: 18),
          ),
        ),
      ],
    );
  }
}
