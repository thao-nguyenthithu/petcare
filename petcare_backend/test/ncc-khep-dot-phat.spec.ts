import { mocDemPhat } from '../src/modules/bookings/sitter-penalty-rules';

// Bộ luật mục 6: mỗi lần tạm ẩn khép lại một đợt, vi phạm cũ không tính cho lần ẩn sau

const MOT_NGAY_MS = 24 * 3600_000;
const BAY_GIO = new Date('2026-08-07T10:00:00+07:00').getTime();
const CUA_SO_NGAY = 90;

function ngayTruoc(so: number) {
  return new Date(BAY_GIO - so * MOT_NGAY_MS);
}

describe('mocDemPhat', () => {
  it('chưa từng bị ẩn thì đếm trọn cửa sổ', () => {
    const moc = mocDemPhat(BAY_GIO, CUA_SO_NGAY, null);
    expect(moc.getTime()).toBe(BAY_GIO - CUA_SO_NGAY * MOT_NGAY_MS);
  });

  // Đây là quy tắc mới: cảnh cáo đã dùng để ẩn không được tính lại
  it('vừa bị ẩn thì đếm lại từ lúc bị ẩn', () => {
    const lanAn = ngayTruoc(3);
    expect(mocDemPhat(BAY_GIO, CUA_SO_NGAY, lanAn).getTime()).toBe(
      lanAn.getTime(),
    );
  });

  it('lần ẩn cũ hơn cửa sổ thì cửa sổ vẫn thắng', () => {
    const lanAn = ngayTruoc(200);
    expect(mocDemPhat(BAY_GIO, CUA_SO_NGAY, lanAn).getTime()).toBe(
      BAY_GIO - CUA_SO_NGAY * MOT_NGAY_MS,
    );
  });

  it('lần ẩn đúng biên cửa sổ thì hai mốc trùng nhau', () => {
    const lanAn = ngayTruoc(CUA_SO_NGAY);
    expect(mocDemPhat(BAY_GIO, CUA_SO_NGAY, lanAn).getTime()).toBe(
      lanAn.getTime(),
    );
  });

  // Cảnh cáo và lệnh ẩn cùng transaction thì trùng mốc, phép lọc phải là gt không gte
  it('cảnh cáo sinh cùng lúc với lệnh ẩn không được tính cho đợt sau', () => {
    const lucAn = ngayTruoc(5);
    const moc = mocDemPhat(BAY_GIO, CUA_SO_NGAY, lucAn);
    const canhCaoCu = [ngayTruoc(60), ngayTruoc(40), ngayTruoc(20), lucAn];
    const canhCaoMoi = ngayTruoc(1);

    expect(canhCaoCu.filter((d) => d > moc)).toHaveLength(0);
    expect(canhCaoMoi > moc).toBe(true);
  });

  // Mốc khép đợt vẫn lấy bản HIDE đã WAIVED, không thì cảnh cáo cũ bị moi ra phạt lại
  it('mốc lấy theo bản ẩn gần nhất chứ không theo lần ẩn đầu tiên', () => {
    const anLanDau = ngayTruoc(50);
    const anGanNhat = ngayTruoc(4);
    expect(mocDemPhat(BAY_GIO, CUA_SO_NGAY, anGanNhat).getTime()).toBe(
      anGanNhat.getTime(),
    );
    expect(mocDemPhat(BAY_GIO, CUA_SO_NGAY, anLanDau).getTime()).toBe(
      anLanDau.getTime(),
    );
  });
});
