import 'package:flutter/material.dart';
import '../widgets/mock_map_background.dart';
import 'driver_coming_screen.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  int _selectedVehicle = 1;
  final TextEditingController _toController = TextEditingController();

  final _vehicles = const [
    {"name": "Econom", "price": "~25 000 so'm", "time": "4 daqiqa", "icon": Icons.directions_car},
    {"name": "Komfort", "price": "~35 000 so'm", "time": "6 daqiqa", "icon": Icons.directions_car_filled},
    {"name": "Biznes", "price": "~55 000 so'm", "time": "8 daqiqa", "icon": Icons.local_taxi},
  ];

  void _callDriver() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DriverComingScreen()));
  }

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
                        child: Text("Taksi chaqirish", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      _circleIconButton(Icons.gps_fixed, () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Joylashuv aniqlandi: Amir Temur ko'chasi, 1")),
                        );
                      }),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.my_location, color: Color(0xFFFFC800), size: 16),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Manzilim", style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text("Amir Temur ko'chasi, 1", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  decoration: const BoxDecoration(color: Color(0xFF1C1F27), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AddressRow(
                        dotColor: const Color(0xFF2E9E4F),
                        label: "Qayerdan",
                        value: "Amir Temur ko'chasi, 1",
                        trailing: TextButton(
                          onPressed: () {},
                          child: const Text("Manzilni o'zgartirish", style: TextStyle(color: Color(0xFFFFC800), fontSize: 12)),
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 20),
                      _AddressRow(
                        dotColor: const Color(0xFFE13B3B),
                        label: "Qayerga",
                        valueWidget: TextField(
                          controller: _toController,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "Manzilni tanlang (yoki xaritadan belgilang)",
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                        ),
                        trailing: const Icon(Icons.add, color: Colors.white54, size: 20),
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
                                    Icon(v["icon"] as IconData, color: selected ? const Color(0xFFFFC800) : Colors.white70, size: 26),
                                    const SizedBox(height: 6),
                                    Text(v["name"] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                    Text(v["price"] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                    Text(v["time"] as String, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statColumn("Masofa", "8.2 km"),
                          _statColumn("Vaqt", "18 daqiqa"),
                          _statColumn("Narx", _vehicles[_selectedVehicle]["price"] as String),
                        ],
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
                          child: const Text("Haydovchini chaqirish", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

class _AddressRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? trailing;

  const _AddressRow({required this.dotColor, required this.label, this.value, this.valueWidget, this.trailing});

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
              valueWidget ?? Text(value ?? "", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
