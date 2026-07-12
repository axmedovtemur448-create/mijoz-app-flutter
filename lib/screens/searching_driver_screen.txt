import 'package:flutter/material.dart';
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

class _SearchingDriverScreenState extends State<SearchingDriverScreen> {
  @override
  void initState() {
    super.initState();
    // Haqiqiy tizimda shu yerda serverdan haydovchi qidiriladi.
    // Hozircha 3 soniyalik animatsiyadan so'ng haydovchi "topiladi".
    Future.delayed(const Duration(seconds: 3), () {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15181F),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: const Color(0xFFFFC800).withOpacity(0.5),
                  ),
                ),
                const Icon(Icons.local_taxi, color: Color(0xFFFFC800), size: 48),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Haydovchi qidirilmoqda...",
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("${widget.tariffName} • ${widget.price}",
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
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
            ),
          ],
        ),
      ),
    );
  }
}
