import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/provider_profile/data/service_draft.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

String serviceSummary(BuildContext context, ServiceDraft service) {
  final l10n = context.l10n;
  final loai = switch (service.petKind) {
    PetKind.dog => l10n.cho,
    PetKind.cat => l10n.meo,
    PetKind.both => l10n.caHai,
  };
  return switch (service.type) {
    ServiceType.walking => l10n.tomTatDatDv(
      loai,
      '${service.durationMinutes}',
      dinhDangTien(service.price ?? 0),
    ),
    ServiceType.boarding => l10n.tomTatTrongGiu(
      loai,
      dinhDangTien(service.price ?? 0),
      '${service.capacity}',
    ),
    ServiceType.grooming => l10n.tomTatCatTia(
      loai,
      _tenGoiGrooming(l10n, service),
      dinhDangTien(service.lowestWeightPrice ?? 0),
    ),
  };
}

String _tenGoiGrooming(AppLocalizations l10n, ServiceDraft service) =>
    switch (service.package) {
      GroomingPackage.bath => l10n.chiTam,
      _ => l10n.tamVaCatTia,
    };
