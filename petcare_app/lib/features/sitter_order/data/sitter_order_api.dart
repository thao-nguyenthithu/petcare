import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

enum TrangThaiDonApi {
  choNhan,
  daNhan,
  dangChay,
  choChuNuoiChot,
  hoanThanh,
  huyBoiChuNuoi,
  huyBoiNguoiCham,
  huyHetHan,
  huyVangMat,
  khieuNai,
  daXuLy,
  huyBoiQuanTri,
  khongRo,
}

TrangThaiDonApi trangThaiDonTuMa(String? ma) => switch (ma) {
  'pending' => TrangThaiDonApi.choNhan,
  'confirmed' => TrangThaiDonApi.daNhan,
  'inProgress' => TrangThaiDonApi.dangChay,
  'awaitingOwnerConfirm' => TrangThaiDonApi.choChuNuoiChot,
  'completed' => TrangThaiDonApi.hoanThanh,
  'cancelledByOwner' => TrangThaiDonApi.huyBoiChuNuoi,
  'cancelledBySitter' => TrangThaiDonApi.huyBoiNguoiCham,
  'cancelledExpired' => TrangThaiDonApi.huyHetHan,
  'cancelledNoShow' => TrangThaiDonApi.huyVangMat,
  'cancelledByAdmin' => TrangThaiDonApi.huyBoiQuanTri,
  'disputed' => TrangThaiDonApi.khieuNai,
  'resolved' => TrangThaiDonApi.daXuLy,
  _ => TrangThaiDonApi.khongRo,
};

ServiceType _loaiTuMa(String? ma) => switch (ma) {
  'boarding' => ServiceType.boarding,
  'grooming' => ServiceType.grooming,
  _ => ServiceType.walking,
};

Map<String, dynamic> _map(Object? o) =>
    o is Map ? Map<String, dynamic>.from(o) : <String, dynamic>{};

LatLng? _viTri(Object? lat, Object? lng) =>
    lat is num && lng is num ? LatLng(lat.toDouble(), lng.toDouble()) : null;

// Một dòng ở màn Công việc
class DongDonNccApi {
  const DongDonNccApi({
    required this.id,
    required this.code,
    required this.trangThai,
    required this.loai,
    required this.tenDichVu,
    required this.tenChuNuoi,
    required this.pets,
    required this.batDau,
    required this.tongTien,
    required this.thucNhan,
    this.anhChuNuoi,
    this.khuVucChuNuoi,
    this.ketThuc,
    this.thoiLuongPhut,
    this.soDem,
    this.hanTraLoi,
  });

  factory DongDonNccApi.fromJson(Map<String, dynamic> j) => DongDonNccApi(
    id: j['id'] as String,
    code: j['code'] as String? ?? '',
    trangThai: trangThaiDonTuMa(j['status'] as String?),
    loai: _loaiTuMa(j['serviceType'] as String?),
    tenDichVu: j['serviceName'] as String? ?? '',
    tenChuNuoi: j['ownerName'] as String? ?? '',
    anhChuNuoi: j['ownerAvatar'] as String?,
    khuVucChuNuoi: j['ownerArea'] as String?,
    pets: [
      for (final e in (j['pets'] as List? ?? const []))
        PetBrief(
          name: (e as Map)['name'] as String? ?? '',
          species: e['species'] as String? ?? '',
        ),
    ],
    batDau: docMocVn(j['startAt'] as String?) ?? nowVn(),
    ketThuc: docMocVn(j['endAt'] as String?),
    thoiLuongPhut: (j['durationMinutes'] as num?)?.toInt(),
    soDem: (j['nights'] as num?)?.toInt(),
    tongTien: ((j['totalPrice'] as num?) ?? 0).round(),
    thucNhan: ((j['sitterAmount'] as num?) ?? 0).round(),
    hanTraLoi: docMocVn(j['respondDeadline'] as String?),
  );

  final String id;
  final String code;
  final TrangThaiDonApi trangThai;
  final ServiceType loai;
  final String tenDichVu;
  final String tenChuNuoi;
  final String? anhChuNuoi;

  // Card chỉ hiện khu vực, không hiện số nhà chủ nuôi
  final String? khuVucChuNuoi;
  final List<PetBrief> pets;
  final DateTime batDau;
  final DateTime? ketThuc;
  final int? thoiLuongPhut;
  final int? soDem;

  // Giá chủ nuôi trả và khoản thực nhận sau phí nền tảng
  final int tongTien;
  final int thucNhan;

  // Hạn phải trả lời, chỉ đơn còn chờ nhận mới có
  final DateTime? hanTraLoi;

  bool get daHuy =>
      trangThai == TrangThaiDonApi.huyBoiChuNuoi ||
      trangThai == TrangThaiDonApi.huyBoiNguoiCham ||
      trangThai == TrangThaiDonApi.huyHetHan ||
      trangThai == TrangThaiDonApi.huyVangMat ||
      trangThai == TrangThaiDonApi.huyBoiQuanTri;

  // Mọi kết cục huỷ đều mở được màn chi tiết
  bool get coManChiTiet => true;
}

// Khối phiên đang chạy, chỉ có từ lúc bấm bắt đầu
typedef PhienApi = ({
  DateTime? batDauLuc,
  DateTime? xacMinhLuc,
  DateTime? ketThucLuc,
  DateTime? mocDuGio,
  double? km,
  List<String> anh,
  int tongAnh,
  String? ghiChuNcc,
});

typedef GoiBeApi = ({String petId, String? maGoi, int? phut});

typedef GroomingApi = ({
  List<GoiBeApi> goiTungBe,
  DateTime? duKienXongLuc,
  DateTime? batDauLuc,
  DateTime? ketThucLuc,
  List<String> anhTruoc,
  List<String> anhSau,
});

typedef CapNhatNgayApi = ({
  String? loiNhan,
  List<String> nhanTinhTrang,
  List<String> anh,
  DateTime? luc,
});

typedef TrongGiuApi = ({
  int soDem,
  int? demHienTai,
  DateTime? nhanBeLuc,
  DateTime? traBeLuc,
  DateTime? daNhanBeLuc,
  DateTime? chuNuoiToiLuc,
  DateTime? ketThucLuc,
  String? ghiChuNhanBe,
  CapNhatNgayApi? capNhatMoiNhat,
  int soBanCapNhat,
  List<String> anh,
  List<String> anhBeNhan,
  List<String> anhBeTra,
  List<String> anhDoDungNhan,
  List<String> anhDoDungTra,
});

typedef ThongTinHuyNccApi = ({
  String ben,
  DateTime? luc,
  String? lyDo,
  String? moTa,
  int chuNuoiChiu,
  int nccNhan,
});

typedef UyTinNccApi = ({
  double tyLeHuy,
  int soCanhCao30Ngay,
  int soDangChoSoat,
  double nguongTyLeHuy,
});

typedef BaoMuonApi = ({int? phut, DateTime? duKienLuc, DateTime? baoLuc});

class ChiTietDonNccApi {
  const ChiTietDonNccApi({
    required this.dong,
    required this.pets,
    required this.tenChuNuoi,
    required this.soDonChuNuoiDaDat,
    required this.dongGia,
    required this.phanTramPhiNenTang,
    required this.uyTin,
    this.avatarChuNuoi,
    this.ghiChu,
    this.khuVucDiemDon,
    this.kmToiDiemDon,
    this.diaChiDayDu,
    this.viTri,
    this.mocMoChiDuong,
    this.mocMoXuatPhat,
    this.mocMoBatDau,
    this.metGeofence = 200,
    this.nhanDonLuc,
    this.xuatPhatLuc,
    this.toiNoiLuc,
    this.metCachDiemDon,
    this.chuNuoiToiLuc,
    this.camKetDungCuLuc,
    this.baoMuon,
    this.mocBaoVangMat,
    this.hetChoDungCuLuc,
    this.tuChotLuc,
    this.phien,
    this.grooming,
    this.trongGiu,
    this.thongTinHuy,
    this.goiTheoBe = const {},
  });

  factory ChiTietDonNccApi.fromJson(Map<String, dynamic> j) {
    final chuNuoi = _map(j['owner']);
    final muon = _map(j['lateReport']);
    return ChiTietDonNccApi(
      dong: DongDonNccApi.fromJson(j),
      pets: [
        for (final e in (j['pets'] as List? ?? const []))
          Pet.fromJson(Map<String, dynamic>.from(e as Map)),
      ],
      goiTheoBe: {
        for (final e in (j['pets'] as List? ?? const []))
          if ((e as Map)['packageCode'] != null)
            e['id'] as String: (
              maGoi: e['packageCode'] as String,
              gia: ((e['packagePrice'] as num?) ?? 0).round(),
              phut: (e['packageDurationMinutes'] as num?)?.toInt(),
            ),
      },
      tenChuNuoi: chuNuoi['name'] as String? ?? j['ownerName'] as String? ?? '',
      avatarChuNuoi: chuNuoi['avatarUrl'] as String?,
      soDonChuNuoiDaDat: (chuNuoi['totalBookings'] as num?)?.toInt() ?? 0,
      ghiChu: j['note'] as String?,
      dongGia: [
        for (final e in (j['priceLines'] as List? ?? const []))
          _dongGia(Map<String, dynamic>.from(e as Map)),
      ],
      phanTramPhiNenTang: (j['platformFeePercent'] as num?)?.toInt() ?? 15,
      khuVucDiemDon: j['pickupArea'] as String?,
      kmToiDiemDon: (j['pickupDistanceKm'] as num?)?.toDouble(),
      diaChiDayDu: j['pickupAddress'] as String?,
      viTri: _viTri(j['pickupLat'], j['pickupLng']),
      mocMoChiDuong: docMocVn(j['directionsOpenAt'] as String?),
      mocMoXuatPhat: docMocVn(j['departOpenAt'] as String?),
      mocMoBatDau: docMocVn(j['startButtonOpenAt'] as String?),
      metGeofence: (j['geofenceMeters'] as num?)?.toInt() ?? 200,
      nhanDonLuc: docMocVn(j['acceptedAt'] as String?),
      xuatPhatLuc: docMocVn(j['departedAt'] as String?),
      toiNoiLuc: docMocVn(j['arrivedAt'] as String?),
      metCachDiemDon: (j['arriveDistanceMeters'] as num?)?.toInt(),
      chuNuoiToiLuc: docMocVn(j['ownerArrivedAt'] as String?),
      camKetDungCuLuc: docMocVn(j['gearCommittedAt'] as String?),
      baoMuon: muon.isEmpty
          ? null
          : (
              phut: (muon['minutes'] as num?)?.toInt(),
              duKienLuc: docMocVn(muon['etaAt'] as String?),
              baoLuc: docMocVn(muon['reportedAt'] as String?),
            ),
      mocBaoVangMat: docMocVn(j['noShowOpenAt'] as String?),
      hetChoDungCuLuc: docMocVn(j['gearWaitUntil'] as String?),
      tuChotLuc: docMocVn(j['autoConfirmAt'] as String?),
      phien: _phien(j['session']),
      grooming: _grooming(j['grooming']),
      trongGiu: _trongGiu(j['boarding']),
      thongTinHuy: _thongTinHuy(j['cancellation']),
      uyTin: _uyTin(_map(j['reputation'])),
    );
  }

  final DongDonNccApi dong;
  final List<Pet> pets;
  final Map<String, ({String maGoi, int gia, int? phut})> goiTheoBe;
  final String tenChuNuoi;
  final String? avatarChuNuoi;
  final int soDonChuNuoiDaDat;
  final String? ghiChu;
  final List<({String key, int tien, String? petId, Map<String, dynamic> meta})>
  dongGia;
  final int phanTramPhiNenTang;

  // Địa chỉ ba nấc do server ẩn, client chỉ hỏi toạ độ có hay không
  final String? khuVucDiemDon;

  // Đường chim bay tới điểm đón, kỳ trông giữ luôn 0
  final double? kmToiDiemDon;
  final String? diaChiDayDu;
  final LatLng? viTri;

  // Ba mốc mở nút do server tính sẵn
  final DateTime? mocMoChiDuong;
  final DateTime? mocMoXuatPhat;
  final DateTime? mocMoBatDau;
  final int metGeofence;

  final DateTime? nhanDonLuc;
  final DateTime? xuatPhatLuc;
  final DateTime? toiNoiLuc;

  // Server giữ làm bằng chứng cho nhánh báo vắng mặt
  final int? metCachDiemDon;
  final DateTime? chuNuoiToiLuc;
  final DateTime? camKetDungCuLuc;
  final BaoMuonApi? baoMuon;
  final DateTime? mocBaoVangMat;
  final DateTime? hetChoDungCuLuc;
  final DateTime? tuChotLuc;

  final PhienApi? phien;
  final GroomingApi? grooming;
  final TrongGiuApi? trongGiu;
  final ThongTinHuyNccApi? thongTinHuy;
  final UyTinNccApi uyTin;
}

({String key, int tien, String? petId, Map<String, dynamic> meta}) _dongGia(
  Map<String, dynamic> j,
) => (
  key: j['key'] as String? ?? '',
  tien: ((j['amount'] as num?) ?? 0).round(),
  petId: j['petId'] as String?,
  meta: _map(j['meta']),
);

PhienApi? _phien(Object? o) {
  if (o is! Map) return null;
  final m = Map<String, dynamic>.from(o);
  return (
    batDauLuc: docMocVn(m['startedAt'] as String?),
    xacMinhLuc: docMocVn(m['verifiedAt'] as String?),
    ketThucLuc: docMocVn(m['endedAt'] as String?),
    mocDuGio: docMocVn(m['finishOpenAt'] as String?),
    km: (m['distanceKm'] as num?)?.toDouble(),
    anh: [for (final a in (m['photos'] as List? ?? const [])) a as String],
    tongAnh: (m['totalPhotos'] as num?)?.toInt() ?? 0,
    ghiChuNcc: m['sitterNote'] as String?,
  );
}

GroomingApi? _grooming(Object? o) {
  if (o is! Map) return null;
  final m = Map<String, dynamic>.from(o);
  return (
    goiTungBe: [
      for (final e in (m['tasks'] as List? ?? const []))
        (
          petId: (e as Map)['petId'] as String,
          maGoi: e['packageCode'] as String?,
          phut: (e['durationMinutes'] as num?)?.toInt(),
        ),
    ],
    duKienXongLuc: docMocVn(m['estimatedFinishAt'] as String?),
    batDauLuc: docMocVn(m['startedAt'] as String?),
    ketThucLuc: docMocVn(m['finishedAt'] as String?),
    anhTruoc: [
      for (final a in (m['beforePhotos'] as List? ?? const [])) a as String,
    ],
    anhSau: [
      for (final a in (m['afterPhotos'] as List? ?? const [])) a as String,
    ],
  );
}

TrongGiuApi? _trongGiu(Object? o) {
  if (o is! Map) return null;
  final m = Map<String, dynamic>.from(o);
  final capNhat = m['latestUpdate'];
  return (
    soDem: (m['nights'] as num?)?.toInt() ?? 0,
    demHienTai: (m['currentNight'] as num?)?.toInt(),
    nhanBeLuc: docMocVn(m['dropOffAt'] as String?),
    traBeLuc: docMocVn(m['pickUpAt'] as String?),
    daNhanBeLuc: docMocVn(m['receivedAt'] as String?),
    chuNuoiToiLuc: docMocVn(m['ownerArrivedAt'] as String?),
    ketThucLuc: docMocVn(m['finishedAt'] as String?),
    ghiChuNhanBe: m['handoverNote'] as String?,
    capNhatMoiNhat: capNhat is Map
        ? _capNhat(Map<String, dynamic>.from(capNhat))
        : null,
    soBanCapNhat: (m['updateCount'] as num?)?.toInt() ?? 0,
    anh: [for (final a in (m['photos'] as List? ?? const [])) a as String],
    anhBeNhan: _dsAnh(m['petPhotosIn']),
    anhBeTra: _dsAnh(m['petPhotosOut']),
    anhDoDungNhan: _dsAnh(m['itemPhotosIn']),
    anhDoDungTra: _dsAnh(m['itemPhotosOut']),
  );
}

List<String> _dsAnh(Object? o) => [
  if (o is List)
    for (final a in o)
      if (a is String) a,
];

CapNhatNgayApi _capNhat(Map<String, dynamic> m) => (
  loiNhan: m['message'] as String?,
  nhanTinhTrang: [
    for (final c in (m['conditions'] as List? ?? const [])) c as String,
  ],
  anh: [for (final a in (m['photoUrls'] as List? ?? const [])) a as String],
  luc: docMocVn(m['createdAt'] as String?),
);

ThongTinHuyNccApi? _thongTinHuy(Object? o) {
  if (o is! Map) return null;
  final m = Map<String, dynamic>.from(o);
  return (
    ben: m['by'] as String? ?? 'systemExpired',
    luc: docMocVn(m['at'] as String?),
    lyDo: m['reason'] as String?,
    moTa: m['note'] as String?,
    chuNuoiChiu: ((m['ownerFee'] as num?) ?? 0).round(),
    nccNhan: ((m['sitterPayout'] as num?) ?? 0).round(),
  );
}

UyTinNccApi _uyTin(Map<String, dynamic> m) => (
  tyLeHuy: (m['tyLeHuy'] as num?)?.toDouble() ?? 0,
  soCanhCao30Ngay: (m['soCanhCao30Ngay'] as num?)?.toInt() ?? 0,
  soDangChoSoat: (m['soDangChoSoat'] as num?)?.toInt() ?? 0,
  nguongTyLeHuy: (m['nguongTyLeHuy'] as num?)?.toDouble() ?? 0.2,
);

// Một trang danh sách đơn của người chăm
class TrangDonNcc {
  const TrangDonNcc({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory TrangDonNcc.fromJson(Map<String, dynamic> j) => TrangDonNcc(
    items: [
      for (final e in (j['items'] as List? ?? const []))
        DongDonNccApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    total: (j['total'] as num?)?.toInt() ?? 0,
    page: (j['page'] as num?)?.toInt() ?? 1,
    limit: (j['limit'] as num?)?.toInt() ?? 20,
  );

  final List<DongDonNccApi> items;
  final int total;
  final int page;
  final int limit;

  bool get conTrangSau => page * limit < total;
}

// Tóm tắt cho thẻ và sheet chuyển chế độ ở tab Tài khoản
class TomTatDonNcc {
  const TomTatDonNcc({this.soDonCho = 0, this.batDauKe});

  factory TomTatDonNcc.fromJson(Map<String, dynamic> j) => TomTatDonNcc(
    soDonCho: (j['pendingCount'] as num?)?.toInt() ?? 0,
    batDauKe: docMocVn(j['nextStartAt'] as String?),
  );

  final int soDonCho;

  // Giờ bắt đầu đơn đã nhận kế tiếp, null là lịch còn trống
  final DateTime? batDauKe;

  // Không có gì đang chờ thì sheet bỏ hẳn khối nhắc việc
  bool get coViecDangCho => soDonCho > 0 || batDauKe != null;
}
