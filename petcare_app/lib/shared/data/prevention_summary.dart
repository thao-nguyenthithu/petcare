import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/prevention_items.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';

const int _nguongDoiSangThang = 30;

// Icon đầu thẻ nói về trạng thái hạng mục
({IconData icon, Color mau}) preventionCardStyle(PreventionStatus trangThai) =>
    switch (trangThai) {
      PreventionStatus.conHan || PreventionStatus.khongNhac => (
        icon: Icons.check,
        mau: AppColors.primaryColor,
      ),
      PreventionStatus.sapToiHan => (
        icon: Icons.schedule,
        mau: AppColors.honey,
      ),
      PreventionStatus.quaHan => (
        icon: Icons.warning_amber_rounded,
        mau: AppColors.accent,
      ),
      PreventionStatus.chuaGhi => (
        icon: Icons.edit_note,
        mau: AppColors.textSecondary,
      ),
    };

// Icon trong chú thích
({IconData icon, Color mau}) preventionLegendStyle(
  PreventionStatus trangThai,
) => switch (trangThai) {
  PreventionStatus.khongNhac => (
    icon: Icons.notifications_off_outlined,
    mau: AppColors.textSecondary,
  ),
  _ => preventionCardStyle(trangThai),
};

String preventionStatusLabel(
  BuildContext context,
  PreventionStatus trangThai,
) => switch (trangThai) {
  PreventionStatus.conHan => context.l10n.conHan,
  PreventionStatus.sapToiHan => context.l10n.sapToiHan,
  PreventionStatus.quaHan => context.l10n.quaHan,
  PreventionStatus.khongNhac => context.l10n.khongNhac,
  PreventionStatus.chuaGhi => context.l10n.chuaGhiLan,
};

// Nhãn một mức nhắc
String preventionCycleLabel(BuildContext context, PreventionCycle chuKy) =>
    switch (chuKy.donVi) {
      CycleUnit.ngay => context.l10n.soNgayNhac('${chuKy.so}'),
      CycleUnit.tuan => context.l10n.soTuanNhac('${chuKy.so}'),
      CycleUnit.thang => context.l10n.soThangNhac('${chuKy.so}'),
    };

// Nhãn đơn vị ở ô nhập chu kỳ
String cycleUnitLabel(BuildContext context, CycleUnit donVi) => switch (donVi) {
  CycleUnit.ngay => context.l10n.donViNgay,
  CycleUnit.tuan => context.l10n.donViTuan,
  CycleUnit.thang => context.l10n.donViThang,
};

// Cách thực hiện hạng mục
String preventionFormLabel(BuildContext context, PreventionForm hinhThuc) =>
    switch (hinhThuc) {
      PreventionForm.vacXin => context.l10n.hinhThucVacXin,
      PreventionForm.uong => context.l10n.hinhThucUong,
      PreventionForm.nhoGay => context.l10n.hinhThucNhoGay,
      PreventionForm.khac => '',
    };

// Tên hạng mục để hiện lên màn
String tenCuaHangMuc(BuildContext context, PreventionRecord muc) =>
    muc.tenTuNhap ?? tenHangMuc(context, muc.ma);

// Nhãn ảnh ở mục giấy tờ
String preventionPhotoLabel(BuildContext context, PreventionRecord muc) =>
    muc.hinhThuc == PreventionForm.khac
    ? tenCuaHangMuc(context, muc)
    : context.l10n.hinhThucVaTen(
        preventionFormLabel(context, muc.hinhThuc),
        tenCuaHangMuc(context, muc),
      );

// Tên hạng mục dùng làm tiêu đề màn hình
String preventionTitle(BuildContext context, PreventionRecord muc) =>
    muc.hinhThuc == PreventionForm.vacXin
    ? context.l10n.hinhThucVaTen(
        preventionFormLabel(context, muc.hinhThuc),
        tenCuaHangMuc(context, muc),
      )
    : tenCuaHangMuc(context, muc);

String preventionCountLabel(BuildContext context, PreventionRecord muc) =>
    context.l10n.soLanDaLam('${muc.soLan}');

String preventionDueLabel(BuildContext context, PreventionRecord muc) {
  final l10n = context.l10n;
  final lanGanNhat = muc.lanGanNhat;
  if (lanGanNhat == null) return l10n.chuaCoLanGhiNao;
  final ganNhat = l10n.ganNhatNgay(ngayThangNam(lanGanNhat.ngay));
  final han = muc.ngayNhacLai;
  if (han == null) return '$ganNhat · ${l10n.khongDatNhacLai}';
  final ngay = ngayThangNam(han);
  final soNgay = muc.soNgayConLai!;
  if (soNgay < 0) {
    return '$ganNhat · ${l10n.daQuaHanNgay(ngay)}, '
        '${l10n.treSoNgay('${-soNgay}')}';
  }
  final conLai = soNgay > _nguongDoiSangThang
      ? l10n.conSoThang('${soNgay ~/ 30}')
      : l10n.conSoNgay('$soNgay');
  final moc = muc.dinhKy ? l10n.toiHanNgay(ngay) : l10n.lanKeTiepNgay(ngay);
  return '$ganNhat · $moc, $conLai';
}

// Dòng phụ ở màn hồ sơ bé
String preventionCountAndLastLabel(BuildContext context, PreventionRecord muc) {
  final lan = muc.lanGanNhat;
  if (lan == null) return context.l10n.chuaCoLanGhiNao;
  return context.l10n.soLanVaGanNhat('${muc.soLan}', ngayThangNam(lan.ngay));
}

// Nhãn ngắn bên phải mỗi dòng ở màn hồ sơ bé
String preventionRemainLabel(BuildContext context, PreventionRecord muc) {
  final l10n = context.l10n;
  if (muc.chuaCoLan) return l10n.chuaGhiLan;
  final soNgay = muc.soNgayConLai;
  if (soNgay == null) return l10n.khongNhac;
  if (soNgay < 0) return l10n.treSoNgayNhan('${-soNgay}');
  return soNgay > _nguongDoiSangThang
      ? l10n.conSoThang('${soNgay ~/ 30}')
      : l10n.conSoNgay('$soNgay');
}

// Màu của nhãn ngắn đó
Color preventionRemainColor(PreventionStatus trangThai) => switch (trangThai) {
  PreventionStatus.conHan => AppColors.primaryColor,
  PreventionStatus.sapToiHan => AppColors.honey,
  PreventionStatus.quaHan => AppColors.accent,
  PreventionStatus.khongNhac ||
  PreventionStatus.chuaGhi => AppColors.textSecondary,
};

// Tình trạng nhãn trên thẻ ở danh sách
enum PetPreventionStatus { chuaCoSo, quaHan, sapToiHan, dayDu }

// Ưu tiên nhắc việc gấp trước
PetPreventionStatus petPreventionStatus(Pet pet) {
  if (pet.phongBenh.isEmpty) {
    return PetPreventionStatus.chuaCoSo;
  }
  final trangThai = pet.phongBenh.map((muc) => muc.trangThai).toSet();
  if (trangThai.contains(PreventionStatus.quaHan)) {
    return PetPreventionStatus.quaHan;
  }
  if (trangThai.contains(PreventionStatus.sapToiHan)) {
    return PetPreventionStatus.sapToiHan;
  }
  return PetPreventionStatus.dayDu;
}

// Số hạng mục đang ở trạng thái cần nhắc
int _soMuc(Pet pet, PreventionStatus trangThai) =>
    pet.phongBenh.where((muc) => muc.trangThai == trangThai).length;

String petPreventionLabel(BuildContext context, Pet pet) {
  final l10n = context.l10n;
  return switch (petPreventionStatus(pet)) {
    PetPreventionStatus.chuaCoSo => l10n.chuaCoSoPhongBenh,
    PetPreventionStatus.quaHan => l10n.quaHanSoMuc(
      '${_soMuc(pet, PreventionStatus.quaHan)}',
    ),
    PetPreventionStatus.sapToiHan => l10n.sapToiHanSoMuc(
      '${_soMuc(pet, PreventionStatus.sapToiHan)}',
    ),
    PetPreventionStatus.dayDu => l10n.phongBenhDayDu,
  };
}

PreventionRecord? mucCanNhacGapNhat(Pet pet, PreventionStatus trangThai) {
  final ds = pet.phongBenh.where((m) => m.trangThai == trangThai).toList();
  if (ds.isEmpty) return null;
  ds.sort((a, b) => (a.soNgayConLai ?? 0).compareTo(b.soNgayConLai ?? 0));
  return ds.first;
}

String petPreventionLabelChiTiet(BuildContext context, Pet pet) {
  final l10n = context.l10n;
  final trangThai = petPreventionStatus(pet);
  final canNhac = switch (trangThai) {
    PetPreventionStatus.quaHan => PreventionStatus.quaHan,
    PetPreventionStatus.sapToiHan => PreventionStatus.sapToiHan,
    _ => null,
  };
  if (canNhac == null) return petPreventionLabel(context, pet);
  final muc = mucCanNhacGapNhat(pet, canNhac);
  if (muc == null) return petPreventionLabel(context, pet);
  final ten = tenCuaHangMuc(context, muc);
  final nhan = canNhac == PreventionStatus.quaHan
      ? l10n.quaHanMuc(ten)
      : l10n.sapToiHanMuc(ten);
  final conLai = _soMuc(pet, canNhac) - 1;
  return conLai > 0 ? '$nhan ${l10n.themSoMuc('$conLai')}' : nhan;
}

// Icon và màu của nhãn
({IconData? icon, Color mau}) petPreventionStyle(
  PetPreventionStatus trangThai,
) => switch (trangThai) {
  PetPreventionStatus.chuaCoSo => (icon: null, mau: AppColors.textSecondary),
  PetPreventionStatus.quaHan => (
    icon: Icons.warning_amber_rounded,
    mau: AppColors.accent,
  ),
  PetPreventionStatus.sapToiHan => (icon: Icons.schedule, mau: AppColors.honey),
  PetPreventionStatus.dayDu => (icon: Icons.check, mau: AppColors.primaryColor),
};
