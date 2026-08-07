import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Các provider phải tải lại sau mỗi thay đổi ví
final _providerVi = <ProviderOrFamily>[
  // Ví mang số lượt rút còn lại, rút xong là số cũ
  viCuaToiProvider,
  taiKhoanNhanTienProvider,
  lichSuViProvider,
];

Iterable<ProviderOrFamily> _canLamMoi(Iterable<ProviderOrFamily> boQua) =>
    boQua.isEmpty ? _providerVi : _providerVi.where((p) => !boQua.contains(p));

extension WalletRefreshRef on Ref {
  void refreshWalletData({Iterable<ProviderOrFamily> boQua = const []}) =>
      _canLamMoi(boQua).forEach(invalidate);
}

extension WalletRefreshWidgetRef on WidgetRef {
  void refreshWalletData({Iterable<ProviderOrFamily> boQua = const []}) =>
      _canLamMoi(boQua).forEach(invalidate);
}
