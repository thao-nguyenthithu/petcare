import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';
import 'package:petcare_app/shared/utils/mo_chi_duong.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

void showLocationViewer(
  BuildContext context,
  LatLng viTri, {
  bool chiDuong = true,
  String? tieuDe,
  String? diaChi,
  List<String> dongPhu = const [],
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _LocationViewer(
        viTri: viTri,
        chiDuong: chiDuong,
        tieuDe: tieuDe,
        diaChi: diaChi,
        dongPhu: dongPhu,
      ),
    ),
  );
}

class _LocationViewer extends StatelessWidget {
  const _LocationViewer({
    required this.viTri,
    required this.chiDuong,
    this.tieuDe,
    this.diaChi,
    this.dongPhu = const [],
  });

  final LatLng viTri;
  final bool chiDuong;
  final String? tieuDe;
  final String? diaChi;
  final List<String> dongPhu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: viTri, initialZoom: 16),
            children: [
              voyagerTileLayer(),
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
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.surface,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            bottom: AppSpacing.screenPadding,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tieuDe != null || diaChi != null || dongPhu.isNotEmpty)
                    _TheThongTin(
                      tieuDe: tieuDe,
                      diaChi: diaChi,
                      dongPhu: dongPhu,
                    ),
                  if (chiDuong) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => moChiDuong(context, viTri),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.directions_outlined),
                      label: Text(context.l10n.xemDuongDi),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TheThongTin extends StatelessWidget {
  const _TheThongTin({
    required this.tieuDe,
    required this.diaChi,
    required this.dongPhu,
  });

  final String? tieuDe;
  final String? diaChi;
  final List<String> dongPhu;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      vien: false,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tieuDe case final ten?) Text(ten, style: AppTextStyles.label),
          if (diaChi case final dc?) ...[
            const SizedBox(height: 4),
            Text(dc, style: AppTextStyles.captionSm),
          ],
          if (dongPhu.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              dongPhu.join(' · '),
              style: AppTextStyles.captionSm.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
