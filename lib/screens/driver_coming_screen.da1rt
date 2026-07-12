import 'package:flutter/material.dart';
import '../widgets/mock_map_background.dart';

class DriverComingScreen extends StatelessWidget {
  const DriverComingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15181F),
      body: Stack(
        children: [
          const Positioned.fill(child: MockMapBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _circleIconButton(Icons.arrow_back, () => Navigator.of(context).pop()),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text("Haydovchi kelyapti",
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      _circleIconButton(Icons.headset_mic_outlined, () {}),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: const Color(0xFF23262F), borderRadius: BorderRadius.circular(12)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sizning haydovchingiz", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text("2 daqiqada yetib keladi", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1C1F27), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(radius: 26, backgroundColor: Color(0xFF3B5BDB), child: Icon(Icons.person, color: Colors.white)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Text("Jasur", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 6),
                                    Icon(Icons.star, color: Color(0xFFFFC800), size: 14),
                                    Text(" 4.9", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                                const Text("Chevrolet Cobalt • 01 123 ABC", style: TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          _circleIconButton(Icons.call_outlined, () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Qo'ng'iroq funksiyasi tez orada qo'shiladi")),
                            );
                          }),
                          const SizedBox(width: 8),
                          _circleIconButton(Icons.sms_outlined, () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Xabar funksiyasi tez orada qo'shiladi")),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statColumn("Masofa", "8.2 km"),
                          _statColumn("Vaqt", "18 daqiqa"),
                          _statColumn("Narx", "25 000 so'm"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                          child: const Text("Buyurtmani bekor qilish", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
