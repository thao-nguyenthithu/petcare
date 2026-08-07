import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';

// Mở trình xem ảnh toàn màn
void showImageViewer(
  BuildContext context,
  List<String> images,
  int initialIndex,
) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (_) => _ImageViewer(images: images, initialIndex: initialIndex),
  );
}

// Ảnh trong chat có hai nguồn: URL đã lên server và ảnh vừa chọn trên máy
Widget anhChat(
  BuildContext context,
  String nguon, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  if (nguon.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: nguon,
      width: width,
      height: height,
      fit: fit,
      // Bỏ trống bề ngang là ảnh xem toàn màn, lấy đúng bề ngang màn hình
      memCacheWidth: beRongCache(
        context,
        width ?? MediaQuery.sizeOf(context).width,
      ),
    );
  }
  return Image.file(File(nguon), width: width, height: height, fit: fit);
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.images, required this.initialIndex});

  final List<String> images;
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
              child: Center(child: anhChat(context, widget.images[i])),
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
