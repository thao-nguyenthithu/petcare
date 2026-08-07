import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';

enum BookingStatus { choXacNhan, sapToi, dangDienRa, hoanThanh, daHuy }

extension BookingStatusApi on BookingStatus {
  String get maApi => switch (this) {
    BookingStatus.choXacNhan => 'pending',
    BookingStatus.sapToi => 'upcoming',
    BookingStatus.dangDienRa => 'ongoing',
    BookingStatus.hoanThanh => 'completed',
    BookingStatus.daHuy => 'cancelled',
  };
}

enum PetServiceType { datDiDao, trongGiu, tamTia }

extension PetServiceTypeApi on PetServiceType {
  String get maApi => switch (this) {
    PetServiceType.datDiDao => 'walking',
    PetServiceType.trongGiu => 'boarding',
    PetServiceType.tamTia => 'grooming',
  };
}

enum TrangThaiDon {
  choNhan,
  daNhan,
  choChuNuoiChot,
  dangChay,
  hoanThanh,
  daHuy,
  khieuNai,
  daXuLy,
  khongRo,
}

TrangThaiDon trangThaiTuMa(String? ma) => switch (ma) {
  'pending' => TrangThaiDon.choNhan,
  'confirmed' => TrangThaiDon.daNhan,
  'awaitingOwnerConfirm' => TrangThaiDon.choChuNuoiChot,
  'inProgress' || 'pausedWaitingOwner' => TrangThaiDon.dangChay,
  'completed' => TrangThaiDon.hoanThanh,
  'cancelledByOwner' ||
  'cancelledBySitter' ||
  'cancelledExpired' ||
  'cancelledNoShow' ||
  'cancelledByAdmin' => TrangThaiDon.daHuy,
  'disputed' => TrangThaiDon.khieuNai,
  'resolved' => TrangThaiDon.daXuLy,
  _ => TrangThaiDon.khongRo,
};

PetServiceType _loaiTuMa(String? ma) => switch (ma) {
  'boarding' => PetServiceType.trongGiu,
  'grooming' => PetServiceType.tamTia,
  _ => PetServiceType.datDiDao,
};

const int _trongNgay = 24 * 60;
const int _quaXa = 1 << 30;

class OwnerBooking {
  const OwnerBooking({
    required this.id,
    required this.code,
    required this.serviceType,
    required this.serviceName,
    required this.pets,
    required this.providerName,
    required this.startAt,
    required this.price,
    required this.trangThai,
    this.providerAvatar,
    this.endAt,
    this.deadlineAt,
  });

  factory OwnerBooking.fromJson(Map<String, dynamic> json) => OwnerBooking(
    id: json['id'] as String,
    code: json['code'] as String? ?? '',
    serviceType: _loaiTuMa(json['serviceType'] as String?),
    serviceName: json['serviceName'] as String? ?? '',
    pets: [
      for (final e in (json['pets'] as List? ?? const []))
        _beTuJson(Map<String, dynamic>.from(e as Map)),
    ],
    providerName: json['sitterName'] as String? ?? '',
    providerAvatar: json['sitterAvatarUrl'] as String?,
    startAt: docMocVn(json['startAt'] as String?) ?? nowVn(),
    endAt: docMocVn(json['endAt'] as String?),
    deadlineAt: docMocVn(json['deadlineAt'] as String?),
    price: (json['priceAmount'] as num?)?.round() ?? 0,
    trangThai: trangThaiTuMa(json['status'] as String?),
  );

  final String id;
  final String code;
  final PetServiceType serviceType;
  final String serviceName;
  final List<PetBrief> pets;
  final String providerName;
  final String? providerAvatar;
  final DateTime startAt;
  final DateTime? endAt;
  final DateTime? deadlineAt;
  final int price;
  final TrangThaiDon trangThai;

  BookingStatus? get status => switch (trangThai) {
    TrangThaiDon.choNhan => BookingStatus.choXacNhan,
    TrangThaiDon.daNhan => BookingStatus.sapToi,
    TrangThaiDon.choChuNuoiChot ||
    TrangThaiDon.dangChay ||
    TrangThaiDon.khieuNai => BookingStatus.dangDienRa,
    TrangThaiDon.hoanThanh || TrangThaiDon.daXuLy => BookingStatus.hoanThanh,
    TrangThaiDon.daHuy => BookingStatus.daHuy,
    TrangThaiDon.khongRo => null,
  };

  bool get choBanXacNhan => trangThai == TrangThaiDon.choChuNuoiChot;

  bool get theoNgay => serviceType == PetServiceType.trongGiu;

  bool get nhieuBe => pets.length > 1;

  DateTime? get _mocDem => switch (trangThai) {
    TrangThaiDon.choNhan || TrangThaiDon.choChuNuoiChot => deadlineAt,
    TrangThaiDon.daNhan => startAt,
    TrangThaiDon.dangChay => endAt,
    _ => null,
  };

  int? get remainingMinutes {
    final moc = _mocDem;
    if (moc == null) return null;
    final phut = moc.difference(nowVn()).inMinutes;
    return phut < 0 ? 0 : phut;
  }

  bool get sapToiGan =>
      status == BookingStatus.sapToi &&
      (remainingMinutes ?? _quaXa) <= _trongNgay;

  bool get dangChay =>
      trangThai == TrangThaiDon.dangChay && (remainingMinutes ?? 0) > 0;

  LoaiDichVu get loaiDichVu => switch (serviceType) {
    PetServiceType.datDiDao => LoaiDichVu.datDiDao,
    PetServiceType.trongGiu => LoaiDichVu.trongGiu,
    PetServiceType.tamTia => LoaiDichVu.catTia,
  };

  int? get soDem {
    if (!theoNgay) return null;
    final het = endAt;
    if (het == null) return null;
    final dem = soNgayLech(startAt, het);
    return dem < 1 ? 1 : dem;
  }

  int? get thoiLuongPhut {
    if (theoNgay) return null;
    return endAt?.difference(startAt).inMinutes;
  }
}

extension OwnerBookingHienThi on OwnerBooking {
  String nhanThoiLuong(AppLocalizations l10n) {
    final dem = soDem;
    return dem != null
        ? l10n.nDemNhan('$dem')
        : l10n.nPhutNhan('${thoiLuongPhut ?? 0}');
  }

  String nhanThoiGian(AppLocalizations l10n) {
    final het = endAt;
    if (soDem != null && het != null) {
      return '${_nhanNgay(l10n, startAt)} - ${_nhanNgay(l10n, het)}'
          ' · ${l10n.nhanLucGio(gioPhut(startAt))}';
    }
    final khoang = het == null
        ? gioPhut(startAt)
        : '${gioPhut(startAt)} - ${gioPhut(het)}';
    final duoi = _duoiThoiGian(l10n);
    final dong = '${_nhanNgay(l10n, startAt)} · $khoang';
    return duoi == null ? dong : '$dong · $duoi';
  }

  String nhanCacBe(AppLocalizations l10n) {
    if (pets.isEmpty) return '';
    if (pets.length == 1) return pets.first.name;
    return l10n.nBeVaTen('${pets.length}', pets.map((p) => p.name).join(', '));
  }

  String nhanCacBeVaGhiChu(AppLocalizations l10n) {
    final be = nhanCacBe(l10n);
    final chu = _ghiChu(l10n);
    return chu == null ? be : '$be · $chu';
  }

  String? _ghiChu(AppLocalizations l10n) => switch (trangThai) {
    TrangThaiDon.choNhan => l10n.choNguoiChamNhan,
    TrangThaiDon.choChuNuoiChot => l10n.choBanXacNhanDon,
    TrangThaiDon.khieuNai => l10n.banDangKhieuNai,
    TrangThaiDon.daXuLy => l10n.hoTroDaXuLy,
    _ => null,
  };

  String? _duoiThoiGian(AppLocalizations l10n) => switch (trangThai) {
    TrangThaiDon.choChuNuoiChot => l10n.nguoiChamDaXongViec,
    TrangThaiDon.khieuNai => l10n.daXongViec,
    _ => null,
  };

  String _nhanNgay(AppLocalizations l10n, DateTime d) {
    final homNay = homNayVn();
    if (cungNgay(d, homNay)) return l10n.homNay;
    if (cungNgay(d, homNay.subtract(const Duration(days: 1)))) {
      return l10n.homQua;
    }
    return '${thuNgan(l10n, d)} ${ngayThang(d)}';
  }
}

PetBrief _beTuJson(Map<String, dynamic> json) => PetBrief(
  name: json['name'] as String? ?? '',
  species: json['species'] as String? ?? '',
  avatar: json['avatarUrl'] as String?,
);

class TrangDonCuaToi {
  const TrangDonCuaToi({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.dangTaiThem = false,
  });

  factory TrangDonCuaToi.fromJson(Map<String, dynamic> json) => TrangDonCuaToi(
    items: [
      for (final e in (json['items'] as List? ?? const []))
        OwnerBooking.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    total: (json['total'] as num?)?.toInt() ?? 0,
    page: (json['page'] as num?)?.toInt() ?? 1,
    limit: (json['limit'] as num?)?.toInt() ?? 20,
  );

  final List<OwnerBooking> items;
  final int total;
  final int page;
  final int limit;

  final bool dangTaiThem;

  bool get conTrangSau => page * limit < total;

  TrangDonCuaToi copyWith({bool? dangTaiThem}) => TrangDonCuaToi(
    items: items,
    total: total,
    page: page,
    limit: limit,
    dangTaiThem: dangTaiThem ?? this.dangTaiThem,
  );

  TrangDonCuaToi noiThem(TrangDonCuaToi tiep) => TrangDonCuaToi(
    items: [...items, ...tiep.items],
    total: tiep.total,
    page: tiep.page,
    limit: tiep.limit,
  );
}
