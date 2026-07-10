import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String title;
  final String emoji;

  const ServiceDetailScreen({super.key, required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)), onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
