import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/sitter_order/providers/sitter_orders_provider.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_error_mapper.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_orders_api_service.dart';
export 'package:petcare_app/shared/utils/anh_multipart.dart';

Future<T?> chayHanhDongLayKetQua<T>(
  BuildContext context,
  WidgetRef ref,
  String bookingId,
  Future<T> Function(SitterOrdersApiService s) viec,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final ketQua = await ref
        .read(chiTietDonNccProvider(bookingId).notifier)
        .chayLay(viec);
    ref.refreshBookingData(boQua: [chiTietDonNccProvider]);
    return ketQua;
  } catch (loi) {
    if (!context.mounted) return null;
    messenger.showSnackBar(
      SnackBar(content: Text(moTaLoiDonNcc(context, loi))),
    );
    return null;
  }
}

// Màn kế tiếp do trạng thái server trả quyết, client không đoán
void dieuHuongSauKetThuc(
  BuildContext context,
  String bookingId,
  String trangThai,
) {
  context.pushReplacement(
    trangThai == 'awaitingOwnerConfirm'
        ? AppRoutes.sitterWaitConfirmPath(bookingId)
        : AppRoutes.sitterOrderDetailPath(bookingId),
  );
}

Future<bool> chayHanhDongDon(
  BuildContext context,
  WidgetRef ref,
  String bookingId,
  Future<void> Function(SitterOrdersApiService s) viec, {
  String? nhanBaoXong,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(chiTietDonNccProvider(bookingId).notifier).chay(viec);
    ref.refreshBookingData(boQua: [chiTietDonNccProvider]);
    if (nhanBaoXong != null) {
      messenger.showSnackBar(SnackBar(content: Text(nhanBaoXong)));
    }
    return true;
  } catch (loi) {
    if (!context.mounted) return false;
    messenger.showSnackBar(
      SnackBar(content: Text(moTaLoiDonNcc(context, loi))),
    );
    return false;
  }
}
