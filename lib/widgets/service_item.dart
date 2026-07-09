import 'package:flutter/material.dart';
import '../data/services.dart';

class ServiceItemWidget extends StatelessWidget {
  final ServiceInfo service;
  final VoidCallback? onTap;

  const ServiceItemWidget({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEFEFEF)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(service.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 8),
            Text(
              service.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1B1B1B)),
            ),
          ],
        ),
      ),
    );
  }
}
