import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/address/widgets/map_tiles.dart';
import 'package:url_launcher/url_launcher.dart';

// Mở trình xem ảnh toàn màn
void showImageViewer(
  BuildContext context,
  List<Uint8List> images,
  int initialIndex,
) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (_) => _ImageViewer(images: images, initialIndex: initialIndex),
  );
}

// Mở bản đồ toàn màn để xem tương tác vị trí đã gửi
void showLocationViewer(BuildContext context, LatLng location) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _LocationViewer(location: location),
    ),
  );
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.images, required this.initialIndex});

  final List<Uint8List> images;
  final int initialIndex;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(child: Image.memory(widget.images[i])),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationViewer extends StatelessWidget {
  const _LocationViewer({required this.location});

  final LatLng location;

  // Mở Google Maps chỉ đường tới điểm này
  Future<void> _chiDuong(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final loi = context.l10n.khongMoDuocBanDo;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${location.latitude},${location.longitude}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) messenger.showSnackBar(SnackBar(content: Text(loi)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(loi)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: location, initialZoom: 16),
            children: [
              voyagerTileLayer(),
              MarkerLayer(
                markers: [
                  Marker(
                    point: location,
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
              child: FilledButton.icon(
                onPressed: () => _chiDuong(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.directions_outlined),
                label: Text(context.l10n.xemDuongDi),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
