import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/services/push_service.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/messaging/providers/conversations_provider.dart';
import 'package:petcare_app/features/notification/providers/notifications_provider.dart';

// Tin của người khác chỉ tới qua push
const _tinVeDon = {'DON_MOI', 'DON_HANG', 'DON_HUY', 'BANG_CHUNG', 'NHAC_LICH'};

void noiPushVaoLamMoi(ProviderContainer kho) {
  try {
    PushService.instance.ngheTinKhiDangMo((loai) {
      // Tin nào cũng vào hộp thông báo
      kho.invalidate(thongBaoCuaToiProvider);
      if (loai == null || _tinVeDon.contains(loai)) {
        kho.refreshBookingData();
      }
      if (loai == 'TIN_NHAN') {
        kho.invalidate(hoiThoaiChuNuoiProvider);
        kho.invalidate(hoiThoaiNguoiChamProvider);
      }
    });
  } catch (e) {
    debugPrint('Không nghe được push để làm mới dữ liệu: $e');
  }
}
