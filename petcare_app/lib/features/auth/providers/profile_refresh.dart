import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_profile_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final _providerHoSo = <ProviderOrFamily>[
  currentUserProvider,
  sitterMeProvider,
  sitterPublicProvider,
];

Iterable<ProviderOrFamily> _canLamMoi(Iterable<ProviderOrFamily> boQua) =>
    boQua.isEmpty
    ? _providerHoSo
    : _providerHoSo.where((p) => !boQua.contains(p));

extension ProfileRefreshRef on Ref {
  void refreshProfileData({Iterable<ProviderOrFamily> boQua = const []}) =>
      _canLamMoi(boQua).forEach(invalidate);
}

extension ProfileRefreshWidgetRef on WidgetRef {
  void refreshProfileData({Iterable<ProviderOrFamily> boQua = const []}) =>
      _canLamMoi(boQua).forEach(invalidate);
}
