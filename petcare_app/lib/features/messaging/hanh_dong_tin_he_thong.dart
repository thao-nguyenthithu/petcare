import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/messaging/data/chat_message.dart';

// Nút trong tin hệ thống: mở đúng màn theo mã máy chủ gửi kèm
void chayHanhDongTin(
  BuildContext context,
  MaHanhDongTin? ma,
  String? bookingId, {
  required bool laChuNuoi,
}) {
  // Ví là màn duy nhất không cần dữ liệu đơn; còn lại màn đích đều đòi bản chi
  // tiết đơn nên đi qua màn đơn, ở đó có sẵn mọi lối bấm tiếp
  if (ma == MaHanhDongTin.vi && !laChuNuoi) {
    context.push(AppRoutes.sitterWallet);
    return;
  }
  _moDon(context, bookingId, laChuNuoi);
}

void _moDon(BuildContext context, String? bookingId, bool laChuNuoi) {
  if (bookingId == null) return;
  if (laChuNuoi) {
    context.push(AppRoutes.bookingDetail, extra: bookingId);
  } else {
    context.push(AppRoutes.sitterOrderDetailPath(bookingId));
  }
}
