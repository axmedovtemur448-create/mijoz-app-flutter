import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsTemplatesScreen extends StatefulWidget {
  final String phoneNumber;

  const SmsTemplatesScreen({super.key, required this.phoneNumber});

  @override
  State<SmsTemplatesScreen> createState() => _SmsTemplatesScreenState();
}

class _SmsTemplatesScreenState extends State<SmsTemplatesScreen> {
  final List<String> _templates = const [
    "Men manzilga chiqdim, kutib turing",
    "Bir necha daqiqada kelaman",
    "Iltimos, meni kuting",
    "Qayerdasiz?",
    "Manzilni o'zgartirsam bo'ladimi?",
  ];

  int? _selected;
  final TextEditingController _customController = TextEditingController();

  Future<void> _send(String text) async {
    final uri = Uri(scheme: 'sms', path: widget.phoneNumber, queryParameters: {'body': text});
    try {
      await launchUrl(uri);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SMS ilovasini ochib bo'lmadi")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1B1B1B),
        title: const Text("Xabar yuborish", style: TextStyle(color: Color(0xFF1B1B1B))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...List.generate(_templates.length, (i) {
              return RadioListTile<int>(
                value: i,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
                activeColor: const Color(0xFFFFC800),
                title: Text(_templates[i]),
                contentPadding: EdgeInsets.zero,
              );
            }),
            RadioListTile<int>(
              value: _templates.length,
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v),
              activeColor: const Color(0xFFFFC800),
              title: const Text("O'zim yozaman"),
              contentPadding: EdgeInsets.zero,
            ),
            if (_selected == _templates.length)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: TextField(
                  controller: _customController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Xabaringizni yozing...",
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
                  backgroundColor: const Color(0xFFFFC800),
                  foregroundColor: const Color(0xFF1B1B1B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _selected == null
                    ? null
                    : () {
                        final text = _selected == _templates.length ? _customController.text : _templates[_selected!];
                        if (text.trim().isEmpty) return;
                        _send(text);
                      },
                child: const Text("Yuborish", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
