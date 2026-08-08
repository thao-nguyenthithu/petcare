import { BadRequestException } from '@nestjs/common';
import {
  canhDai,
  doKichThuoc,
  kieuTheoNoiDung,
} from '../src/modules/media/anh-kich-thuoc';
import {
  GIOI_HAN_ANH_BYTE,
  kiemTraAnh,
} from '../src/modules/media/image-upload';

// Tin `mimetype` client khai là để tệp HTML mang nhãn ảnh chạy trong trình duyệt chủ nuôi

function anhPng(rong = 1920, cao = 1080): Buffer {
  const b = Buffer.alloc(24);
  b.writeUInt32BE(0x89504e47, 0);
  b.writeUInt32BE(0x0d0a1a0a, 4);
  b.writeUInt32BE(13, 8);
  b.write('IHDR', 12, 'ascii');
  b.writeUInt32BE(rong, 16);
  b.writeUInt32BE(cao, 20);
  return b;
}

function anhJpeg(rong = 1920, cao = 1080): Buffer {
  const b = Buffer.alloc(20);
  b.writeUInt16BE(0xffd8, 0);
  b[2] = 0xff;
  b[3] = 0xc0;
  b.writeUInt16BE(17, 4);
  b[6] = 8;
  b.writeUInt16BE(cao, 7);
  b.writeUInt16BE(rong, 9);
  return b;
}

function anhWebp(rong = 1920, cao = 1080): Buffer {
  const b = Buffer.alloc(30);
  b.write('RIFF', 0, 'ascii');
  b.writeUInt32LE(22, 4);
  b.write('WEBP', 8, 'ascii');
  b.write('VP8 ', 12, 'ascii');
  b.writeUInt32LE(10, 16);
  b.writeUInt16LE(rong, 26);
  b.writeUInt16LE(cao, 28);
  return b;
}

const TEP_HTML = Buffer.from(
  '<html><script>document.location="http://ke-tan-cong"</script></html>',
);

describe('ca tấn công: tệp không phải ảnh mang nhãn ảnh', () => {
  it.each([['image/jpeg'], ['image/png'], ['image/webp'], ['image/jpg']])(
    'tệp HTML khai là %s vẫn bị từ chối',
    (khai) => {
      expect(() => kiemTraAnh({ buffer: TEP_HTML, mimetype: khai })).toThrow(
        BadRequestException,
      );
    },
  );

  it('mã lỗi nói đúng chuyện, không lộ là do đọc byte', () => {
    try {
      kiemTraAnh({ buffer: TEP_HTML, mimetype: 'image/jpeg' });
      throw new Error('phải ném');
    } catch (loi) {
      const ct = (loi as BadRequestException).getResponse();
      expect(ct).toMatchObject({ code: 'KIEU_ANH_KHONG_HO_TRO' });
    }
  });

  it('GIF và SVG không nằm trong whitelist nên bị từ chối', () => {
    const gif = Buffer.from('GIF89a' + '\0'.repeat(40));
    const svg = Buffer.from('<svg xmlns="http://www.w3.org/2000/svg"></svg>');
    for (const tep of [gif, svg]) {
      expect(() => kiemTraAnh({ buffer: tep, mimetype: 'image/png' })).toThrow(
        BadRequestException,
      );
    }
  });
});

describe('lời khai của client không còn quyết định gì', () => {
  it('ảnh thật khai sai kiểu vẫn nhận, contentType lấy theo nội dung', () => {
    expect(kiemTraAnh({ buffer: anhPng(), mimetype: 'image/jpeg' })).toEqual({
      contentType: 'image/png',
      duoi: 'png',
    });
    expect(kiemTraAnh({ buffer: anhJpeg(), mimetype: 'image/png' })).toEqual({
      contentType: 'image/jpeg',
      duoi: 'jpg',
    });
  });

  it('thiếu hẳn mimetype vẫn nhận vì kiểu đọc từ tệp', () => {
    expect(kiemTraAnh({ buffer: anhWebp() })).toEqual({
      contentType: 'image/webp',
      duoi: 'webp',
    });
  });

  it('đuôi tệp lưu lên kho suy từ nội dung, không từ tên tệp', () => {
    expect(kiemTraAnh({ buffer: anhJpeg(), mimetype: 'image/webp' }).duoi).toBe(
      'jpg',
    );
  });
});

describe('mọi kiểu trong whitelist đều nhận dạng được', () => {
  it.each([
    ['image/jpeg', anhJpeg()],
    ['image/png', anhPng()],
    ['image/webp', anhWebp()],
  ] as [string, Buffer][])('%s đọc ra đúng kiểu', (mong, tep) => {
    expect(kieuTheoNoiDung(tep)).toBe(mong);
  });

  it('đọc được cả kích thước để tầng AI hạ mức khi ảnh nhỏ', () => {
    for (const tep of [
      anhJpeg(1600, 900),
      anhPng(1600, 900),
      anhWebp(1600, 900),
    ]) {
      const kt = doKichThuoc(tep);
      expect(kt).not.toBeNull();
      expect(canhDai(kt!)).toBe(1600);
    }
  });
});

describe('hai cửa cũ vẫn đứng', () => {
  it('tệp rỗng bị từ chối', () => {
    expect(() => kiemTraAnh({ buffer: Buffer.alloc(0) })).toThrow(
      BadRequestException,
    );
    expect(() => kiemTraAnh({})).toThrow(BadRequestException);
  });

  it('vượt trần dung lượng bị từ chối trước khi đọc kiểu', () => {
    const qua = Buffer.concat([
      anhPng(),
      Buffer.alloc(GIOI_HAN_ANH_BYTE + 1 - 24),
    ]);
    try {
      kiemTraAnh({ buffer: qua, mimetype: 'image/png' });
      throw new Error('phải ném');
    } catch (loi) {
      const ct = (loi as BadRequestException).getResponse();
      expect(ct).toMatchObject({ code: 'ANH_QUA_LON' });
    }
  });
});
