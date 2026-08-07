import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/booking/providers/owner_booking_detail_provider.dart';
import 'package:petcare_app/features/booking/providers/owner_bookings_provider.dart';
import 'package:petcare_app/features/home/providers/owner_home_provider.dart';
import 'package:petcare_app/features/messaging/providers/conversations_provider.dart';
import 'package:petcare_app/features/owner_wallet/providers/owner_payments_provider.dart';
import 'package:petcare_app/features/reviews/providers/reviews_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_home_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_schedule_provider.dart';
import 'package:petcare_app/features/sitter_order/providers/sitter_orders_provider.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final _providerDon = <ProviderOrFamily>[
  ownerBookingsProvider,
  bookingDetailProvider,
  chiTietDonNccProvider,
  trangChuCuaToiProvider,
  sitterBookingsProvider,
  tomTatDonNccProvider,
  trangChuNguoiChamProvider,
  sitterScheduleProvider,
  donChoDanhGiaCuaToiProvider,
  hoiThoaiChuNuoiProvider,
  hoiThoaiNguoiChamProvider,
  tienDangTamGiuProvider,
  viCuaToiProvider,
];

Iterable<ProviderOrFamily> _canLamMoi(Iterable<ProviderOrFamily> boQua) =>
    boQua.isEmpty
    ? _providerDon
    : _providerDon.where((p) => !boQua.contains(p));

extension BookingRefreshRef on Ref {
  void refreshBookingData({Iterable<ProviderOrFamily> boQua = const []}) =>
      _canLamMoi(boQua).forEach(invalidate);
}

extension BookingRefreshWidgetRef on WidgetRef {
  void refreshBookingData({Iterable<ProviderOrFamily> boQua = const []}) =>
      _canLamMoi(boQua).forEach(invalidate);
}

extension BookingRefreshContainer on ProviderContainer {
  void refreshBookingData() => _providerDon.forEach(invalidate);
}
