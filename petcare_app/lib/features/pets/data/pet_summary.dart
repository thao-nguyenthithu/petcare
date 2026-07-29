import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/data/pet_breeds.dart';

// Dòng mô tả dưới tên bé
String petSummary(BuildContext context, Pet pet) {
  final l10n = context.l10n;
  final loai = pet.species == PetSpecies.dog ? l10n.cho : l10n.meo;
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

// Tuổi đứng riêng cho bảng thông tin ở màn hồ sơ
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
  // Chưa tới ngày sinh trong tháng thì chưa tính đủ tháng đó
  return (homNay.day < ngaySinh.day ? soThang - 1 : soThang).clamp(0, 1200);
}

// Bỏ phần thập phân thừa
String canNangGon(double so) =>
    so == so.roundToDouble() ? '${so.round()}' : '$so';
