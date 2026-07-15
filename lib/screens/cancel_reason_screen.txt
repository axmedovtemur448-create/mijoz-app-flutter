import 'package:flutter/material.dart';

class CancelReasonScreen extends StatefulWidget {
  const CancelReasonScreen({super.key});

  @override
  State<CancelReasonScreen> createState() => _CancelReasonScreenState();
}

class _CancelReasonScreenState extends State<CancelReasonScreen> {
  final List<String> _reasons = const [
    "Kutish vaqti juda uzoq",
    "Fikrimdan qaytdim",
    "Manzilni noto'g'ri kiritdim",
    "Narx mos kelmadi",
    "Haydovchi bilan bog'lana olmadim",
  ];

  int? _selected;
  final TextEditingController _customController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1B1B1B),
        title: const Text("Bekor qilish sababi", style: TextStyle(color: Color(0xFF1B1B1B))),
      ),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...List.generate(_reasons.length, (i) {
              return RadioListTile<int>(
                value: i,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
                activeColor: const Color(0xFFE13B3B),
                title: Text(_reasons[i]),
                contentPadding: EdgeInsets.zero,
              );
            }),
            RadioListTile<int>(
              value: _reasons.length,
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v),
              activeColor: const Color(0xFFE13B3B),
              title: const Text("Boshqa sabab"),
              contentPadding: EdgeInsets.zero,
            ),
            if (_selected == _reasons.length)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: TextField(
                  controller: _customController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Sababni yozing...",
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE13B3B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _selected == null
                    ? null
                    : () {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Buyurtma bekor qilindi")),
                        );
                      },
                child: const Text("Bekor qilish", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
