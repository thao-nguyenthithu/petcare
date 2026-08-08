import { PrismaService } from '../src/prisma/prisma.service';
import {
  BUCKET_ANH_CHAT,
  BUCKET_ANH_DON,
  GIAY_KY_ANH,
  duongDanAnh,
  khoCuaAnh,
} from '../src/modules/media/anh-duong-dan';
import { AnhKyService } from '../src/modules/media/anh-ky.service';
import { AnhTaiLenService } from '../src/modules/media/anh-tai-len.service';
import { SupabaseService } from '../src/modules/media/supabase.service';
import { type UploadedImage } from '../src/modules/media/image-upload';
import { DisputeService } from '../src/modules/wallet/dispute.service';
import { AdminEvidenceReadService } from '../src/modules/admin/evidence/admin-evidence-read.service';
import { anhKyGia } from './anh-ky-gia';

const CHU_NUOI = 'u-chu-nuoi';
const NGUOI_CHAM = 'u-ncc';
const NGUOI_LA = 'u-nguoi-la';

// PNG thật: phép suy kiểu đọc byte đầu tệp nên chữ ký giả là bị chặn ngay
function anhPng(): UploadedImage {
  const buffer = Buffer.alloc(24);
  buffer.writeUInt32BE(0x89504e47, 0);
  buffer.writeUInt32BE(0x0d0a1a0a, 4);
  buffer.writeUInt32BE(13, 8);
  buffer.write('IHDR', 12, 'ascii');
  buffer.writeUInt32BE(1200, 16);
  buffer.writeUInt32BE(900, 20);
  return { buffer, mimetype: 'image/png', size: buffer.length };
}

function khoGia() {
  const daTao: Array<{ bucket: string; congKhai: boolean }> = [];
  const daSua: Array<{ bucket: string; congKhai: boolean }> = [];
  const daDay: Array<{ bucket: string; path: string; contentType: string }> =
    [];
  const luotKy: Array<{ kho: string; duong: string[]; giay: number }> = [];
  const client = {
    storage: {
      createBucket: (bucket: string, opt: { public: boolean }) => {
        daTao.push({ bucket, congKhai: opt.public });
        return Promise.resolve({ error: { message: 'Bucket already exists' } });
      },
      updateBucket: (bucket: string, opt: { public: boolean }) => {
        daSua.push({ bucket, congKhai: opt.public });
        return Promise.resolve({ error: null });
      },
      from: (kho: string) => ({
        createSignedUrls: (duong: string[], giay: number) => {
          luotKy.push({ kho, duong, giay });
          return Promise.resolve({
            data: duong.map((p) => ({ signedUrl: `https://ky/${p}?token=t` })),
            error: null,
          });
        },
      }),
    },
  };
  const supabase = {
    getClient: () => client,
    uploadFile: (bucket: string, path: string, _b: Buffer, ct: string) => {
      daDay.push({ bucket, path, contentType: ct });
      return Promise.resolve(path);
    },
    ensurePrivateBucket: (bucket: string) => {
      daTao.push({ bucket, congKhai: false });
      return Promise.resolve();
    },
  };
  return {
    daTao,
    daSua,
    daDay,
    luotKy,
    supabase: supabase as unknown as SupabaseService,
    client,
  };
}

describe('Đường ghi lưu path chứ không lưu URL', () => {
  it('trả về path của kho, không trả URL công khai', async () => {
    const kho = khoGia();
    const service = new AnhTaiLenService(kho.supabase);

    const ra = await service.dayLen(BUCKET_ANH_DON, 'don-1', [
      anhPng(),
      anhPng(),
    ]);

    expect(ra).toHaveLength(2);
    for (const duong of ra) {
      expect(duong).not.toMatch(/^https?:\/\//);
      expect(duong).toMatch(/^don-1\/[0-9a-f-]+\.png$/);
    }
  });

  it('tạo kho ở chế độ riêng tư, không phải công khai', async () => {
    const kho = khoGia();

    await new AnhTaiLenService(kho.supabase).dayLen(BUCKET_ANH_DON, 'don-1', [
      anhPng(),
    ]);

    expect(kho.daTao).toEqual([{ bucket: BUCKET_ANH_DON, congKhai: false }]);
  });

  it('kho lỡ tạo công khai từ trước thì phải hạ cờ xuống riêng tư', async () => {
    const kho = khoGia();
    const that = new SupabaseService({
      get: (k: string) => (k === 'SUPABASE_URL' ? 'https://kho' : 'khoa'),
    } as never);
    (that as unknown as { client: unknown }).client = kho.client;

    await that.ensurePrivateBucket(BUCKET_ANH_DON);

    expect(kho.daSua).toEqual([{ bucket: BUCKET_ANH_DON, congKhai: false }]);
  });

  it('vẫn ép contentType theo byte đầu tệp, không tin lời khai client', async () => {
    const kho = khoGia();
    const doiTra = { ...anhPng(), mimetype: 'text/html' };

    await new AnhTaiLenService(kho.supabase).dayLen(BUCKET_ANH_DON, 'don-1', [
      doiTra,
    ]);

    expect(kho.daDay[0].contentType).toBe('image/png');
    expect(kho.daDay[0].path).toMatch(/\.png$/);
  });

  it('tệp không phải ảnh bị chặn trước khi chạm kho', async () => {
    const kho = khoGia();
    const html: UploadedImage = {
      buffer: Buffer.from('<html>x</html>'),
      mimetype: 'image/png',
    };

    await expect(
      new AnhTaiLenService(kho.supabase).dayLen(BUCKET_ANH_DON, 'don-1', [
        html,
      ]),
    ).rejects.toMatchObject({ response: { code: 'KIEU_ANH_KHONG_HO_TRO' } });
    expect(kho.daDay).toHaveLength(0);
  });
});

describe('Đường đọc ký một lượt cho nhiều ảnh', () => {
  it('nhiều path đi trong ĐÚNG MỘT lượt gọi kho', async () => {
    const kho = khoGia();
    const ky = new AnhKyService(kho.supabase);

    const ra = await ky.kyLo(['don-1/a.jpg', 'don-1/b.jpg', 'don-2/c.jpg']);

    expect(kho.luotKy).toHaveLength(1);
    expect(kho.luotKy[0].duong).toEqual([
      'don-1/a.jpg',
      'don-1/b.jpg',
      'don-2/c.jpg',
    ]);
    expect(ra.get('don-1/b.jpg')).toBe('https://ky/don-1/b.jpg?token=t');
  });

  it('ký theo hạn khai một chỗ duy nhất', async () => {
    const kho = khoGia();

    await new AnhKyService(kho.supabase).kyLo(['don-1/a.jpg']);

    expect(kho.luotKy[0].giay).toBe(GIAY_KY_ANH);
  });

  it('ảnh trùng nhau chỉ ký một lần, mảng ra vẫn đủ và đúng thứ tự', async () => {
    const kho = khoGia();

    const ra = await new AnhKyService(kho.supabase).kyMang([
      'don-1/a.jpg',
      'don-1/b.jpg',
      'don-1/a.jpg',
    ]);

    expect(kho.luotKy).toHaveLength(1);
    expect(kho.luotKy[0].duong).toEqual(['don-1/a.jpg', 'don-1/b.jpg']);
    expect(ra).toEqual([
      'https://ky/don-1/a.jpg?token=t',
      'https://ky/don-1/b.jpg?token=t',
      'https://ky/don-1/a.jpg?token=t',
    ]);
  });

  it('không có ảnh thì không gọi kho lượt nào', async () => {
    const kho = khoGia();

    await new AnhKyService(kho.supabase).kyLo([null, undefined, '']);

    expect(kho.luotKy).toHaveLength(0);
  });

  it('kho lỗi thì trả rỗng chứ không ném vỡ cả màn', async () => {
    const kho = khoGia();
    kho.client.storage.from = () =>
      ({
        createSignedUrls: () =>
          Promise.resolve({ data: null, error: { message: 'kho sap' } }),
      }) as never;

    const ra = await new AnhKyService(kho.supabase).kyLo(['don-1/a.jpg']);

    expect(ra.size).toBe(0);
  });
});

describe('Ảnh cũ dạng URL tuyệt đối vẫn đọc được', () => {
  const CU =
    'https://abc.supabase.co/storage/v1/object/public/booking-media/don-9/cu.jpg';

  it('cắt đúng path từ URL công khai cũ', () => {
    expect(duongDanAnh(CU)).toBe('don-9/cu.jpg');
  });

  it('URL cũ gửi đi ký dưới dạng path, tra ngược vẫn ra bản ký', async () => {
    const kho = khoGia();

    const ra = await new AnhKyService(kho.supabase).kyMang([CU]);

    expect(kho.luotKy[0].duong).toEqual(['don-9/cu.jpg']);
    expect(ra).toEqual(['https://ky/don-9/cu.jpg?token=t']);
  });

  it('ảnh kho công khai không dính đến đơn thì để nguyên, không ký', async () => {
    const kho = khoGia();
    const avatar =
      'https://abc.supabase.co/storage/v1/object/public/avatars/a.jpg';

    const ra = await new AnhKyService(kho.supabase).kyMang([avatar]);

    expect(khoCuaAnh(avatar)).toBeNull();
    expect(kho.luotKy).toHaveLength(0);
    expect(ra).toEqual([avatar]);
  });

  it('URL cũ của kho chat ký đúng kho chat chứ không ký sang kho đơn', async () => {
    const kho = khoGia();
    const chat =
      'https://abc.supabase.co/storage/v1/object/public/chat-media/hoi-1/a.jpg';

    await new AnhKyService(kho.supabase).kyMang([chat]);

    expect(kho.luotKy).toEqual([
      { kho: BUCKET_ANH_CHAT, duong: ['hoi-1/a.jpg'], giay: GIAY_KY_ANH },
    ]);
  });
});

// Danh sách ảnh bằng chứng: một trang nhiều ảnh vẫn phải là một lượt ký
function dungDanhSachAnh(soAnh: number) {
  const dong = Array.from({ length: soAnh }, (_, i) => ({
    id: `sp-${i}`,
    url: `don-1/anh-${i}.jpg`,
    phase: 'CHECK_IN',
    anhDoDung: false,
    anhVanXa: false,
    photoLat: null,
    photoLng: null,
    takenAt: new Date(),
    aiConfidenceScore: null,
    aiPassed: null,
    bookingCode: 'PC001',
    serviceName: 'Dắt đi dạo',
    serviceType: 'WALKING',
  }));
  const prisma = {
    sessionPhoto: { count: () => Promise.resolve(soAnh) },
    $queryRaw: () => Promise.resolve(dong),
  };
  const gia = anhKyGia();
  return {
    gia,
    service: new AdminEvidenceReadService(
      prisma as unknown as PrismaService,
      gia.service,
    ),
  };
}

describe('Thư viện ảnh bằng chứng của quản trị', () => {
  it('cả trang ảnh đi chung MỘT lượt ký, không ký từng ô lưới', async () => {
    const { gia, service } = dungDanhSachAnh(12);

    const trang = await service.danhSach({ source: 'session' } as never);

    expect(gia.luot).toHaveLength(1);
    expect(gia.luot[0]).toHaveLength(12);
    expect(trang.items[0].url).toBe('ky://don-1/anh-0.jpg');
  });
});

// Hồ sơ khiếu nại: kiểm quyền hai vai và ký ảnh hai phía trong một lượt
function dungKhieuNai(hoSo: Record<string, unknown>) {
  const prisma = {
    sitter: {
      findUnique: () =>
        Promise.resolve({ id: 'ncc-1', userId: NGUOI_CHAM, bannedAt: null }),
    },
    violationReport: { findUnique: () => Promise.resolve(hoSo) },
  };
  const gia = anhKyGia();
  return {
    gia,
    service: new DisputeService(
      prisma as unknown as PrismaService,
      { dayLen: () => Promise.resolve([]) } as unknown as AnhTaiLenService,
      gia.service,
    ),
  };
}

const DON_HO_SO = {
  id: 'don-1',
  code: 'PC-001',
  status: 'COMPLETED',
  scheduledAt: new Date(),
  scheduledEndAt: new Date(),
  endedAt: new Date(),
  durationMinutes: 60,
  totalPrice: 200000,
  sitterPayout: 170000,
  platformFee: 30000,
  priceBreakdown: null,
  cancellationReason: null,
  owner: { fullName: 'Hoa' },
  service: { name: 'Dắt đi dạo', type: 'WALKING' },
  pets: [{ pet: { name: 'Mun', species: 'DOG' } }],
  ownerId: CHU_NUOI,
  sitter: { userId: NGUOI_CHAM },
};

function hoSoMau() {
  return {
    code: 'KN-001',
    status: 'REVIEWING',
    description: 'Bé bị xước',
    evidenceUrls: ['don-1/kn-0.jpg', 'don-1/kn-1.jpg'],
    sitterReply: 'Tôi có ảnh lúc trả bé',
    sitterReplyAt: new Date(),
    sitterReplyPhotos: ['don-1/ph-0.jpg'],
    replyDeadline: null,
    resolution: null,
    resolutionReason: null,
    refundAmount: null,
    resolvedAt: null,
    createdAt: new Date(),
    booking: DON_HO_SO,
  };
}

describe('Ảnh khiếu nại chỉ mở cho hai bên của đơn', () => {
  it('chủ nuôi của đơn xem được, ảnh hai phía ký trong MỘT lượt', async () => {
    const { gia, service } = dungKhieuNai(hoSoMau());

    const ra = await service.theoMa(CHU_NUOI, 'KN-001');

    expect(gia.luot).toHaveLength(1);
    expect(gia.luot[0]).toEqual([
      'don-1/kn-0.jpg',
      'don-1/kn-1.jpg',
      'don-1/ph-0.jpg',
    ]);
    expect(ra.anhPhanAnh).toEqual([
      'ky://don-1/kn-0.jpg',
      'ky://don-1/kn-1.jpg',
    ]);
    expect(ra.anhPhanHoi).toEqual(['ky://don-1/ph-0.jpg']);
  });

  it('người chăm của đơn cũng xem được', async () => {
    const { service } = dungKhieuNai(hoSoMau());

    const ra = await service.theoMa(NGUOI_CHAM, 'KN-001');

    expect(ra.anhPhanAnh).toHaveLength(2);
  });

  it('người ngoài đơn bị từ chối, KHÔNG ký tấm nào', async () => {
    const { gia, service } = dungKhieuNai(hoSoMau());

    await expect(service.theoMa(NGUOI_LA, 'KN-001')).rejects.toMatchObject({
      response: { code: 'KHONG_TIM_THAY_KHIEU_NAI' },
    });
    expect(gia.luot).toHaveLength(0);
  });

  it('hồ sơ mang ảnh cũ dạng URL tuyệt đối vẫn ra được đường xem', async () => {
    const cu = hoSoMau();
    cu.evidenceUrls = [
      'https://abc.supabase.co/storage/v1/object/public/booking-media/don-1/cu.jpg',
    ];
    cu.sitterReplyPhotos = [];
    const { service } = dungKhieuNai(cu);

    const ra = await service.theoMa(CHU_NUOI, 'KN-001');

    expect(ra.anhPhanAnh[0]).toMatch(/^ky:\/\//);
  });
});
