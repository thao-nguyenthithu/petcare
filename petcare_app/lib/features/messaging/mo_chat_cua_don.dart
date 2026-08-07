import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/messaging/screens/chat_detail_screen.dart';
import 'package:petcare_app/features/messaging/services/messaging_api_service.dart';

// Mở chat từ một đơn, hỏi server hội thoại tương ứng theo id đơn
Future<void> moChatCuaDon(
  BuildContext context,
  String bookingId, {
  required bool laChuNuoi,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final hoiThoai = await MessagingApiService().theoDon(
      bookingId,
      laChuNuoi: laChuNuoi,
    );
    if (!context.mounted) return;
    if (hoiThoai == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.khongTaiDuocDuLieu)));
      return;
    }
    context.push(
      AppRoutes.chatThread,
      extra: ChatArgs(conversation: hoiThoai, isOwner: laChuNuoi),
    );
  } catch (_) {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.khongTaiDuocDuLieu)));
  }
}
