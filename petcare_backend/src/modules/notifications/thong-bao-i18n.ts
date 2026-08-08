export type ThamSoTin = Record<string, string | number>;

const VI = {
  tbHoSoSapBiAnTieuDe: 'Hồ sơ của bạn đang có cảnh cáo',
  tbHoSoSapBiAnNoiDung:
    'Bạn đang có {soCanhCao} cảnh cáo, thêm {conLai} lần nữa là hồ sơ bị ẩn khỏi tìm kiếm.',
  tbHoSoBiKhoaTieuDe: 'Hồ sơ đã bị khoá',
  tbHoSoBiKhoaNoiDung:
    'Hồ sơ của bạn đã bị khoá do tái phạm nhiều lần. Liên hệ bộ phận hỗ trợ nếu bạn cho rằng có nhầm lẫn.',
  tbHoSoTamAnTieuDe: 'Hồ sơ tạm bị ẩn khỏi tìm kiếm',
  tbHoSoTamAnNoiDung:
    'Hồ sơ của bạn tạm ẩn {soNgay} ngày nên không nhận được đơn mới. Các đơn đã nhận vẫn phải hoàn thành, hết hạn ẩn hồ sơ tự hiện lại.',
  tbPhongBenhToiHanTieuDe: 'Sắp tới hạn {tenHangMuc} của {tenBe}',
  tbPhongBenhToiHanNoiDung:
    'Còn {conMayNgay} ngày nữa là tới hạn {tenHangMuc} của {tenBe}. Đặt lịch thú y sớm cho kịp.',
  tbPhongBenhNhacCuoiNoiDung:
    '{tenHangMuc} của {tenBe} tới hạn vào ngày mai. Đây là lời nhắc cuối.',

  tbDonMoiTieuDe: 'Bạn có đơn mới',
  tbDonMoiNoiDung:
    '{tenDichVu} · {code}. Nhận đơn trước khi hết hạn để không bị bỏ lỡ.',
  tbDaNhanDonTieuDe: 'Người chăm đã nhận đơn',
  tbDaNhanDonNoiDung: '{tenNcc} sẽ phục vụ đơn {code}.',
  tbTuChoiDonTieuDe: 'Người chăm đã từ chối đơn',
  tbTuChoiDonNoiDung:
    'Đơn {code} chưa có người nhận. Bạn có thể chọn người chăm khác.',
  tbDaXuatPhatTieuDe: 'Người chăm đang trên đường',
  tbDaXuatPhatNoiDung: '{tenNcc} đã xuất phát tới điểm hẹn của đơn {code}.',
  tbDaToiNoiTieuDe: 'Người chăm đã tới điểm hẹn',
  tbDaToiNoiNoiDung: 'Đơn {code} đang chờ bạn giao bé.',
  tbSapHetGioGiaoBeTieuDe: 'Còn 5 phút để giao bé',
  tbSapHetGioGiaoBeNoiDung:
    'Người chăm vẫn đang chờ ở điểm hẹn của đơn {code}. Quá giờ là đơn bị tính phí {phanTramPhi}%.',
  tbDaBatDauTieuDe: 'Đã bắt đầu dịch vụ',
  tbDaBatDauNoiDung: '{tenDichVu} của đơn {code} đang diễn ra.',
  tbChoXacNhanTieuDe: 'Dịch vụ đã hoàn thành, chờ bạn xác nhận',
  tbChoXacNhanNoiDung:
    'Xác nhận đơn {code} trong {gioGiuTien} giờ, quá hạn hệ thống tự chốt.',
  tbAnhMoiTieuDe: 'Có ảnh mới từ người chăm',
  tbAnhMoiNoiDung: 'Người chăm vừa gửi ảnh cho đơn {code}.',
  tbNccHuyDonTieuDe: 'Người chăm đã huỷ đơn',
  tbNccHuyDonNoiDung:
    'Đơn {code} đã huỷ, bạn không mất phí và tiền sẽ được hoàn về nguồn đã thanh toán. Bạn có thể tìm người chăm khác cho khung giờ này.',
  tbNccKhongTiepNhanTieuDe: 'Người chăm không thể tiếp nhận đơn',
  tbNccKhongTiepNhanNoiDung:
    'Người chăm gặp sự cố trên đường nên đơn {code} đã dừng. Bạn không mất phí, tiền sẽ được hoàn về nguồn đã thanh toán.',
  tbThieuDungCuChuNuoiTieuDe: 'Đơn đã huỷ vì thiếu rọ mõm hoặc dây xích',
  tbThieuDungCuChuNuoiNoiDung:
    'Hết thời gian chờ mà bé vẫn chưa đủ rọ mõm hoặc dây xích nên đơn {code} đã huỷ. Phí huỷ {phiHuy}, hoàn {hoanLai} về nguồn đã thanh toán.',
  tbThieuDungCuNccTieuDe: 'Đơn đã huỷ, bạn được nhận phí huỷ',
  tbThieuDungCuNccNoiDung:
    'Đơn {code} huỷ do thiếu dụng cụ. Bạn nhận {nccNhan} từ phí huỷ, đơn này không tính vào tỷ lệ huỷ của bạn.',
  tbVangMatChuNuoiTieuDe: 'Người chăm báo bạn không có mặt',
  tbVangMatChuNuoiNoiDung:
    'Đơn {code} đã huỷ sau khi người chăm chờ đủ giờ tại điểm hẹn. Đơn tính như huỷ muộn: phí {phiHuy}, phần còn lại hoàn về nguồn đã thanh toán. Bạn có {soGioPhanDoi} giờ để phản đối kèm bằng chứng.',
  tbVangMatNccTieuDe: 'Đã ghi nhận chủ nuôi vắng mặt',
  tbVangMatNccNoiDung:
    'Đơn {code} đã khép. {nccNhan} tạm giữ {soGioPhanDoi} giờ chờ chủ nuôi phản đối rồi vào ví của bạn.',
  tbQuaGioHenTieuDe: 'Đơn đã huỷ vì quá giờ hẹn',
  tbQuaGioHenChuNuoiNoiDung:
    'Quá giờ hẹn mà đơn {code} vẫn chưa bắt đầu nên hệ thống đã khép lại. Bạn không mất phí, tiền sẽ được hoàn về nguồn đã thanh toán.',
  tbQuaGioHenNccNoiDung:
    'Đơn {code} quá giờ hẹn mà chưa bắt đầu nên hệ thống đã khép lại ở mức không tính phí bên nào. Đơn này không tính vào tỷ lệ huỷ của bạn.',
  tbKetThucSomChuNuoiTieuDe: 'Đã chốt kết thúc sớm kỳ trông giữ',
  tbKetThucSomChuNuoiNoiDung:
    'Đơn {code} đã đổi ngày trả. Số tiền hoàn {hoanLai} sẽ về nguồn đã thanh toán.',
  tbKetThucSomNccTieuDe: 'Chủ nuôi kết thúc sớm kỳ trông giữ',
  tbKetThucSomNccNoiDung:
    'Đơn {code} đã đổi ngày trả bé. Những đêm bị cắt trong 7 ngày tới vẫn tính nửa tiền cho bạn.',
  tbChuNuoiHuyDonTieuDe: 'Chủ nuôi đã huỷ đơn',
  tbChuNuoiHuyDonNoiDung:
    'Đơn {code} vừa bị huỷ, lịch của bạn đã được trả lại.',
  tbQuaHanNhanChuNuoiTieuDe: 'Đơn đã huỷ vì không có người nhận',
  tbQuaHanNhanChuNuoiNoiDung:
    'Đơn {code} hết hạn chờ mà chưa có người chăm nhận, tiền sẽ được hoàn về cho bạn. Bạn có thể đặt lại với người chăm khác.',
  tbQuaHanNhanNccTieuDe: 'Đơn đã hết hạn nhận',
  tbQuaHanNhanNccNoiDung:
    'Đơn {code} quá hạn trả lời nên hệ thống đã huỷ, lịch của bạn được trả lại.',
  tbNccChuaToiChuNuoiTieuDe: 'Đơn đã huỷ vì người chăm không tới',
  tbNccChuaToiChuNuoiNoiDung:
    'Quá giờ hẹn mà người chăm chưa tới điểm đón nên đơn {code} đã huỷ. Bạn không mất phí, tiền sẽ được hoàn về nguồn đã thanh toán.',
  tbNccChuaToiNccTieuDe: 'Đơn đã huỷ vì bạn chưa tới điểm đón',
  tbNccChuaToiNccNoiDung:
    'Đơn {code} đã huỷ do quá giờ hẹn mà bạn chưa xác thực vị trí tại điểm đón. Lần huỷ này được tính cho bạn.',
  tbNccBanChuNuoiTieuDe: 'Đơn đã huỷ vì người chăm bận khung giờ này',
  tbNccBanChuNuoiNoiDung:
    'Đơn {code} đã huỷ do người chăm nhận một đơn khác trùng khung giờ, tiền sẽ được hoàn về cho bạn. Bạn có thể đặt với người chăm khác.',
  tbNccBanNccTieuDe: 'Đơn chờ đã tự huỷ',
  tbNccBanNccNoiDung:
    'Đơn {code} tự huỷ vì bạn đã nhận một đơn khác trùng khung giờ.',
  tbDanhGiaMoiTieuDe: 'Bạn có đánh giá mới',
  tbDanhGiaMoiNoiDung: 'Chủ nuôi vừa chấm {soSao} sao cho một đơn của bạn.',

  tbAdminHuyDonTieuDe: 'Đơn đã bị huỷ',
  tbAdminHuyDonChuaTraTienNoiDung:
    'Đơn {code} đã được quản trị viên huỷ. Đơn chưa trả tiền nên không có khoản nào bị trừ. Lý do: {lyDo}',
  tbAdminHuyDonHoanDuNoiDung:
    'Đơn {code} đã được quản trị viên huỷ. Bạn được hoàn đủ tiền, lệnh hoàn đã gửi đi. Lý do: {lyDo}',
  tbAdminHuyDonNccNoiDung:
    'Đơn {code} đã được quản trị viên huỷ. Lần huỷ này không tính vào tỷ lệ huỷ của bạn. Lý do: {lyDo}',
  tbKhieuNaiKetLuanTieuDe: 'Khiếu nại đã có kết luận',
  tbKhieuNaiCoHoanNoiDung:
    'Đơn {code}: {ketLuan}. Khoản hoàn cho chủ nuôi: {soTien}. Lý do: {lyDo}',
  tbKhieuNaiKhongHoanNoiDung:
    'Đơn {code}: {ketLuan}. Khiếu nại không được chấp nhận nên không có khoản hoàn nào. Lý do: {lyDo}',
} satisfies Record<string, string>;

// Thiếu khoá thì rơi về tiếng Việt
const EN: Partial<Record<KhoaTin, string>> = {};

export type KhoaTin = keyof typeof VI;

const BANG: Record<string, Partial<Record<KhoaTin, string>>> = {
  vi: VI,
  en: EN,
};

export function dungCau(
  khoa: KhoaTin,
  thamSo?: ThamSoTin,
  locale = 'vi',
): string {
  const mau = BANG[locale]?.[khoa] ?? VI[khoa];
  if (!thamSo) return mau;
  return mau.replace(/\{(\w+)\}/g, (nguyen, ten: string) =>
    ten in thamSo ? String(thamSo[ten]) : nguyen,
  );
}
