import 'package:flutter/foundation.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_check_in.dart';

const int slotCaDan = 0;

enum KetLuanQuet { dat, khongDat, chuaXacMinhDuoc }

enum XuLySlot { diTiep, canTuXacNhan, chupLai }

enum ManQuetAi { dangQuet, aiDu, chuaQuaKiem, vanXaConLuot, hetLanChup }

KetLuanQuet _ketLuan(String? ma) => switch (ma) {
  'DAT' => KetLuanQuet.dat,
  'KHONG_DAT' => KetLuanQuet.khongDat,
  _ => KetLuanQuet.chuaXacMinhDuoc,
};

XuLySlot _xuLy(String? ma) => switch (ma) {
  'DI_TIEP' => XuLySlot.diTiep,
  'TU_XAC_NHAN' => XuLySlot.canTuXacNhan,
  'CHUP_LAI' => XuLySlot.chupLai,
  _ => _laLoi(ma),
};

XuLySlot _laLoi(String? ma) {
  debugPrint('Không hiểu mã xử lý slot của server: $ma');
  return XuLySlot.chupLai;
}

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
    required this.duocTuXacNhan,
    required this.luotNayCoTru,
    required this.loiHeThong,
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
    duocTuXacNhan: json['duocTuXacNhan'] == true,
    luotNayCoTru: json['luotNayCoTru'] != false,
    loiHeThong: json['loiHeThong'] == true,
    anhUrl: json['anhUrl'] as String?,
  );

  final int slotIndex;
  final KetLuanQuet ketLuan;
  final XuLySlot xuLy;
  final String reason;
  final String? ghiChu;
  final double doTinCay;

  final bool anhDuNet;

  final int soLanConLai;
  final bool daTuXacNhan;

  // Server chốt mốc mở van xả, app không tự suy từ bộ đếm (bộ luật mục 8)
  final bool duocTuXacNhan;

  final bool luotNayCoTru;

  // Lỗi nền tảng thì chụp lại cũng vô ích, màn phải nói khác và giấu bộ đếm đi
  final bool loiHeThong;

  final String? anhUrl;

  bool get xong => daTuXacNhan || xuLy != XuLySlot.chupLai;
  bool get canTuXacNhan => xuLy == XuLySlot.canTuXacNhan && !daTuXacNhan;

  bool get kyDuoc => duocTuXacNhan && !daTuXacNhan;

  bool get conLuot => soLanConLai > 0;

  int get phanTramTinCay => (doTinCay * 100).round();
}

class KetQuaLoQuet {
  const KetQuaLoQuet({
    required this.slots,
    required this.duDieuKienBatDau,
    this.batchId,
    this.dangQuet = false,
  });

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
  final bool duDieuKienBatDau;
  final String? batchId;
  final bool dangQuet;

  List<SlotQuet> get slotBe =>
      slots.where((s) => s.slotIndex != slotCaDan).toList();

  ManQuetAi get man {
    if (dangQuet) return ManQuetAi.dangQuet;
    final be = slotBe;
    if (be.isEmpty) return ManQuetAi.dangQuet;
    final chua = be.where((s) => !s.xong).toList();
    if (chua.isEmpty) return ManQuetAi.aiDu;
    final conLuot = chua.any((s) => s.conLuot);
    if (!chua.any((s) => s.kyDuoc)) return ManQuetAi.chuaQuaKiem;
    return conLuot ? ManQuetAi.vanXaConLuot : ManQuetAi.hetLanChup;
  }

  SlotQuet? get slotDangVuong {
    final chua = slotBe.where((s) => !s.xong).toList();
    if (chua.isEmpty) return null;
    return chua.firstWhere((s) => s.conLuot, orElse: () => chua.first);
  }

  List<SlotQuet> get slotCanTuXacNhan =>
      slotBe.where((s) => s.canTuXacNhan).toList();

  // Bộ đếm lượt tính chung cả đơn nên van xả cũng ký một lần cho mọi bé còn vướng
  List<SlotQuet> get slotKyDuoc => slotBe.where((s) => s.kyDuoc).toList();

  bool get batDauDuoc => duDieuKienBatDau && man == ManQuetAi.aiDu;
}

typedef AnhSlot = ({int slotIndex, Uint8List bytes});

typedef KetQuaQuetArgs = ({CheckInArgs checkIn, String? batchId});
