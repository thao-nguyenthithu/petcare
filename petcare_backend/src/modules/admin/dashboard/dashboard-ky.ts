import { LECH_VN_MS } from '../../../common/thoi-gian-vn';

export type Khoang = { tu: Date; den: Date };

// Mốc 00:00 giờ VN ngày mùng 1, lui bằng số tháng lùi lại
export function dauThangVn(moc: Date, lui = 0): Date {
  const vn = new Date(moc.getTime() + LECH_VN_MS);
  const dau = Date.UTC(vn.getUTCFullYear(), vn.getUTCMonth() + lui, 1);
  return new Date(dau - LECH_VN_MS);
}

// Kỳ trước cắt đúng phần đã trôi của tháng này: so cả tháng với nửa tháng là tụt giả
export function haiKy(bayGio: Date): { nay: Khoang; truoc: Khoang } {
  const nayTu = dauThangVn(bayGio);
  const truocTu = dauThangVn(bayGio, -1);
  const daTroi = bayGio.getTime() - nayTu.getTime();
  const truocDen = Math.min(truocTu.getTime() + daTroi, nayTu.getTime());
  return {
    nay: { tu: nayTu, den: bayGio },
    truoc: { tu: truocTu, den: new Date(truocDen) },
  };
}

// Kỳ trước bằng 0 thì trả null: 0 đọc thành "không đổi", thật ra là chưa có gì để so
export function lechPhanTram(nay: number, truoc: number): number | null {
  if (truoc <= 0) return null;
  return Math.round(((nay - truoc) / truoc) * 100);
}

// Khoá YYYY-MM theo giờ VN, dùng để ghép kết quả gộp tháng vào đủ số cột
export function khoaThangVn(moc: Date): string {
  return new Date(moc.getTime() + LECH_VN_MS).toISOString().slice(0, 7);
}

// Dãy khoá tháng liên tiếp, phần tử cuối là tháng đang chạy
export function dayKhoaThang(bayGio: Date, so: number): string[] {
  const ds: string[] = [];
  for (let i = so - 1; i >= 0; i -= 1) {
    ds.push(khoaThangVn(dauThangVn(bayGio, -i)));
  }
  return ds;
}
