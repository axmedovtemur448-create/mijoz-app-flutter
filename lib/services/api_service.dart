import 'dart:convert';
import 'package:http/http.dart' as http;

// JetCab serveriga ulanish uchun barcha funksiyalar shu yerda.
// Server manzili o'zgarsa, faqat shu bitta joyni tahrirlash kifoya.
class ApiService {
  static const String baseUrl = "https://jetcab-server.onrender.com";
  static const String defaultRegion = "qashqadaryo";

  // Hududdagi narxli tariflar ro'yxati
  static Future<List<Map<String, dynamic>>> fetchTariffs({String region = defaultRegion}) async {
    try {
      final uri = Uri.parse("$baseUrl/api/customer/tariffs?region=$region");
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return List<Map<String, dynamic>>.from(data["tariffs"] ?? []);
      }
    } catch (_) {}
    return [];
  }

  // Yangi buyurtma yaratish
  static Future<Map<String, dynamic>?> createOrder({
    required double pickupLat,
    required double pickupLng,
    required String pickupAddr,
    required double destLat,
    required double destLng,
    required String destAddr,
    required String tariff,
    required num price,
    required double distanceKm,
    String region = defaultRegion,
    String payment = "cash",
    String comment = "",
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/api/customer/orders");
      final res = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "region": region,
              "pickup_lat": pickupLat,
              "pickup_lng": pickupLng,
              "pickup_addr": pickupAddr,
              "dest_lat": destLat,
              "dest_lng": destLng,
              "dest_addr": destAddr,
              "tariff": tariff,
              "price": price,
              "distance_km": distanceKm,
              "payment": payment,
              "comment": comment,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (_) {}
    return null;
  }

  // Buyurtma holatini tekshirish (har necha soniyada chaqirib turiladi)
  static Future<Map<String, dynamic>?> getOrderStatus(int orderId) async {
    try {
      final uri = Uri.parse("$baseUrl/api/customer/orders/$orderId");
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (_) {}
    return null;
  }

  // Buyurtmani bekor qilish
  static Future<bool> cancelOrder(int orderId) async {
    try {
      final uri = Uri.parse("$baseUrl/api/customer/orders/$orderId/cancel");
      final res = await http.post(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data["ok"] == true;
      }
    } catch (_) {}
    return false;
  }
}
