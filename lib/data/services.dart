import 'package:flutter/material.dart';

class ServiceInfo {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ServiceInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Barcha xizmatlar shu ro'yxatda. Yangi xizmat qo'shish uchun
// shu massivga bitta ServiceInfo qo'shsangiz bo'ldi — u avtomatik
// Bosh sahifada (birinchi 12 tasi) va "Barcha xizmatlar" sahifasida chiqadi.
const List<ServiceInfo> kServices = [
  ServiceInfo(id: "taxi", name: "Taksi", icon: Icons.local_taxi, color: Color(0xFFFFC800)),
  ServiceInfo(id: "food", name: "Ovqat yetkazish", icon: Icons.fastfood, color: Color(0xFFFF6B35)),
  ServiceInfo(id: "market", name: "Bozor mahsulotlari", icon: Icons.shopping_basket, color: Color(0xFF2E9E4F)),
  ServiceInfo(id: "pharmacy", name: "Dorixona", icon: Icons.local_pharmacy, color: Color(0xFF2E9E4F)),
  ServiceInfo(id: "water", name: "Suv yetkazish", icon: Icons.water_drop, color: Color(0xFF3B9DE8)),
  ServiceInfo(id: "gas", name: "Gaz ballon", icon: Icons.local_fire_department, color: Color(0xFFE13B3B)),
  ServiceInfo(id: "cleaning", name: "Uy tozalash", icon: Icons.cleaning_services, color: Color(0xFFF2B705)),
  ServiceInfo(id: "master", name: "Usta chaqirish", icon: Icons.build, color: Color(0xFF3B5BDB)),
  ServiceInfo(id: "cargo", name: "Yuk toshish", icon: Icons.local_shipping, color: Color(0xFF495057)),
  ServiceInfo(id: "tow", name: "Evakuator", icon: Icons.car_repair, color: Color(0xFFF2A900)),
  ServiceInfo(id: "carwash", name: "Avtoyuvish", icon: Icons.local_car_wash, color: Color(0xFF3B9DE8)),
  ServiceInfo(id: "fuel", name: "Yoqilg'i yetkazish", icon: Icons.local_gas_station, color: Color(0xFFE13B3B)),
  ServiceInfo(id: "excavator", name: "Ekiskavatir", icon: Icons.construction, color: Color(0xFFF2A900)),
  ServiceInfo(id: "tire", name: "Shina xizmati", icon: Icons.tire_repair, color: Color(0xFF212529)),
  ServiceInfo(id: "hotel", name: "Mehmonxona", icon: Icons.hotel, color: Color(0xFF3B5BDB)),
  ServiceInfo(id: "flight", name: "Avia chipta", icon: Icons.flight, color: Color(0xFF3B9DE8)),
  ServiceInfo(id: "train", name: "Poyezd chipta", icon: Icons.train, color: Color(0xFF1B2A4A)),
  ServiceInfo(id: "barber", name: "Sartarosh", icon: Icons.content_cut, color: Color(0xFF3B5BDB)),
  ServiceInfo(id: "flowers", name: "Gul yetkazish", icon: Icons.local_florist, color: Color(0xFFE13B6B)),
];
