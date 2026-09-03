import 'package:flutter_map/flutter_map.dart';

// Lớp dùng chung cho màn bản đồ và map xem trước
TileLayer osmTileLayer() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.petcare.smart_pet_care_app',
);

// Ảnh vệ tinh
TileLayer satelliteTileLayer() => TileLayer(
  urlTemplate:
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  userAgentPackageName: 'com.petcare.smart_pet_care_app',
);

// Nhãn đường địa danh phủ lên ảnh vệ tinh
TileLayer satelliteLabelsTileLayer() => TileLayer(
  urlTemplate:
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
  userAgentPackageName: 'com.petcare.smart_pet_care_app',
);
