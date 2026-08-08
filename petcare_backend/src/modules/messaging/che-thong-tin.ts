const SO_DIEN_THOAI = /(?:\+?84|0)(?:[\s.-]?\d){8,10}/g;
const DAY_SO_DAI = /\b\d{9,}\b/g;
const LIEN_KET = /\b(?:https?:\/\/|www\.)\S+/gi;

function cheSo(chuoi: string): string {
  const so = chuoi.replace(/\D/g, '');
  if (so.length < 6) return chuoi;
  const dau = so[0];
  const cuoi = so.slice(-2);
  return `${dau}●● ●●● ●●${cuoi}`;
}

export type KetQuaChe = { text: string; masked: boolean };

export function cheThongTinLienLac(text: string): KetQuaChe {
  let daChe = false;
  let ketQua = text.replace(SO_DIEN_THOAI, (m) => {
    if (m.replace(/\D/g, '').length < 9) return m;
    daChe = true;
    return cheSo(m);
  });
  ketQua = ketQua.replace(DAY_SO_DAI, (m) => {
    daChe = true;
    return cheSo(m);
  });
  ketQua = ketQua.replace(LIEN_KET, () => {
    daChe = true;
    return '[liên kết đã ẩn]';
  });
  return { text: ketQua, masked: daChe };
}
