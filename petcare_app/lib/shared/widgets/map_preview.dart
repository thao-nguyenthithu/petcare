import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Ô xem trước bản đồ
class MapPreview extends StatefulWidget {
  const MapPreview({
    super.key,
    required this.viTri,
    required this.onDoi,
    this.zoom = 16,
    this.banKinhKm,
    this.icon = Icons.edit_location_alt_outlined,
    this.nhan,
    this.khoa = false,
    this.hienGhim = true,
    this.duongDi = const <LatLng>[],
  });

  final bool hienGhim;
  final LatLng viTri;
  final VoidCallback onDoi;
  final double zoom;
  final int? banKinhKm;
  final IconData icon;
  final String? nhan;
  final bool khoa;
  final List<LatLng> duongDi;
  static const double _cao = 160;

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  final _dieuKhien = MapController();

  @override
  void dispose() {
    _dieuKhien.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MapPreview cu) {
    super.didUpdateWidget(cu);
    if (widget.khoa || cu.viTri == widget.viTri && cu.zoom == widget.zoom) {
      return;
    }
    try {
      _dieuKhien.move(widget.viTri, widget.zoom);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final viTri = widget.viTri;
    final banKinhKm = widget.banKinhKm;
    final khoa = widget.khoa;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: SizedBox(
        height: MapPreview._cao,
        child: Stack(
          children: [
            if (khoa)
              Positioned.fill(
                child: Container(
                  color: AppColors.background,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.map_outlined,
                    size: 34,
                    color: AppColors.neutral,
                  ),
                ),
              )
            else
              FlutterMap(
                mapController: _dieuKhien,
                options: MapOptions(
                  initialCenter: viTri,
                  initialZoom: widget.zoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  osmTileLayer(),
                  if (widget.duongDi.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: widget.duongDi,
                          strokeWidth: 4,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  if (banKinhKm != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: viTri,
                          radius: banKinhKm * 1000,
                          useRadiusInMeter: true,
                          color: AppColors.primaryColor.withValues(alpha: 0.15),
                          borderColor: AppColors.primaryColor,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                  if (widget.hienGhim)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: viTri,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child: const Align(
                            alignment: Alignment.bottomCenter,
                            child: Icon(
                              Icons.location_on,
                              color: AppColors.primaryColor,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            if (!khoa)
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(onTap: widget.onDoi),
                ),
              ),
            Positioned(
              left: khoa ? AppSpacing.itemGap : null,
              right: AppSpacing.itemGap,
              bottom: AppSpacing.itemGap,
              child: AppCard(
                vien: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      khoa ? Icons.lock_outline : widget.icon,
                      size: 16,
                      color: khoa
                          ? AppColors.textSecondary
                          : AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.nhan ?? context.l10n.chamDeDoiViTri,
                        style: AppTextStyles.label.copyWith(
                          color: khoa
                              ? AppColors.textSecondary
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
