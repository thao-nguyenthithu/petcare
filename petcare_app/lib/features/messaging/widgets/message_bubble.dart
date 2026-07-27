import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/messaging/data/chat_message.dart';
import 'package:petcare_app/features/messaging/widgets/media_viewers.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';

// Một bong bóng chat
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.onRetry});

  final ChatMessage message;
  final VoidCallback? onRetry; // gửi lại khi tin thất bại

  @override
  Widget build(BuildContext context) {
    final me = message.fromMe;
    final child = switch (message.kind) {
      ChatMessageKind.image => _ImageContent(message: message),
      ChatMessageKind.location => _LocationBubble(message: message),
      _ => _TextBubble(message: message),
    };
    return Column(
      crossAxisAlignment: me
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: me
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                ),
                child: child,
              ),
            ),
          ],
        ),
        if (message.masked) ...[
          const SizedBox(height: AppSpacing.textGap),
          const _MaskedNotice(),
        ],
        if (message.timeLabel != null || message.status != null) ...[
          const SizedBox(height: 3),
          _Meta(message: message, onRetry: onRetry),
        ],
      ],
    );
  }
}

// Nền góc bong bóng
BoxDecoration _bubbleDecoration(bool me) {
  const tail = Radius.circular(4);
  const full = Radius.circular(AppRadius.radius14);
  return BoxDecoration(
    color: me ? AppColors.primaryColor : AppColors.surface,
    border: me ? null : Border.all(color: AppColors.neutralLight),
    borderRadius: BorderRadius.only(
      topLeft: full,
      topRight: full,
      bottomLeft: me ? full : tail,
      bottomRight: me ? tail : full,
    ),
  );
}

// Bong bóng chữ
class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final me = message.fromMe;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: _bubbleDecoration(me),
      child: Text(
        message.text,
        style: AppTextStyles.body.copyWith(
          fontSize: 13,
          color: me ? AppColors.textWhite : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// Nội dung ảnh không nền bong bóng, bấm để xem to
class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final images = message.images;
    if (images == null || images.isEmpty) {
      return _Placeholder(
        icon: Icons.image_outlined,
        label: context.l10n.anhGuiKem,
      );
    }
    return images.length == 1
        ? _Photo(
            bytes: images.first,
            width: 180,
            height: 130,
            onTap: () => showImageViewer(context, images, 0),
          )
        : _PhotoGrid(images: images);
  }
}

// Tin vị trí, bản đồ thu nhỏ bấm mở toàn màn
class _LocationBubble extends StatelessWidget {
  const _LocationBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final me = message.fromMe;
    final loc = message.location;
    final Widget content = loc == null
        ? _Placeholder(
            icon: Icons.location_on_outlined,
            label: context.l10n.viTriHienTai,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showLocationViewer(context, loc),
                child: _MapPreview(location: loc, width: 200),
              ),
              if (message.caption != null) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: 200,
                  child: Text(
                    message.caption!,
                    style: AppTextStyles.captionSm.copyWith(
                      fontSize: 12,
                      color: me ? AppColors.textWhite : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          );
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _bubbleDecoration(me),
      child: content,
    );
  }
}

// Một ảnh đơn
class _Photo extends StatelessWidget {
  const _Photo({
    required this.bytes,
    required this.width,
    required this.height,
    this.onTap,
  });

  final Uint8List bytes;
  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Lưới ảnh 3 cột, n hàng
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.images});

  final List<Uint8List> images;

  static const double _gridWidth = 234;
  static const double _gap = 4;
  static const int _cols = 3;

  @override
  Widget build(BuildContext context) {
    final cell = (_gridWidth - _gap * (_cols - 1)) / _cols;
    return SizedBox(
      width: _gridWidth,
      child: Wrap(
        spacing: _gap,
        runSpacing: _gap,
        children: [
          for (var i = 0; i < images.length; i++)
            _Photo(
              bytes: images[i],
              width: cell,
              height: cell,
              onTap: () => showImageViewer(context, images, i),
            ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.cardMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(height: AppSpacing.textGap),
          Text(label, style: AppTextStyles.captionSm.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

// Bản đồ thu nhỏ
class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.location, required this.width});

  final LatLng location;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: 130,
        child: IgnorePointer(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: location,
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
                    point: location,
                    width: 34,
                    height: 34,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primaryColor,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dòng meta dưới bong bóng
class _Meta extends StatelessWidget {
  const _Meta({required this.message, this.onRetry});

  final ChatMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final base = AppTextStyles.captionSm.copyWith(fontSize: 10);
    final children = <Widget>[];
    if (message.timeLabel != null) {
      children.add(Text(message.timeLabel!, style: base));
    }
    switch (message.status) {
      case ChatSendStatus.sending:
        children.add(
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        );
        children.add(Text(l10n.dangGui, style: base));
      case ChatSendStatus.sent:
        children.add(Text(l10n.daGui, style: base));
      case ChatSendStatus.read:
        children.add(Text(l10n.daDoc, style: base));
      case ChatSendStatus.failed:
        children.add(
          Text(
            l10n.guiThatBai,
            style: base.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        children.add(
          InkWell(
            onTap: onRetry,
            child: Text(
              l10n.thuLai,
              style: base.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      case null:
        break;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          children[i],
        ],
      ],
    );
  }
}

// Cảnh báo khi số điện thoại trong tin bị ẩn
class _MaskedNotice extends StatelessWidget {
  const _MaskedNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_outlined, size: 13, color: AppColors.accent),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            context.l10n.soDienThoaiDaAn,
            style: AppTextStyles.captionSm.copyWith(
              fontSize: 12,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}
