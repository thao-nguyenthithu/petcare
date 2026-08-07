import 'package:flutter/foundation.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_check_in.dart';

// Ô 0 là tấm cả đàn, chỉ lưu bằng chứng, không phán quyết
const int slotCaDan = 0;

// Ba kết luận AI trả cho một tấm riêng
enum KetLuanQuet { dat, khongDat, chuaXacMinhDuoc }

// Server chốt lối đi từng ô, app không tự tính lại
enum XuLySlot { diTiep, canTuXacNhan, chupLai }

// Bốn màn kết quả, app suy ra từ danh sách ô
enum ManQuetAi { dangQuet, aiDu, chuaQuaKiem, hetLanChup }

// Mã lạ về nhánh chưa xác minh, không ghi vi phạm
KetLuanQuet _ketLuan(String? ma) => switch (ma) {
  'DAT' => KetLuanQuet.dat,
  'KHONG_DAT' => KetLuanQuet.khongDat,
  _ => KetLuanQuet.chuaXacMinhDuoc,
};

// Mã lạ thì bắt chụp lại, không tự mở đường đi tiếp
XuLySlot _xuLy(String? ma) => switch (ma) {
  'DI_TIEP' => XuLySlot.diTiep,
  'TU_XAC_NHAN' => XuLySlot.canTuXacNhan,
  'CHUP_LAI' => XuLySlot.chupLai,
  // Kêu lên để không im lặng nuốt lỗi lệch tên mã
  _ => _laLoi(ma),
};

XuLySlot _laLoi(String? ma) {
  debugPrint('Không hiểu mã xử lý slot của server: $ma');
  return XuLySlot.chupLai;
}

// Phán quyết cho một tấm, đếm lượt riêng theo ô
class SlotQuet {
  const SlotQuet({
    required this.slotIndex,
    required this.ketLuan,
    required this.xuLy,
    required this.reason,
    required this.ghiChu,
    required this.doTinCay,
    required this.anhDuNet,
    required this.soLanConLai,
    required this.daTuXacNhan,
    required this.luotNayCoTru,
    this.anhUrl,
  });

  factory SlotQuet.fromJson(Map<String, dynamic> json) => SlotQuet(
    slotIndex: (json['slotIndex'] as num?)?.toInt() ?? slotCaDan,
    ketLuan: _ketLuan(json['trangThai'] as String?),
    xuLy: _xuLy(json['xuLy'] as String?),
    reason: json['reason'] as String? ?? '',
    ghiChu: json['ghiChu'] as String?,
    doTinCay: (json['confidence'] as num?)?.toDouble() ?? 0,
    anhDuNet: json['anhDuNet'] != false,
    soLanConLai: (json['soLanConLai'] as num?)?.toInt() ?? 0,
    daTuXacNhan: json['daTuXacNhan'] == true,
    luotNayCoTru: json['luotNayCoTru'] != false,
    anhUrl: json['anhUrl'] as String?,
  );

  final int slotIndex;

  // Thiếu thật khác ảnh không đọc được, màn phải nói khác
  final KetLuanQuet ketLuan;

  final XuLySlot xuLy;

  // Câu server soạn sẵn, hiển thị nguyên văn
  final String reason;

  // null thì đừng chừa chỗ trống trên màn
  final String? ghiChu;

  // Chỉ để hiển thị, lối đi do server chốt ở xuLy
  final double doTinCay;

  final bool anhDuNet;

  final int soLanConLai;
  final bool daTuXacNhan;

  // false là lỗi hạ tầng, bộ đếm lượt không bị trừ
  final bool luotNayCoTru;

  final String? anhUrl;

  // Hết chặn: server cho đi tiếp hoặc người chăm đã ký
  bool get xong => daTuXacNhan || xuLy != XuLySlot.chupLai;

  // Đi tiếp được nhưng phải có chữ ký người chăm
  bool get canTuXacNhan => xuLy == XuLySlot.canTuXacNhan && !daTuXacNhan;

  bool get conLuot => soLanConLai > 0;

  int get phanTramTinCay => (doTinCay * 100).round();
}

// Trạng thái quét của một đơn, dùng cho cả REST lẫn socket
class KetQuaLoQuet {
  const KetQuaLoQuet({
    required this.slots,
    required this.duDieuKienBatDau,
    this.batchId,
    this.dangQuet = false,
  });

  // Vừa gửi lô, chưa có phán quyết nào
  const KetQuaLoQuet.dangQuetLo(this.batchId)
    : slots = const [],
      duDieuKienBatDau = false,
      dangQuet = true;

  factory KetQuaLoQuet.fromJson(Map<String, dynamic> json) {
    final ds = json['slots'];
    return KetQuaLoQuet(
      slots: [
        if (ds is List)
          for (final s in ds)
            if (s is Map) SlotQuet.fromJson(Map<String, dynamic>.from(s)),
      ],
      duDieuKienBatDau: json['duDieuKienBatDau'] == true,
      batchId: json['batchId'] as String?,
      dangQuet: json['trangThai'] == 'PROCESSING',
    );
  }

  final List<SlotQuet> slots;

  // Server chốt cho đi tiếp hay không, app không suy ra
  final bool duDieuKienBatDau;

  final String? batchId;
  final bool dangQuet;

  // Tấm cả đàn không có phán quyết nên phải loại ra
  List<SlotQuet> get slotBe =>
      slots.where((s) => s.slotIndex != slotCaDan).toList();

  ManQuetAi get man {
    if (dangQuet) return ManQuetAi.dangQuet;
    final be = slotBe;
    if (be.isEmpty) return ManQuetAi.dangQuet;
    final chua = be.where((s) => !s.xong).toList();
    if (chua.isEmpty) return ManQuetAi.aiDu;
    return chua.any((s) => s.conLuot)
        ? ManQuetAi.chuaQuaKiem
        : ManQuetAi.hetLanChup;
  }

  // Còn lượt thì chụp lại, hết lượt mới tới van xả
  SlotQuet? get slotDangVuong {
    final chua = slotBe.where((s) => !s.xong).toList();
    if (chua.isEmpty) return null;
    return chua.firstWhere((s) => s.conLuot, orElse: () => chua.first);
  }

  List<SlotQuet> get slotCanTuXacNhan =>
      slotBe.where((s) => s.canTuXacNhan).toList();

  bool get batDauDuoc => duDieuKienBatDau && man == ManQuetAi.aiDu;
}

// Ảnh một ô của lô gửi lên, ô 0 là tấm cả đàn
typedef AnhSlot = ({int slotIndex, Uint8List bytes});

// Đi qua extra vì lô ảnh chỉ sống trong lượt check-in
typedef KetQuaQuetArgs = ({CheckInArgs checkIn, String? batchId});
