import 'package:flutter/material.dart';

class TripCompletedScreen extends StatefulWidget {
  final String distanceKm;
  final String price;
  final String driverName;

  const TripCompletedScreen({
    super.key,
    required this.distanceKm,
    required this.price,
    required this.driverName,
  });

  @override
  State<TripCompletedScreen> createState() => _TripCompletedScreenState();
}

class _TripCompletedScreenState extends State<TripCompletedScreen> {
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF2E9E4F), size: 64),
              const SizedBox(height: 16),
              const Text("Safar yakunlandi!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B))),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat("Masofa", "${widget.distanceKm} km"),
                    _stat("Narx", widget.price),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text("Haydovchi ${widget.driverName}ni baholang", style: const TextStyle(fontSize: 15, color: Color(0xFF1B1B1B))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return IconButton(
                    onPressed: () => setState(() => _rating = i + 1),
                    icon: Icon(filled ? Icons.star : Icons.star_border, color: const Color(0xFFFFC800), size: 36),
                  );
                }),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC800),
                    foregroundColor: const Color(0xFF1B1B1B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text("Yakunlash", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFF1B1B1B), fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
