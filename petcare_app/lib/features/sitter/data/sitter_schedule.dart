import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/sitter_availability.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Lịch làm việc của NCC

const String gioMoMacDinh = '07:00';
const String gioDongMacDinh = '20:00';

// Vòng đời một đơn trên lịch, suy từ BookingStatus
enum ScheduleApptStatus { sapToi, dangDienRa, choXacNhan, hoanThanh }

extension ScheduleApptStatusX on ScheduleApptStatus {
  bool get conHieuLuc =>
      this == ScheduleApptStatus.sapToi ||
      this == ScheduleApptStatus.dangDienRa;
}

ScheduleApptStatus _trangThaiTuMa(Object? ma) => switch (ma) {
  'dangDienRa' => ScheduleApptStatus.dangDienRa,
  'choXacNhan' => ScheduleApptStatus.choXacNhan,
  'hoanThanh' => ScheduleApptStatus.hoanThanh,
  _ => ScheduleApptStatus.sapToi,
};

ServiceType _loaiTuMa(Object? ma) => ServiceType.values.firstWhere(
  (e) => e.name == ma,
  orElse: () => ServiceType.walking,
);

enum PhanNgayTrongGiu { nhan, troc, tra }

PhanNgayTrongGiu? _phanNgayTuMa(Object? ma) => switch (ma) {
  'nhan' => PhanNgayTrongGiu.nhan,
  'troc' => PhanNgayTrongGiu.troc,
  'tra' => PhanNgayTrongGiu.tra,
  _ => null,
};

// Một lịch hẹn
class ScheduleAppointment {
  const ScheduleAppointment({
    required this.id,
    required this.code,
    required this.startTime,
    required this.endTime,
    required this.serviceName,
    required this.serviceType,
    required this.pets,
    required this.ownerName,
    this.district,
    required this.status,
    this.ngayThu = 1,
    this.tongNgay = 1,
    this.phanNgay,
  });

  final String id;
  final String code;
  final String startTime;
  final String endTime;
  final String serviceName;
  final ServiceType serviceType;
  final List<PetBrief> pets;
  final String ownerName;
  final String? district;
  final ScheduleApptStatus status;
  final int ngayThu;
  final int tongNgay;
  final PhanNgayTrongGiu? phanNgay;

  bool get nhieuNgay => tongNgay > 1;
  bool get laNgayDau => ngayThu == 1;
  bool get laNgayCuoi => ngayThu == tongNgay;

  bool get dangDienRa => status == ScheduleApptStatus.dangDienRa;

  DateTime gioHenNgay(DateTime ngay) {
    final phan = startTime.split(':');
    return DateTime(
      ngay.year,
      ngay.month,
      ngay.day,
      int.tryParse(phan.first) ?? 0,
      int.tryParse(phan.last) ?? 0,
    );
  }

  factory ScheduleAppointment.fromJson(Map<String, dynamic> j) =>
      ScheduleAppointment(
        id: j['id'] as String? ?? '',
        code: j['code'] as String? ?? '',
        startTime: j['startTime'] as String? ?? '',
        endTime: j['endTime'] as String? ?? '',
        serviceName: j['serviceName'] as String? ?? '',
        serviceType: _loaiTuMa(j['serviceType']),
        pets:
            (j['pets'] as List?)
                ?.map(
                  (e) => PetBrief(
                    name: (e as Map)['name'] as String? ?? '',
                    species: e['species'] as String? ?? '',
                    avatar: e['avatarUrl'] as String?,
                  ),
                )
                .toList() ??
            const [],
        ownerName: j['ownerName'] as String? ?? '',
        district: j['district'] as String?,
        status: _trangThaiTuMa(j['status']),
        ngayThu: (j['ngayThu'] as num?)?.toInt() ?? 1,
        tongNgay: (j['tongNgay'] as num?)?.toInt() ?? 1,
        phanNgay: _phanNgayTuMa(j['dayPart']),
      );
}

class ScheduleDay {
  const ScheduleDay({
    required this.date,
    required this.appointments,
    required this.ngayNghi,
    required this.kinCho,
  });

  final DateTime date;
  final List<ScheduleAppointment> appointments;
  final bool ngayNghi;
  final bool kinCho;

  bool get isToday => cungNgay(date, homNayVn());
  bool get coLichHen => appointments.isNotEmpty;
}

class KhoangLich {
  const KhoangLich({
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.ngayLamViec,
    required this.soChoToiDa,
    required this.thietLap,
    required this.lich,
  });

  final String gioBatDau;
  final String gioKetThuc;
  final Set<int> ngayLamViec;
  final int soChoToiDa;
  final Map<String, DayAvailability> thietLap;
  final Map<String, List<ScheduleAppointment>> lich;

  factory KhoangLich.fromJson(Map<String, dynamic> j) {
    final soCho = (j['boardingCapacity'] as num?)?.toInt() ?? 0;
    final thietLap = <String, DayAvailability>{};
    final lich = <String, List<ScheduleAppointment>>{};
    for (final e in (j['days'] as List?) ?? const []) {
      final ngay = (e as Map)['date'] as String?;
      if (ngay == null) continue;
      thietLap[ngay] = DayAvailability.fromJson(
        Map<String, dynamic>.from(e),
        soCho,
      );
      final don = (e['appointments'] as List?) ?? const [];
      if (don.isEmpty) continue;
      lich[ngay] = don
          .map(
            (d) => ScheduleAppointment.fromJson(
              Map<String, dynamic>.from(d as Map),
            ),
          )
          .toList();
    }
    return KhoangLich(
      gioBatDau: j['workStart'] as String? ?? gioMoMacDinh,
      gioKetThuc: j['workEnd'] as String? ?? gioDongMacDinh,
      ngayLamViec: {
        for (final t in (j['workDays'] as List?) ?? const [])
          (t as num).toInt(),
      },
      soChoToiDa: soCho,
      thietLap: thietLap,
      lich: lich,
    );
  }
}

// Toàn bộ lịch NCC đang giữ trong máy, tra theo khoá yyyy-MM-dd
class SitterSchedule {
  const SitterSchedule({
    this.gioBatDau = gioMoMacDinh,
    this.gioKetThuc = gioDongMacDinh,
    this.ngayLamViec = const {1, 2, 3, 4, 5, 6},
    this.soChoToiDa = 0,
    this.thietLap = const {},
    this.lich = const {},
    this.ngayDaTai = const {},
  });

  final String gioBatDau;
  final String gioKetThuc;
  final Set<int> ngayLamViec;
  final int soChoToiDa;
  final Map<String, DayAvailability> thietLap;
  final Map<String, List<ScheduleAppointment>> lich;
  final Set<String> ngayDaTai;

  DayAvailability cuaNgay(DateTime ngay) =>
      thietLap[ngayJson(ngay)] ?? DayAvailability(boardingSlots: soChoToiDa);

  bool nghiTheoTuan(DateTime ngay) => !ngayLamViec.contains(ngay.weekday);

  bool ngayNghi(DateTime ngay) {
    final cai = cuaNgay(ngay);
    if (cai.nghi) return true;
    return cai.mode != DayMode.gioRieng && nghiTheoTuan(ngay);
  }

  int soChoConNhan(DateTime ngay) => cuaNgay(ngay).boardingLeft;

  int soChoToiDaCuaNgay(DateTime ngay) {
    final con = soChoToiDa - cuaNgay(ngay).boardingUsed;
    return con > 0 ? con : 0;
  }

  bool kinCho(DateTime ngay) =>
      soChoToiDa > 0 && !ngayNghi(ngay) && soChoConNhan(ngay) == 0;

  List<ScheduleAppointment> lichCuaNgay(DateTime ngay) =>
      lich[ngayJson(ngay)] ?? const [];

  ScheduleDay chiTietNgay(DateTime ngay) => ScheduleDay(
    date: ngay,
    appointments: lichCuaNgay(ngay),
    ngayNghi: ngayNghi(ngay),
    kinCho: kinCho(ngay),
  );

  List<ScheduleDay> tuanTu(DateTime thuHai) =>
      List.generate(7, (i) => chiTietNgay(thuHai.add(Duration(days: i))));

  bool daTaiKhoang(DateTime tu, DateTime den) {
    var ngay = chiNgay(tu);
    final cuoi = chiNgay(den);
    while (!ngay.isAfter(cuoi)) {
      if (!ngayDaTai.contains(ngayJson(ngay))) return false;
      ngay = ngay.add(const Duration(days: 1));
    }
    return true;
  }

  // Các đơn chặn việc đặt nghỉ của ngày đó
  List<ScheduleAppointment> donConHieuLuc(DateTime ngay) =>
      lichCuaNgay(ngay).where((appt) => appt.status.conHieuLuc).toList();

  // Ngày có đơn ĐANG diễn ra thì không thể nghỉ (đơn đang chạy không huỷ được)
  bool coDonDangDienRa(DateTime ngay) =>
      lichCuaNgay(ngay).any((appt) => appt.dangDienRa);

  List<DateTime> _ngayThoaTrongKhoang(
    DateTime tu,
    DateTime den,
    bool Function(DateTime) thoa,
  ) {
    final ketQua = <DateTime>[];
    var ngay = chiNgay(tu);
    final cuoi = chiNgay(den);
    while (!ngay.isAfter(cuoi)) {
      if (thoa(ngay)) ketQua.add(ngay);
      ngay = ngay.add(const Duration(days: 1));
    }
    return ketQua;
  }

  // Các ngày trong khoảng đang có đơn chạy
  List<DateTime> ngayDangDienRaTrongKhoang(DateTime tu, DateTime den) =>
      _ngayThoaTrongKhoang(tu, den, coDonDangDienRa);

  // Các ngày còn đơn chưa xong trong một khoảng
  List<DateTime> ngayConDonTrongKhoang(DateTime tu, DateTime den) =>
      _ngayThoaTrongKhoang(tu, den, (n) => donConHieuLuc(n).isNotEmpty);

  // Tổng số đơn chưa xong trong một khoảng
  int soDonConTrongKhoang(DateTime tu, DateTime den) => ngayConDonTrongKhoang(
    tu,
    den,
  ).fold(0, (sum, ngay) => sum + donConHieuLuc(ngay).length);

  SitterSchedule copyWith({
    String? gioBatDau,
    String? gioKetThuc,
    Set<int>? ngayLamViec,
    int? soChoToiDa,
    Map<String, DayAvailability>? thietLap,
    Map<String, List<ScheduleAppointment>>? lich,
    Set<String>? ngayDaTai,
  }) => SitterSchedule(
    gioBatDau: gioBatDau ?? this.gioBatDau,
    gioKetThuc: gioKetThuc ?? this.gioKetThuc,
    ngayLamViec: ngayLamViec ?? this.ngayLamViec,
    soChoToiDa: soChoToiDa ?? this.soChoToiDa,
    thietLap: thietLap ?? this.thietLap,
    lich: lich ?? this.lich,
    ngayDaTai: ngayDaTai ?? this.ngayDaTai,
  );

  SitterSchedule gop(DateTime tu, DateTime den, KhoangLich khoang) {
    final khoaTrongKhoang = <String>{};
    var ngay = chiNgay(tu);
    final cuoi = chiNgay(den);
    while (!ngay.isAfter(cuoi)) {
      khoaTrongKhoang.add(ngayJson(ngay));
      ngay = ngay.add(const Duration(days: 1));
    }
    final thietLapMoi = {
      for (final e in thietLap.entries)
        if (!khoaTrongKhoang.contains(e.key)) e.key: e.value,
      ...khoang.thietLap,
    };
    final lichMoi = {
      for (final e in lich.entries)
        if (!khoaTrongKhoang.contains(e.key)) e.key: e.value,
      ...khoang.lich,
    };
    return SitterSchedule(
      gioBatDau: khoang.gioBatDau,
      gioKetThuc: khoang.gioKetThuc,
      ngayLamViec: khoang.ngayLamViec,
      soChoToiDa: khoang.soChoToiDa,
      thietLap: thietLapMoi,
      lich: lichMoi,
      ngayDaTai: {...ngayDaTai, ...khoaTrongKhoang},
    );
  }

  SitterSchedule datNgay(DateTime ngay, DayAvailability giaTri) =>
      copyWith(thietLap: {...thietLap, ngayJson(ngay): giaTri});

  SitterSchedule boDon(String idDon) => copyWith(
    lich: {
      for (final e in lich.entries)
        e.key: e.value.where((appt) => appt.id != idDon).toList(),
    },
  );
}
