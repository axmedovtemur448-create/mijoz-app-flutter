import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MijozApp());
}

class MijozApp extends StatelessWidget {
  const MijozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mijoz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFC800),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const StartupScreen(),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissionAndContinue();
  }

  Future<void> _requestPermissionAndContinue() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }
      }
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RootScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFC800),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_taxi, size: 64, color: Color(0xFF1B1B1B)),
            SizedBox(height: 16),
            Text("Mijoz App", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B))),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFF1B1B1B)),
          ],
        ),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  final _tabs = const [
    HomeScreen(),
    _PlaceholderScreen(label: "Buyurtmalar"),
    _PlaceholderScreen(label: "Sevimlilar"),
    _PlaceholderScreen(label: "Profil"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFFFFC800),
        unselectedItemColor: const Color(0xFFB0B0B0),
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 24),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Bosh sahifa"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: "Buyurtmalar"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Sevimlilar"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text("$label sahifasi (keyin to'ldiramiz)", style: const TextStyle(color: Color(0xFF8A8A8A))),
      ),
    );
  }
}
