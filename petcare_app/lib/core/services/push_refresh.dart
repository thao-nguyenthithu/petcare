import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/services/local_notif_service.dart';
import 'package:petcare_app/core/services/notify_socket_service.dart';
import 'package:petcare_app/core/services/push_service.dart';
import 'package:petcare_app/core/services/tin_realtime.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/dksitter/providers/dksitter_provider.dart';
import 'package:petcare_app/features/messaging/providers/conversations_provider.dart';
import 'package:petcare_app/features/notification/providers/notifications_provider.dart';
import 'package:petcare_app/features/wallet/providers/wallet_refresh.dart';
import 'package:petcare_app/features/owner_wallet/providers/owner_payments_provider.dart';

// Việc người khác làm chỉ về tới máy này qua kênh tin hoặc push
const _tinVeDon = {'DON_MOI', 'DON_HANG', 'DON_HUY', 'BANG_CHUNG', 'NHAC_LICH'};

void _lamMoiTheoLoai(ProviderContainer kho, String? loai) {
  // Tin nào cũng vào hộp thông báo
  kho.invalidate(thongBaoCuaToiProvider);
  if (loai == null || _tinVeDon.contains(loai)) {
    kho.refreshBookingData();
  }
  if (loai == null || loai == 'TIN_NHAN') {
    kho.invalidate(hoiThoaiChuNuoiProvider);
    kho.invalidate(hoiThoaiNguoiChamProvider);
  }
  // Duyệt hồ sơ đổi luôn vai người dùng, không nạp lại thì app còn ở vai cũ
  if (loai == null || loai == 'HO_SO') {
    kho.invalidate(currentUserProvider);
    kho.invalidate(sitterStatusProvider);
  }
  if (loai == null || loai == 'TIEN_VI') {
    kho.refreshWalletData();
    kho.invalidate(tienDangTamGiuProvider);
  }
}

void _nhanTin(ProviderContainer kho, TinRealtime tin) {
  _lamMoiTheoLoai(kho, tin.loai);
  final tieuDe = tin.tieuDe;
  if (tieuDe == null || tieuDe.isEmpty) return;
  unawaited(
    LocalNotifService.instance.hien(
      khoa: tin.id,
      tieuDe: tieuDe,
      noiDung: tin.noiDung,
    ),
  );
}

// Kênh tin đứt khi máy ngủ, quay lại phải nối lại rồi kéo hết dữ liệu mới
void lamMoiKhiQuayLai(ProviderContainer kho) {
  unawaited(NotifySocketService.instance.ketNoi());
  _lamMoiTheoLoai(kho, null);
}

void noiPushVaoLamMoi(ProviderContainer kho) {
  NotifySocketService.instance.ngheTin((tin) => _nhanTin(kho, tin));
  try {
    PushService.instance.ngheTinKhiDangMo((tin) => _nhanTin(kho, tin));
  } catch (e) {
    debugPrint('Không nghe được push để làm mới dữ liệu: $e');
  }
}
