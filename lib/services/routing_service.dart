import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// OSRM (Open Source Routing Machine) - OpenStreetMap yo'llari asosida
// haqiqiy marshrutni hisoblab beradi (to'g'ri chiziq emas, yo'l bo'ylab).
class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;

  RouteResult(this.points, this.distanceMeters);
}

Future<RouteResult> fetchRoute(LatLng start, LatLng end) async {
  try {
    final uri = Uri.parse(
      "https://router.project-osrm.org/route/v1/driving/"
      "${start.longitude},${start.latitude};${end.longitude},${end.latitude}"
      "?overview=full&geometries=geojson",
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final coords = data["routes"][0]["geometry"]["coordinates"] as List;
      final distance = (data["routes"][0]["distance"] as num).toDouble();
      final points = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
      return RouteResult(points, distance);
    }
  } catch (_) {}
  // Marshrut topilmasa - to'g'ri chiziq bilan zaxira variant
  final dist = Geolocator.distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude);
  return RouteResult([start, end], dist);
}

// Marshrut nuqtalari bo'ylab, 0..1 progress asosida joriy pozitsiyani topadi
LatLng pointAlongRoute(List<LatLng> route, double progress) {
  if (route.length < 2) return route.isNotEmpty ? route.first : const LatLng(0, 0);
  progress = progress.clamp(0, 1);

  final segLengths = <double>[];
  double total = 0;
  for (int i = 0; i < route.length - 1; i++) {
    final d = Geolocator.distanceBetween(
      route[i].latitude, route[i].longitude, route[i + 1].latitude, route[i + 1].longitude,
    );
    segLengths.add(d);
    total += d;
  }
  if (total == 0) return route.first;

  double target = total * progress;
  double covered = 0;
  for (int i = 0; i < segLengths.length; i++) {
    if (covered + segLengths[i] >= target) {
      final segProgress = segLengths[i] == 0 ? 0 : (target - covered) / segLengths[i];
      return LatLng(
        route[i].latitude + (route[i + 1].latitude - route[i].latitude) * segProgress,
        route[i].longitude + (route[i + 1].longitude - route[i].longitude) * segProgress,
      );
    }
    covered += segLengths[i];
  }
  return route.last;
}

// Marshrutning boshidan joriy progressgacha bo'lgan qismini qaytaradi
// (mashina orqasidan "chizilib boruvchi" chiziq uchun)
List<LatLng> routeUpToProgress(List<LatLng> route, double progress) {
  if (route.length < 2) return route;
  progress = progress.clamp(0, 1);

  final segLengths = <double>[];
  double total = 0;
  for (int i = 0; i < route.length - 1; i++) {
    final d = Geolocator.distanceBetween(
      route[i].latitude, route[i].longitude, route[i + 1].latitude, route[i + 1].longitude,
    );
    segLengths.add(d);
    total += d;
  }
  if (total == 0) return route;

  double target = total * progress;
  double covered = 0;
  final result = <LatLng>[route.first];
  for (int i = 0; i < segLengths.length; i++) {
    if (covered + segLengths[i] >= target) {
      final segProgress = segLengths[i] == 0 ? 0 : (target - covered) / segLengths[i];
      result.add(LatLng(
        route[i].latitude + (route[i + 1].latitude - route[i].latitude) * segProgress,
        route[i].longitude + (route[i + 1].longitude - route[i].longitude) * segProgress,
      ));
      return result;
    }
    result.add(route[i + 1]);
    covered += segLengths[i];
  }
  return result;
}
