import 'package:flutter_map/flutter_map.dart';

// Lớp dùng chung cho màn bản đồ và map xem trước
TileLayer voyagerTileLayer() => TileLayer(
  urlTemplate:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  subdomains: const ['a', 'b', 'c', 'd'],
  userAgentPackageName: 'com.smartpetcare.app',
);

// Ảnh vệ tinh
TileLayer satelliteTileLayer() => TileLayer(
  urlTemplate:
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  userAgentPackageName: 'com.smartpetcare.app',
);

// Nhãn đường địa danh phủ lên ảnh vệ tinh
TileLayer satelliteLabelsTileLayer() => TileLayer(
  urlTemplate:
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
  userAgentPackageName: 'com.smartpetcare.app',
);
