import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Loại dịch vụ của nền tảng
enum LoaiDichVu { datDiDao, trongGiu, catTia }

extension LoaiDichVuHienThi on LoaiDichVu {
  String ten(AppLocalizations l10n) => switch (this) {
    LoaiDichVu.datDiDao => l10n.datDiDao,
    LoaiDichVu.trongGiu => l10n.trongGiu,
    LoaiDichVu.catTia => l10n.tamVaTia,
  };

  // Đơn vị tính giá theo loại dịch vụ
  String donVi(AppLocalizations l10n) => switch (this) {
    LoaiDichVu.datDiDao => l10n.moiLuot,
    LoaiDichVu.trongGiu => l10n.moiNgay,
    LoaiDichVu.catTia => l10n.moiBe,
  };

  String get maApi => switch (this) {
    LoaiDichVu.datDiDao => 'walking',
    LoaiDichVu.trongGiu => 'boarding',
    LoaiDichVu.catTia => 'grooming',
  };

  Color get mauCham => switch (this) {
    LoaiDichVu.datDiDao => AppColors.primaryColor,
    LoaiDichVu.trongGiu => AppColors.honey,
    LoaiDichVu.catTia => AppColors.accent,
  };

  String get anhMinhHoa => switch (this) {
    LoaiDichVu.datDiDao => 'assets/illustrations/service_walking.png',
    LoaiDichVu.trongGiu => 'assets/illustrations/service_boadring.png',
    LoaiDichVu.catTia => 'assets/illustrations/service_grooming.png',
  };
}
