import 'package:flutter/material.dart';

class BannerCardWidget extends StatelessWidget {
  final String? imageAsset; // masalan "assets/banner-taxi.png"
  final Color bgColor;
  final String? badge;
  final String title;
  final String subtitle;
  final String buttonText;
  final bool dark;
  final VoidCallback? onPressed;
  final VoidCallback? onTapWhole;

  const BannerCardWidget({
    super.key,
    this.imageAsset,
    this.bgColor = const Color(0xFFFFC800),
    this.badge,
    required this.title,
    required this.subtitle,
    this.buttonText = "Buyurtma berish",
    this.dark = false,
    this.onPressed,
    this.onTapWhole,
  });

  @override
  Widget build(BuildContext context) {
    // Agar tayyor banner rasmi berilgan bo'lsa, uning ustiga qo'shimcha
    // matn chizmaymiz — chunki matn allaqachon rasmning ichida bor.
    if (imageAsset != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: onTapWhole ?? onPressed,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.72,
              child: Image.asset(imageAsset!, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }

    final textColor = dark ? Colors.white : const Color(0xFF1B1B1B);

    final content = Container(
      padding: const EdgeInsets.all(18),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC800),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("PREMIUM",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B))),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.85))),
            ],
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B1B1B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTapWhole,
        child: ClipRRect(borderRadius: BorderRadius.circular(18), child: content),
      ),
    );
  }
}
