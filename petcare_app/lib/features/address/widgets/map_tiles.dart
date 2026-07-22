import 'package:flutter_map/flutter_map.dart';

// Lớp dùng chung cho màn bản đồ và map xem trước
TileLayer voyagerTileLayer() => TileLayer(
  urlTemplate:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  subdomains: const ['a', 'b', 'c', 'd'],
  userAgentPackageName: 'com.smartpetcare.app',
);
