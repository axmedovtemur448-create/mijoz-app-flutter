import 'package:flutter/material.dart';

class ServiceInfo {
  final String id;
  final String name;
  final String emoji;
  final Color color;

  const ServiceInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });
}

const List<ServiceInfo> kServices = [
  ServiceInfo(id: "taxi", name: "Taksi", emoji: "🚕", color: Color(0xFFFFC800)),
  ServiceInfo(id: "food", name: "Ovqat yetkazish", emoji: "🍔", color: Color(0xFFFF6B35)),
  ServiceInfo(id: "market", name: "Bozor mahsulotlari", emoji: "🧺", color: Color(0xFF2E9E4F)),
  ServiceInfo(id: "pharmacy", name: "Dorixona", emoji: "➕", color: Color(0xFF2E9E4F)),
  ServiceInfo(id: "water", name: "Suv yetkazish", emoji: "💧", color: Color(0xFF3B9DE8)),
  ServiceInfo(id: "gas", name: "Gaz ballon", emoji: "🛢️", color: Color(0xFFE13B3B)),
  ServiceInfo(id: "cleaning", name: "Uy tozalash", emoji: "🧹", color: Color(0xFFF2B705)),
  ServiceInfo(id: "master", name: "Usta chaqirish", emoji: "🔧", color: Color(0xFF3B5BDB)),
  ServiceInfo(id: "cargo", name: "Yuk toshish", emoji: "🚚", color: Color(0xFF495057)),
  ServiceInfo(id: "tow", name: "Evakuator", emoji: "🚛", color: Color(0xFFF2A900)),
  ServiceInfo(id: "carwash", name: "Avtoyuvish", emoji: "🚿", color: Color(0xFF3B9DE8)),
  ServiceInfo(id: "fuel", name: "Yoqilg'i yetkazish", emoji: "⛽", color: Color(0xFFE13B3B)),
  ServiceInfo(id: "excavator", name: "Ekiskavatir", emoji: "🚜", color: Color(0xFFF2A900)),
  ServiceInfo(id: "tire", name: "Shina xizmati", emoji: "🛞", color: Color(0xFF212529)),
  ServiceInfo(id: "hotel", name: "Mehmonxona", emoji: "🏨", color: Color(0xFF3B5BDB)),
  ServiceInfo(id: "flight", name: "Avia chipta", emoji: "✈️", color: Color(0xFF3B9DE8)),
  ServiceInfo(id: "train", name: "Poyezd chipta", emoji: "🚆", color: Color(0xFF1B2A4A)),
  ServiceInfo(id: "barber", name: "Sartarosh", emoji: "✂️", color: Color(0xFF3B5BDB)),
  ServiceInfo(id: "flowers", name: "Gul yetkazish", emoji: "🌹", color: Color(0xFFE13B6B)),
];
