import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';

// Ô xem trước bản đồ, chạm để mở lại màn chọn vị trí.
class MapPreview extends StatelessWidget {
  const MapPreview({super.key, required this.viTri, required this.onDoi});

  final LatLng viTri;
  final VoidCallback onDoi;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            FlutterMap(
              key: ValueKey(viTri),
              options: MapOptions(
                initialCenter: viTri,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                voyagerTileLayer(),
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
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onDoi),
              ),
            ),
            Positioned(
              right: AppSpacing.itemGap,
              bottom: AppSpacing.itemGap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_location_alt_outlined,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.chamDeDoiViTri,
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
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
