import 'package:flutter/material.dart';

class MockMapBackground extends StatelessWidget {
  const MockMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF15181F),
      child: CustomPaint(size: Size.infinite, painter: _RoadsPainter()),
    );
  }
}

class _RoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 2;

    for (double y = 40; y < size.height; y += 90) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 30), paint);
    }
    for (double x = -40; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x + 60, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
