import 'package:flutter/material.dart';
import '../data/services.dart';
import '../widgets/service_item.dart';
import '../widgets/banner_card.dart';
import 'services_screen.dart';
import 'taxi_order_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeServices = kServices.take(12).toList();

    void goToServices() {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServicesScreen()));
    }

    void goToTaxiOrder() {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxiOrderScreen()));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundIconButton(Icons.menu),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Salom, Ahmad!", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B))),
                    Text("Qayerga boramiz?", style: TextStyle(fontSize: 13, color: Color(0xFF8A8A8A))),
                  ],
                ),
                _roundIconButton(Icons.notifications_none),
              ],
            ),
            const SizedBox(height: 16),

            BannerCardWidget(
              imageAsset: "assets/banner-taxi.png",
              title: "Taksi",
              subtitle: "Tez va qulay\nxizmat",
              onPressed: goToTaxiOrder,
              onTapWhole: goToTaxiOrder,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Xizmatlar", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B))),
                GestureDetector(
                  onTap: goToServices,
                  child: const Text("Barchasi ›", style: TextStyle(fontSize: 13, color: Color(0xFF8A8A8A))),
                ),
              ],
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
              children: homeServices
                  .map((s) => ServiceItemWidget(
                        service: s,
                        onTap: s.id == "taxi" ? goToTaxiOrder : goToServices,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Do'stlaringizni taklif qiling",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B1B1B))),
                        SizedBox(height: 4),
                        Text("10 000 so'mgacha bonus oling!", style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B))),
                      ],
                    ),
                  ),
                  const Icon(Icons.card_giftcard, color: Color(0xFFF2A900), size: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundIconButton(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
      child: Icon(icon, color: const Color(0xFF1B1B1B), size: 22),
    );
  }
}
