import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_breeds.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';

// Dòng mô tả dưới tên bé
String petSummary(BuildContext context, Pet pet) {
  final l10n = context.l10n;
  final loai = tenLoai(l10n, pet.species);
  final gioiTinh = pet.gender == PetGender.male ? l10n.duc : l10n.cai;
  return [
    '$loai ${tenGiong(context, pet.breed)}',
    l10n.soKgCanNang(canNangGon(pet.weightKg)),
    _gioiTinhVaTuoi(context, gioiTinh, pet.birthDate),
  ].join(' · ');
}

String _gioiTinhVaTuoi(
  BuildContext context,
  String gioiTinh,
  DateTime? ngaySinh,
) {
  final l10n = context.l10n;
  if (ngaySinh == null) return gioiTinh;
  final soThang = _soThangTuoi(ngaySinh);
  return soThang < 12
      ? l10n.gioiTinhVaThangTuoi(gioiTinh, '$soThang')
      : l10n.gioiTinhVaTuoi(gioiTinh, '${soThang ~/ 12}');
}

// Giống và cân nặng
String petGiongCan(BuildContext context, Pet pet) {
  final l10n = context.l10n;
  final loai = tenLoai(l10n, pet.species);
  return '$loai ${tenGiong(context, pet.breed)} · '
      '${l10n.soKgCanNang(canNangGon(pet.weightKg))}';
}

// Loài kèm giống
String petLoaiGiong(BuildContext context, Pet pet) {
  final l10n = context.l10n;
  final loai = tenLoai(l10n, pet.species);
  return '$loai ${tenGiong(context, pet.breed)}';
}

String petTenGiongCan(BuildContext context, Pet pet) {
  final l10n = context.l10n;
  final loai = tenLoai(l10n, pet.species);
  return l10n.beGiongCan(
    pet.name,
    '$loai ${tenGiong(context, pet.breed)}',
    l10n.soKgCanNang(canNangGon(pet.weightKg)),
  );
}

String tuoiBe(BuildContext context, Pet pet) {
  final ngaySinh = pet.birthDate;
  if (ngaySinh == null) return context.l10n.chuaCapNhat;
  final soThang = _soThangTuoi(ngaySinh);
  return soThang < 12
      ? context.l10n.soThangTuoiNhan('$soThang')
      : context.l10n.soTuoiNhan('${soThang ~/ 12}');
}

int _soThangTuoi(DateTime ngaySinh) {
  final homNay = homNayVn();
  final soThang =
      (homNay.year - ngaySinh.year) * 12 + homNay.month - ngaySinh.month;
  return (homNay.day < ngaySinh.day ? soThang - 1 : soThang).clamp(0, 1200);
}

String canNangGon(double so) =>
    so == so.roundToDouble() ? '${so.round()}' : '$so';
