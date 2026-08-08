import 'package:petcare_app/core/utils/vn_date.dart';

enum LoaiThongBao {
  donHang, // nhận đơn / xuất phát / đã tới / bắt đầu / hoàn thành / chờ xác nhận
  donHuy, // huỷ mọi nhánh, từ chối, không ai nhận, vắng mặt, thiếu dụng cụ
  donMoi, // đơn mới chờ NCC nhận, và hai mốc nhắc hạn nhận
  bangChung, // ảnh nhật ký, ảnh grooming sau khi xong, bản cập nhật kỳ giữa
  nhacLich, // sắp tới giờ, báo đến muộn, ETA vượt giờ, nhắc trước tự chốt
  hoSo, // duyệt hoặc từ chối hồ sơ, cảnh cáo, tạm ẩn, khoá tài khoản
  danhGia, // mời chủ nuôi đánh giá, hoặc NCC nhận đánh giá mới
  tinNhan, // tin nhắn mới trong phiên dịch vụ
  noiDung, // thông báo hệ thống: bảo trì, cập nhật điều khoản
  tienVi, // tiền vào ví, phần chia phí huỷ, hoàn tiền xong, rút tiền
  phongBenh, // nhắc phòng bệnh định kỳ: trước 7 ngày, đúng hạn, quá hạn
  khieuNai, // mở khiếu nại và kết luận của đội hỗ trợ
}

enum VaiNhan { chuNuoi, nguoiCham }

const _maLoai = <String, LoaiThongBao>{
  'DON_HANG': LoaiThongBao.donHang,
  'DON_HUY': LoaiThongBao.donHuy,
  'DON_MOI': LoaiThongBao.donMoi,
  'BANG_CHUNG': LoaiThongBao.bangChung,
  'NHAC_LICH': LoaiThongBao.nhacLich,
  'HO_SO': LoaiThongBao.hoSo,
  'DANH_GIA': LoaiThongBao.danhGia,
  'TIN_NHAN': LoaiThongBao.tinNhan,
  'NOI_DUNG': LoaiThongBao.noiDung,
  'TIEN_VI': LoaiThongBao.tienVi,
  'PHONG_BENH': LoaiThongBao.phongBenh,
  'KHIEU_NAI': LoaiThongBao.khieuNai,
};

const _maVai = <String, VaiNhan>{
  'CHU_NUOI': VaiNhan.chuNuoi,
  'NGUOI_CHAM': VaiNhan.nguoiCham,
};

// Backend trộn chuỗi với số, ép hết về chuỗi cho placeholder ARB
Map<String, String> _docThamSo(Object? tho) {
  if (tho is! Map) return const {};
  return {
    for (final e in tho.entries)
      if (e.value != null) e.key.toString(): e.value.toString(),
  };
}

String maCuaVai(VaiNhan vai) =>
    vai == VaiNhan.chuNuoi ? 'CHU_NUOI' : 'NGUOI_CHAM';

class ThongBao {
  const ThongBao({
    required this.id,
    required this.loai,
    required this.vai,
    required this.title,
    required this.message,
    required this.thoiDiem,
    this.titleKey,
    this.bodyKey,
    this.params = const {},
    this.canXuLy = false,
    this.targetId,
    this.daDoc = false,
  });

  final String id;
  final LoaiThongBao loai;
  final VaiNhan vai;
  final String title;
  final String message;
  final DateTime thoiDiem;

  final String? titleKey;
  final String? bodyKey;
  final Map<String, String> params;

  final bool canXuLy;

  final String? targetId;
  final bool daDoc;

  factory ThongBao.fromJson(Map<String, dynamic> json) => ThongBao(
    id: json['id'] as String,
    loai: _maLoai[json['type'] as String? ?? ''] ?? LoaiThongBao.donHang,
    vai: _maVai[json['role'] as String? ?? ''] ?? VaiNhan.chuNuoi,
    title: (json['title'] as String?) ?? '',
    message: (json['body'] as String?) ?? '',
    thoiDiem: docMocVn(json['createdAt'] as String?) ?? nowVn(),
    titleKey: json['titleKey'] as String?,
    bodyKey: json['bodyKey'] as String?,
    params: _docThamSo(json['params']),
    canXuLy: (json['urgent'] as bool?) ?? false,
    targetId: json['targetId'] as String?,
    daDoc: (json['isRead'] as bool?) ?? false,
  );

  ThongBao copyWith({bool? daDoc}) => ThongBao(
    id: id,
    loai: loai,
    vai: vai,
    title: title,
    message: message,
    thoiDiem: thoiDiem,
    titleKey: titleKey,
    bodyKey: bodyKey,
    params: params,
    canXuLy: canXuLy,
    targetId: targetId,
    daDoc: daDoc ?? this.daDoc,
  );

  int get soPhutTruoc => nowVn().difference(thoiDiem).inMinutes;

  bool get laHomNay {
    final homNay = nowVn();
    return thoiDiem.year == homNay.year &&
        thoiDiem.month == homNay.month &&
        thoiDiem.day == homNay.day;
  }
}

extension NhomThongBao on List<ThongBao> {
  List<ThongBao> theoVai(VaiNhan? vai) =>
      vai == null ? this : where((n) => n.vai == vai).toList();

  List<ThongBao> get canXuLyNgay =>
      where((n) => n.canXuLy && !n.daDoc).toList();

  List<ThongBao> get homNay =>
      where((n) => n.laHomNay && !(n.canXuLy && !n.daDoc)).toList();

  List<ThongBao> get truocDo =>
      where((n) => !n.laHomNay && !(n.canXuLy && !n.daDoc)).toList();
}
