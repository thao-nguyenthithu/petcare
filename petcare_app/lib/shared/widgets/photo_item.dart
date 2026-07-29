import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Một ảnh trong trình xem
class PhotoItem {
  const PhotoItem.mang(String this.url, {this.ngayThem})
    : bytes = null,
      asset = null;
  const PhotoItem.bytes(Uint8List this.bytes, {this.ngayThem})
    : url = null,
      asset = null;

  const PhotoItem.asset(String this.asset, {this.ngayThem})
    : url = null,
      bytes = null;

  final String? url;
  final Uint8List? bytes;
  final String? asset;

  // Ngày đăng ảnh
  final DateTime? ngayThem;
}

class PhotoThumb extends StatelessWidget {
  const PhotoThumb({
    super.key,
    required this.anh,
    this.fit = BoxFit.cover,
    this.canh,
  });

  final PhotoItem anh;
  final BoxFit fit;
  final double? canh;

  @override
  Widget build(BuildContext context) {
    if (anh.bytes != null) {
      return Image.memory(anh.bytes!, width: canh, height: canh, fit: fit);
    }
    if (anh.asset != null) {
      return Image.asset(anh.asset!, width: canh, height: canh, fit: fit);
    }
    return CachedNetworkImage(
      imageUrl: anh.url!,
      width: canh,
      height: canh,
      fit: fit,
      placeholder: (_, _) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      errorWidget: (_, _, _) =>
          const Icon(Icons.broken_image, color: Colors.white54),
    );
  }
}
