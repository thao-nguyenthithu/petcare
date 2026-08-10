// Tham số vận hành máy chủ trả về, kèm mặc định
const int phiNenTangMacDinh = 15;
const int phiHuyMuonMacDinh = 50;
const int gioGiuTienMacDinh = 48;
const int rutToiThieuMacDinh = 50000;
const int luotRutMoiNgayMacDinh = 2;
const int canhCaoBiAnMacDinh = 4;
const int cuaSoPhatNgayMacDinh = 90;
const int tranTyLeHuyMacDinh = 20;
const int donToiThieuXetTyLeHuyMacDinh = 5;
const int banKinhTimToiDaKmMacDinh = 15;
const bool batVnpayMacDinh = false;
const bool batGeofenceMacDinh = true;

class CauHinhNghiepVu {
  const CauHinhNghiepVu({
    this.phiNenTangPhanTram = phiNenTangMacDinh,
    this.phiHuyMuonPhanTram = phiHuyMuonMacDinh,
    this.gioGiuTien = gioGiuTienMacDinh,
    this.rutToiThieu = rutToiThieuMacDinh,
    this.luotRutMoiNgay = luotRutMoiNgayMacDinh,
    this.canhCaoBiAn = canhCaoBiAnMacDinh,
    this.cuaSoPhatNgay = cuaSoPhatNgayMacDinh,
    this.tranTyLeHuy = tranTyLeHuyMacDinh,
    this.donToiThieuXetTyLeHuy = donToiThieuXetTyLeHuyMacDinh,
    this.banKinhTimToiDaKm = banKinhTimToiDaKmMacDinh,
    this.batVnpay = batVnpayMacDinh,
    this.batGeofence = batGeofenceMacDinh,
    this.emailHoTro,
    this.capNhatLuc,
  });

  // Bản mặc định, dùng khi chưa nạp xong hoặc gọi hỏng
  static const CauHinhNghiepVu macDinh = CauHinhNghiepVu();

  final int phiNenTangPhanTram;
  final int phiHuyMuonPhanTram;
  final int gioGiuTien;
  final int rutToiThieu;
  final int luotRutMoiNgay;
  final int canhCaoBiAn;
  final int cuaSoPhatNgay;
  final int tranTyLeHuy;
  final int donToiThieuXetTyLeHuy;
  final int banKinhTimToiDaKm;

  // Tắt thì đơn đi qua cổng giả lập
  final bool batVnpay;
  final bool batGeofence;

  final String? emailHoTro;

  final DateTime? capNhatLuc;

  factory CauHinhNghiepVu.fromJson(Map<String, dynamic> json) {
    final tho = json['thamSo'];
    final thamSo = tho is Map
        ? Map<String, dynamic>.from(tho)
        : const <String, dynamic>{};
    return CauHinhNghiepVu(
      phiNenTangPhanTram: _so(
        thamSo,
        'platform.fee.percent',
        phiNenTangMacDinh,
      ),
      phiHuyMuonPhanTram: _so(thamSo, 'cancel.fee.percent', phiHuyMuonMacDinh),
      gioGiuTien: _so(thamSo, 'escrow.hours', gioGiuTienMacDinh),
      rutToiThieu: _so(thamSo, 'withdraw.min', rutToiThieuMacDinh),
      luotRutMoiNgay: _so(thamSo, 'withdraw.per_day', luotRutMoiNgayMacDinh),
      canhCaoBiAn: _so(thamSo, 'penalty.warnings_to_hide', canhCaoBiAnMacDinh),
      cuaSoPhatNgay: _so(thamSo, 'penalty.window_days', cuaSoPhatNgayMacDinh),
      tranTyLeHuy: _so(thamSo, 'penalty.cancel_rate_max', tranTyLeHuyMacDinh),
      donToiThieuXetTyLeHuy: _so(
        thamSo,
        'penalty.min_orders',
        donToiThieuXetTyLeHuyMacDinh,
      ),
      banKinhTimToiDaKm: _so(
        thamSo,
        'search.radius_max_km',
        banKinhTimToiDaKmMacDinh,
      ),
      batVnpay: _cong(thamSo, 'payment.vnpay.enabled', batVnpayMacDinh),
      batGeofence: _cong(
        thamSo,
        'checkin.geofence.enabled',
        batGeofenceMacDinh,
      ),
      emailHoTro: json['lienHe'] is Map
          ? (json['lienHe'] as Map)['email'] as String?
          : null,
      capNhatLuc: DateTime.tryParse(json['capNhatLuc'] as String? ?? ''),
    );
  }

  // Thiếu khoá, sai kiểu hoặc số không dương đều rơi về mặc định
  static int _so(Map<String, dynamic> thamSo, String khoa, int macDinh) {
    final gt = thamSo[khoa];
    final so = gt is num ? gt.toInt() : int.tryParse('$gt');
    return so == null || so <= 0 ? macDinh : so;
  }

  static bool _cong(Map<String, dynamic> thamSo, String khoa, bool macDinh) {
    final gt = thamSo[khoa];
    if (gt is bool) return gt;
    if (gt is String) return gt == 'true';
    return macDinh;
  }
}
