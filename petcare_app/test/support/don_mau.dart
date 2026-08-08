import 'package:latlong2/latlong.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

const beMau = Pet(
  id: 'p-1',
  name: 'Mun',
  species: PetSpecies.dog,
  breed: 'Corgi',
  weightKg: 9.5,
  gender: PetGender.male,
);

SitterOrderDetail donMau({
  LatLng? viTri = const LatLng(21.0187, 105.8130),
  String? gioMoKetThuc,
}) {
  return SitterOrderDetail(
    bookingId: 'b-1',
    maDon: 'PC-0001',
    tinhTrang: TinhTrangDonNcc.dangDat,
    loai: ServiceType.walking,
    tenDichVu: 'Dắt chó · 30 phút',
    pets: const [beMau],
    tenChuNuoi: 'Trần Thị Hoa',
    soDonDaDat: 3,
    gioHen: '08:00',
    ngayNganHen: '07/08',
    moTaThoiGian: '30 phút',
    kmToiDiemDon: 1.2,
    khuVucDiemDon: 'Cầu Giấy',
    ghiChu: '',
    dongTien: const [],
    tongTien: 120000,
    viTri: viTri,
    gioMoKetThuc: gioMoKetThuc,
  );
}

WalkingSession phienMau({
  LatLng? viTri = const LatLng(21.0187, 105.8130),
  String? gioMoKetThuc,
  int? metConToiDiemTra,
}) {
  return WalkingSession(
    don: donMau(viTri: viTri, gioMoKetThuc: gioMoKetThuc),
    giaiDoan: GiaiDoanPhien.dangDat,
    kmDaDi: 0.8,
    kmLoTrinh: 1.5,
    conLai: '12:30',
    phutDaDat: 18,
    soAnhDaGui: 2,
    bookingId: 'b-1',
    metConToiDiemTra: metConToiDiemTra,
  );
}
