export type KichThuocAnh = { rong: number; cao: number };

export function doKichThuoc(bytes: Buffer): KichThuocAnh | null {
  return docPng(bytes) ?? docWebp(bytes) ?? docJpeg(bytes);
}

export function canhDai(kt: KichThuocAnh): number {
  return Math.max(kt.rong, kt.cao);
}

export function kieuTheoNoiDung(bytes: Buffer): string | null {
  if (docPng(bytes)) return 'image/png';
  if (docWebp(bytes)) return 'image/webp';
  if (docJpeg(bytes)) return 'image/jpeg';
  return null;
}

function docPng(b: Buffer): KichThuocAnh | null {
  if (b.length < 24) return null;
  if (b.readUInt32BE(0) !== 0x89504e47) return null;
  if (b.toString('ascii', 12, 16) !== 'IHDR') return null;
  return { rong: b.readUInt32BE(16), cao: b.readUInt32BE(20) };
}

function docWebp(b: Buffer): KichThuocAnh | null {
  if (b.length < 30) return null;
  if (b.toString('ascii', 0, 4) !== 'RIFF') return null;
  if (b.toString('ascii', 8, 12) !== 'WEBP') return null;
  const loai = b.toString('ascii', 12, 16);
  if (loai === 'VP8X') {
    return {
      rong: (b.readUIntLE(24, 3) & 0xffffff) + 1,
      cao: (b.readUIntLE(27, 3) & 0xffffff) + 1,
    };
  }
  if (loai === 'VP8 ') {
    return {
      rong: b.readUInt16LE(26) & 0x3fff,
      cao: b.readUInt16LE(28) & 0x3fff,
    };
  }
  if (loai === 'VP8L') {
    const bit = b.readUInt32LE(21);
    return { rong: (bit & 0x3fff) + 1, cao: ((bit >> 14) & 0x3fff) + 1 };
  }
  return null;
}

function laKhoiKichThuoc(marker: number): boolean {
  if (marker < 0xc0 || marker > 0xcf) return false;
  return marker !== 0xc4 && marker !== 0xc8 && marker !== 0xcc;
}

function docJpeg(b: Buffer): KichThuocAnh | null {
  if (b.length < 4 || b.readUInt16BE(0) !== 0xffd8) return null;
  let i = 2;
  while (i + 9 < b.length) {
    if (b[i] !== 0xff) {
      i++;
      continue;
    }
    const marker = b[i + 1];
    if (
      marker === 0xff ||
      marker === 0x01 ||
      (marker >= 0xd0 && marker <= 0xd9)
    ) {
      i += 2;
      continue;
    }
    if (laKhoiKichThuoc(marker)) {
      return { cao: b.readUInt16BE(i + 5), rong: b.readUInt16BE(i + 7) };
    }
    const dai = b.readUInt16BE(i + 2);
    if (dai < 2) return null;
    i += 2 + dai;
  }
  return null;
}
