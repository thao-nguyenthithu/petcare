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
