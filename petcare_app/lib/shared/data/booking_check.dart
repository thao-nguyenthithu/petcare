import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Kiểm tra dữ liệu trước và trong trang đặt lịch.

PetKind loaiNhanCua(SitterServices s, ServiceType t) => switch (t) {
  ServiceType.walking => PetKind.dog,
  ServiceType.boarding => s.boarding.petKind,
  ServiceType.grooming => s.grooming.petKind,
};

const int soBeToiDaDonDat = 5;
const int phutToiDaDonGrooming = 480;

int? soBeToiDaCua(SitterServices s, ServiceType t) => switch (t) {
  ServiceType.walking => _chatHon(s.walking.maxPets, soBeToiDaDonDat),
  ServiceType.boarding => s.boarding.maxPets,
  ServiceType.grooming => s.grooming.maxPets,
};

int _chatHon(int? khai, int tran) =>
    (khai == null || khai > tran) ? tran : khai;

bool kindNhanLoai(PetKind kind, PetSpecies loai) => switch (kind) {
  PetKind.both => true,
  PetKind.dog => loai == PetSpecies.dog,
  PetKind.cat => loai == PetSpecies.cat,
};

// Các bé hợp loài với một loại dịch vụ
List<Pet> beHopLoai(List<Pet> pets, SitterServices s, ServiceType t) {
  final kind = loaiNhanCua(s, t);
  return pets.where((p) => kindNhanLoai(kind, p.species)).toList();
}

// Các bé đặt được dịch vụ này
List<Pet> beDatDuoc(List<Pet> pets, SitterServices s, ServiceType t) =>
    pets.where((p) => lyDoBeKhongChon(p, s, t) == null).toList();

// Các loại đang bật nhận đơn và đã có bảng giá
List<ServiceType> loaiDangNhan(SitterServices? s) =>
    s == null ? const [] : s.configuredTypes.where(s.isEnabled).toList();

bool khongDichVuNaoHop(List<Pet> pets, SitterServices? s) {
  if (pets.isEmpty) return false;
  final loai = loaiDangNhan(s);
  if (loai.isEmpty) return false;
  return loai.every((t) => beDatDuoc(pets, s!, t).isEmpty);
}

enum LyDoBeKhongChon { khongHopLoai, vuotCan }

// Bé không hợp thì trả lý do
LyDoBeKhongChon? lyDoBeKhongChon(Pet be, SitterServices s, ServiceType t) {
  if (!kindNhanLoai(loaiNhanCua(s, t), be.species)) {
    return LyDoBeKhongChon.khongHopLoai;
  }
  if (t == ServiceType.grooming) {
    final muc = mucCanCua(be.weightKg);
    if (muc == null || !s.grooming.coGiaChoMucCan(muc)) {
      return LyDoBeKhongChon.vuotCan;
    }
  }
  return null;
}

// Mức cân của một bé theo cân nặng
WeightTier? mucCanCua(double kg) {
  if (kg < 5) return WeightTier.duoi5;
  if (kg <= 10) return WeightTier.tu5den10;
  if (kg <= 20) return WeightTier.tu10den20;
  return WeightTier.tren20;
}
