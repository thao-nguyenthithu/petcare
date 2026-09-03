import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/sitter/widgets/profile/circle_icon_button.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';

// Zoom ước lượng để vòng bán kính nằm gọn trong khung map
double zoomTheoBanKinh(int km) {
  if (km <= 1) return 13.5;
  if (km <= 3) return 12.5;
  if (km <= 5) return 11.8;
  if (km <= 10) return 11;
  return 10.2;
}

List<Widget> lopBanDoKhuVuc(
  LatLng viTri,
  int radiusKm, {
  bool chinhChu = true,
}) => [
  osmTileLayer(),
  CircleLayer(
    circles: [
      CircleMarker(
        point: viTri,
        radius: radiusKm * 1000,
        useRadiusInMeter: true,
        color: AppColors.primaryColor.withValues(alpha: 0.15),
        borderColor: AppColors.primaryColor,
        borderStrokeWidth: 2,
      ),
    ],
  ),
  if (chinhChu)
    MarkerLayer(
      markers: [
        Marker(
          point: viTri,
          width: 40,
          height: 40,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.location_on,
            color: AppColors.primaryColor,
            size: 32,
          ),
        ),
      ],
    ),
];

// Mở bản đồ toàn màn hình, tương tác phóng to/thu nhỏ
Future<void> moXemBanDo(
  BuildContext context,
  LatLng viTri,
  int radiusKm, {
  bool chinhChu = true,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          _BanDoScreen(viTri: viTri, radiusKm: radiusKm, chinhChu: chinhChu),
    ),
  );
}

class _BanDoScreen extends StatelessWidget {
  const _BanDoScreen({
    required this.viTri,
    required this.radiusKm,
    required this.chinhChu,
  });

  final LatLng viTri;
  final int radiusKm;
  final bool chinhChu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: viTri,
              initialZoom: zoomTheoBanKinh(radiusKm),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: lopBanDoKhuVuc(viTri, radiusKm, chinhChu: chinhChu),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
