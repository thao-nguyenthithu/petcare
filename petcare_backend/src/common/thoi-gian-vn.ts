// Ngày thuần dạng YYYY-MM-DD, hiểu theo giờ Việt Nam
export const MAU_NGAY = /^\d{4}-\d{2}-\d{2}$/;

// Giờ trong ngày dạng HH:mm
export const MAU_GIO = /^([01]\d|2[0-3]):[0-5]\d$/;

// Giờ đóng cửa nhận thêm 24:00 nghĩa là hết ngày 
export const MAU_GIO_DONG = /^([01]\d|2[0-3]):[0-5]\d$|^24:00$/;

// Lệch múi giờ Việt Nam so với UTC
export const LECH_VN_MS = 7 * 60 * 60 * 1000;
export const MOT_NGAY_MS = 24 * 60 * 60 * 1000;
export const MOT_GIO_MS = 60 * 60 * 1000;
export const MOT_PHUT_MS = 60 * 1000;

export function dauNgayVn(ngay: string): Date {
  return new Date(`${ngay}T00:00:00.000+07:00`);
}

export function mocVn(ngay: string, gio: string): Date {
  return new Date(`${ngay}T${gio}:00.000+07:00`);
}

export function ngayDb(ngay: string): Date {
  return new Date(`${ngay}T00:00:00.000Z`);
}

export function khoaTuNgayDb(d: Date): string {
  return d.toISOString().slice(0, 10);
}

export function khoaNgayVn(d: Date): string {
  return new Date(d.getTime() + LECH_VN_MS).toISOString().slice(0, 10);
}

export function ngayThangVn(d: Date): string {
  const khoa = khoaNgayVn(d);
  return `${khoa.slice(8, 10)}/${khoa.slice(5, 7)}`;
}

// HH:mm của một mốc thời gian, tính theo giờ VN
export function gioVn(d: Date): string {
  return new Date(d.getTime() + LECH_VN_MS).toISOString().slice(11, 16);
}

export function themNgay(khoa: string, so: number): string {
  return khoaNgayVn(new Date(dauNgayVn(khoa).getTime() + so * MOT_NGAY_MS));
}

export function soNgayLech(tu: string, den: string): number {
  return Math.round(
    (dauNgayVn(den).getTime() - dauNgayVn(tu).getTime()) / MOT_NGAY_MS,
  );
}

export function homNayVn(): string {
  return khoaNgayVn(new Date());
}

// Thứ trong tuần theo giờ VN
export function thuTrongTuanVn(ngay: string): number {
  const thu = new Date(dauNgayVn(ngay).getTime() + LECH_VN_MS).getUTCDay();
  return thu === 0 ? 7 : thu;
}

export function truocHoacBang(a: string, b: string): boolean {
  return a.localeCompare(b) <= 0;
}

export function phutTrongNgay(gio: string): number {
  const [h, m] = gio.split(':');
  return Number(h) * 60 + Number(m);
}

export function gioTuPhut(phut: number): string {
  const trongNgay = ((phut % 1440) + 1440) % 1440;
  const h = Math.floor(trongNgay / 60)
    .toString()
    .padStart(2, '0');
  const m = (trongNgay % 60).toString().padStart(2, '0');
  return `${h}:${m}`;
}

export function soTuoi(ngaySinh: Date, moc: Date = new Date()): number {
  const sinh = khoaNgayVn(ngaySinh);
  const nay = khoaNgayVn(moc);
  const [ns, ts, ds] = sinh.split('-').map(Number);
  const [nn, tn, dn] = nay.split('-').map(Number);
  const chuaToiSinhNhat = tn < ts || (tn === ts && dn < ds);
  return nn - ns - (chuaToiSinhNhat ? 1 : 0);
}
