import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/pets/data/prevention_items.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';

// Đơn vị chu kỳ nhắc lại
enum CycleUnit { ngay, tuan, thang }

// Một mức nhắc lại
class PreventionCycle {
  const PreventionCycle(this.so, this.donVi);

  const PreventionCycle.ngay(this.so) : donVi = CycleUnit.ngay;
  const PreventionCycle.tuan(this.so) : donVi = CycleUnit.tuan;
  const PreventionCycle.thang(this.so) : donVi = CycleUnit.thang;

  final int so;
  final CycleUnit donVi;

  static CycleUnit donViTuJson(String ma) => switch (ma) {
    'DAY' => CycleUnit.ngay,
    'WEEK' => CycleUnit.tuan,
    _ => CycleUnit.thang,
  };

  String get donViJson => switch (donVi) {
    CycleUnit.ngay => 'DAY',
    CycleUnit.tuan => 'WEEK',
    CycleUnit.thang => 'MONTH',
  };

  // Hạn kế tiếp tính từ ngày vừa thực hiện
  DateTime apDung(DateTime tu) => switch (donVi) {
    CycleUnit.ngay => tu.add(Duration(days: so)),
    CycleUnit.tuan => tu.add(Duration(days: so * 7)),
    CycleUnit.thang => congThang(tu, so),
  };

  @override
  bool operator ==(Object other) =>
      other is PreventionCycle && other.so == so && other.donVi == donVi;

  @override
  int get hashCode => Object.hash(so, donVi);
}

DateTime congThang(DateTime tu, int soThang) {
  final thang = tu.month + soThang;
  final nam = tu.year + (thang - 1) ~/ 12;
  final thangCuoi = (thang - 1) % 12 + 1;
  final soNgayCuaThang = DateTime(nam, thangCuoi + 1, 0).day;
  return DateTime(nam, thangCuoi, tu.day.clamp(1, soNgayCuaThang));
}

// Hệ thống bắt đầu nhắc trước hạn
const int nguongSapToiHanNgay = 7;
const String idTamHangMuc = 'tam-';

// Trạng thái nhắc lại của một hạng mục
enum PreventionStatus { conHan, sapToiHan, quaHan, khongNhac, chuaGhi }

class PreventionDose {
  const PreventionDose({
    required this.id,
    required this.ngay,
    this.chuKy,
    this.noiThucHien,
    this.anh = const [],
  });

  final String id;
  final DateTime ngay;
  final PreventionCycle? chuKy;
  final String? noiThucHien;
  final List<PhotoItem> anh;

  factory PreventionDose.fromJson(Map<String, dynamic> j) {
    final so = j['cycleValue'] as int?;
    final donVi = j['cycleUnit'] as String?;
    return PreventionDose(
      id: j['id'] as String,
      ngay: docNgayJson(j['doneAt'] as String)!,
      chuKy: so == null || donVi == null
          ? null
          : PreventionCycle(so, PreventionCycle.donViTuJson(donVi)),
      noiThucHien: j['place'] as String?,
      anh: [
        for (final a in (j['photos'] as List? ?? []))
          PhotoItem.mang(
            (a as Map)['url'] as String,
            id: a['id'] as String?,
            ngayThem: DateTime.tryParse(
              a['createdAt'] as String? ?? '',
            )?.toLocal(),
          ),
      ],
    );
  }

  // Thân request khi ghi hoặc sửa một lần
  Map<String, dynamic> toJson() => {
    'doneAt': ngayJson(ngay),
    'cycleValue': chuKy?.so,
    'cycleUnit': chuKy?.donViJson,
    'place': noiThucHien,
  };

  DateTime? get ngayNhacLai => chuKy?.apDung(ngay);

  PreventionDose copyWith({
    DateTime? ngay,
    PreventionCycle? chuKy,
    bool xoaChuKy = false,
    String? noiThucHien,
    List<PhotoItem>? anh,
  }) => PreventionDose(
    id: id,
    ngay: ngay ?? this.ngay,
    chuKy: xoaChuKy ? null : (chuKy ?? this.chuKy),
    noiThucHien: noiThucHien ?? this.noiThucHien,
    anh: anh ?? this.anh,
  );
}

// Một hạng mục phòng bệnh của bé
class PreventionRecord {
  const PreventionRecord({
    required this.id,
    required this.ma,
    required this.hinhThuc,
    this.tenTuNhap,
    required this.lanThucHien,
    this.chuKyDeXuat,
    this.dinhKy = false,
  });

  final String id;
  final String ma;
  final String? tenTuNhap;
  final PreventionForm hinhThuc;
  final List<PreventionDose> lanThucHien;
  final PreventionCycle? chuKyDeXuat;
  final bool dinhKy;

  factory PreventionRecord.fromJson(Map<String, dynamic> j) {
    final so = j['suggestedCycleValue'] as int?;
    final donVi = j['suggestedCycleUnit'] as String?;
    return PreventionRecord(
      id: j['id'] as String,
      ma: j['code'] as String,
      tenTuNhap: j['customName'] as String?,
      hinhThuc: hinhThucTuJson(j['form'] as String),
      dinhKy: j['isPeriodic'] as bool? ?? false,
      chuKyDeXuat: so == null || donVi == null
          ? null
          : PreventionCycle(so, PreventionCycle.donViTuJson(donVi)),
      lanThucHien: [
        for (final d in (j['doses'] as List? ?? []))
          PreventionDose.fromJson(Map<String, dynamic>.from(d as Map)),
      ],
    );
  }

  // Thân request khi tạo hạng mục mới
  Map<String, dynamic> toJson() => {
    'code': ma,
    'customName': tenTuNhap,
    'form': hinhThucJson,
    'isPeriodic': dinhKy,
    'suggestedCycleValue': chuKyDeXuat?.so,
    'suggestedCycleUnit': chuKyDeXuat?.donViJson,
  };

  String get hinhThucJson => switch (hinhThuc) {
    PreventionForm.vacXin => 'VACCINE',
    PreventionForm.uong => 'ORAL',
    PreventionForm.nhoGay => 'SPOT_ON',
    PreventionForm.khac => 'OTHER',
  };

  static PreventionForm hinhThucTuJson(String ma) => switch (ma) {
    'VACCINE' => PreventionForm.vacXin,
    'ORAL' => PreventionForm.uong,
    'SPOT_ON' => PreventionForm.nhoGay,
    _ => PreventionForm.khac,
  };

  bool get daLuuTrenServer => !id.startsWith(idTamHangMuc);
  int get soLan => lanThucHien.length;
  bool get chuaCoLan => lanThucHien.isEmpty;

  // Lần mới nhất, cũng là mốc để tính hạn kế tiếp
  PreventionDose? get lanGanNhat => chuaCoLan
      ? null
      : lanThucHien.reduce((a, b) => a.ngay.isAfter(b.ngay) ? a : b);

  DateTime? get ngayNhacLai => lanGanNhat?.ngayNhacLai;

  PreventionCycle? get chuKyHienHanh => lanGanNhat?.chuKy ?? chuKyDeXuat;

  // Ảnh phiếu của mọi lần
  List<PhotoItem> get anh => [for (final lan in lanThucHien) ...lan.anh];

  PreventionStatus get trangThai {
    if (chuaCoLan) return PreventionStatus.chuaGhi;
    final han = ngayNhacLai;
    if (han == null) return PreventionStatus.khongNhac;
    final soNgay = soNgayLech(homNayVn(), han);
    if (soNgay < 0) return PreventionStatus.quaHan;
    if (soNgay <= nguongSapToiHanNgay) return PreventionStatus.sapToiHan;
    return PreventionStatus.conHan;
  }

  // Số ngày còn lại tới hạn
  int? get soNgayConLai {
    final han = ngayNhacLai;
    return han == null ? null : soNgayLech(homNayVn(), han);
  }

  PreventionRecord copyWith({
    String? tenTuNhap,
    PreventionForm? hinhThuc,
    List<PreventionDose>? lanThucHien,
    PreventionCycle? chuKyDeXuat,
    bool? dinhKy,
  }) => PreventionRecord(
    id: id,
    ma: ma,
    tenTuNhap: tenTuNhap ?? this.tenTuNhap,
    hinhThuc: hinhThuc ?? this.hinhThuc,
    lanThucHien: lanThucHien ?? this.lanThucHien,
    chuKyDeXuat: chuKyDeXuat ?? this.chuKyDeXuat,
    dinhKy: dinhKy ?? this.dinhKy,
  );
}
