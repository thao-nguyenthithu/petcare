import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/shared/data/pet.dart';

// Thú cưng trong đơn, dùng chung cho lịch làm việc NCC và tin nhắn
class PetBrief {
  const PetBrief({
    required this.name,
    required this.species,
    this.avatar,
    this.detail = '',
  });

  final String name;
  final String species;
  final String? avatar;

  final String detail;

  String get nhan => '$name ($species)';

  static String moTa(List<PetBrief> pets) =>
      pets.length == 1 ? pets.first.nhan : pets.map((p) => p.name).join(', ');
}

// Nhãn loài từ mã backend trả
String tenLoaiBe(AppLocalizations l10n, String ma) => switch (ma) {
  'dog' => l10n.cho,
  'cat' => l10n.meo,
  _ => ma,
};

String tenLoai(AppLocalizations l10n, PetSpecies loai) =>
    loai == PetSpecies.dog ? l10n.cho : l10n.meo;

List<PetBrief> tomTatCacBe(AppLocalizations l10n, List<Pet> pets) => [
  for (final be in pets)
    PetBrief(
      name: be.name,
      species: tenLoai(l10n, be.species),
      avatar: be.avatar,
    ),
];

String moTaCacBe(AppLocalizations l10n, List<PetBrief> pets) {
  if (pets.isEmpty) return '';
  if (pets.length == 1) {
    final be = pets.first;
    final loai = tenLoaiBe(l10n, be.species);
    return loai.isEmpty ? be.name : '${be.name} ($loai)';
  }
  return pets.map((p) => p.name).join(', ');
}
