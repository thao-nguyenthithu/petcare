import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

// Nhãn loài nhận
String petKindLabel(BuildContext context, PetKind kind) => switch (kind) {
  PetKind.dog => context.l10n.cho,
  PetKind.cat => context.l10n.meo,
  PetKind.both => context.l10n.caHai,
};

// Tên loại dịch vụ
String serviceTypeName(BuildContext context, ServiceType type) =>
    switch (type) {
      ServiceType.walking => context.l10n.datThuCung,
      ServiceType.boarding => context.l10n.trongGiu,
      ServiceType.grooming => context.l10n.tamVaTia,
    };

String serviceTypeNameDai(BuildContext context, ServiceType type) =>
    switch (type) {
      ServiceType.walking => context.l10n.datDiDao,
      ServiceType.boarding => context.l10n.trongGiuTaiNha,
      ServiceType.grooming => context.l10n.tamVaCatTia,
    };

// Tên gói grooming
String groomingPackageName(BuildContext context, GroomingPackage goi) =>
    goi == GroomingPackage.bath
    ? context.l10n.chiTam
    : context.l10n.tamVaCatTia;

// Nhãn mức cân nặng
String weightTierLabel(BuildContext context, WeightTier muc) => switch (muc) {
  WeightTier.duoi5 => context.l10n.duoi5kg,
  WeightTier.tu5den10 => context.l10n.tu5den10kg,
  WeightTier.tu10den20 => context.l10n.tu10den20kg,
  WeightTier.tren20 => context.l10n.tren20kg,
};

// Tóm tắt dịch vụ
String? serviceTypeSummary(
  BuildContext context,
  SitterServices s,
  ServiceType type,
) {
  final l10n = context.l10n;
  switch (type) {
    case ServiceType.walking:
      if (!s.walking.configured) return null;
      final loai = petKindLabel(context, s.walking.petKind);
      return l10n.tomTatDatDv(
        loai,
        walkingDurations.join('/'),
        dinhDangTien(s.walking.lowestPrice ?? 0),
      );
    case ServiceType.boarding:
      if (!s.boarding.configured) return null;
      final loai = petKindLabel(context, s.boarding.petKind);
      return '$loai · ${l10n.giaNgayToiDa(dinhDangTien(s.boarding.pricePerDay ?? 0), '${s.boarding.capacity ?? 0}')}';
    case ServiceType.grooming:
      if (!s.grooming.configured) return null;
      final loai = petKindLabel(context, s.grooming.petKind);
      return '$loai · ${l10n.tuGiaBe(dinhDangTien(s.grooming.lowestPrice ?? 0))}';
  }
}
