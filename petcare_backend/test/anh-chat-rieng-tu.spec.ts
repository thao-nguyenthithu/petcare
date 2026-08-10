import { PrismaService } from '../src/prisma/prisma.service';
import {
  BUCKET_ANH_CHAT,
  BUCKET_ANH_DON,
  GIAY_KY_ANH,
  khoCuaAnh,
} from '../src/modules/media/anh-duong-dan';
import { AnhKyService } from '../src/modules/media/anh-ky.service';
import { AnhTaiLenService } from '../src/modules/media/anh-tai-len.service';
import { SupabaseService } from '../src/modules/media/supabase.service';
import { type UploadedImage } from '../src/modules/media/image-upload';
import { ChatPhotoService } from '../src/modules/messaging/chat-photo.service';
import { MessagingService } from '../src/modules/messaging/messaging.service';
import { BookingNotifyService } from '../src/modules/notifications/booking-notify.service';

const CHU_NUOI = 'u-chu-nuoi';
const NGUOI_CHAM = 'u-ncc';
const NGUOI_LA = 'u-nguoi-la';
const HOI_THOAI = 'hoi-1';
const DON = 'don-1';

const ANH_CHAT_CU =
  'https://abc.supabase.co/storage/v1/object/public/chat-media/hoi-1/cu.jpg';

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
  const daTao: string[] = [];
  const daDay: Array<{ bucket: string; path: string }> = [];
  const luotKy: Array<{ kho: string; duong: string[]; giay: number }> = [];
  const supabase = {
    getClient: () => ({
      storage: {
        from: (kho: string) => ({
          createSignedUrls: (duong: string[], giay: number) => {
            luotKy.push({ kho, duong, giay });
            return Promise.resolve({
              data: duong.map((p) => ({ signedUrl: `https://ky/${kho}/${p}` })),
              error: null,
            });
          },
        }),
      },
    }),
    uploadFile: (bucket: string, path: string) => {
      daDay.push({ bucket, path });
      return Promise.resolve(path);
    },
    ensurePrivateBucket: (bucket: string) => {
      daTao.push(bucket);
      return Promise.resolve();
    },
  };
  return {
    daTao,
    daDay,
    luotKy,
    supabase: supabase as unknown as SupabaseService,
  };
}

function tinDb(anh: string[], thuTu = 0) {
  return {
    id: `tin-${thuTu}`,
    senderId: CHU_NUOI,
    role: 'OWNER',
    kind: 'IMAGE',
    text: '',
    textSitter: null,
    actionLabel: null,
    actionLabelSitter: null,
    canGap: false,
    masked: false,
    images: anh,
    soAnhThem: null,
    caption: null,
    lat: null,
    lng: null,
    isRead: false,
    createdAt: new Date(2026, 7, 8, 10, thuTu),
  };
}

function prismaGia(tuyChon: { status?: string; tin?: unknown[] } = {}) {
  const daGhi: Array<Record<string, unknown>> = [];
  const prisma = {
    conversation: {
      findUnique: () => Promise.resolve({ id: HOI_THOAI, bookingId: DON }),
      update: () => Promise.resolve({}),
    },
    booking: {
      findUnique: () =>
        Promise.resolve({
          id: DON,
          ownerId: CHU_NUOI,
          status: tuyChon.status ?? 'IN_PROGRESS',
          sitter: { userId: NGUOI_CHAM },
        }),
    },
    message: {
      create: (arg: { data: Record<string, unknown> }) => {
        daGhi.push(arg.data);
        return Promise.resolve({ ...tinDb([]), ...arg.data });
      },
      // Prisma trả mới nhất trước, spec khai theo chiều thời gian cho dễ đọc
      findMany: () => Promise.resolve([...(tuyChon.tin ?? [])].reverse()),
    },
    $transaction: (viec: Promise<unknown>[]) => Promise.all(viec),
  };
  return { daGhi, prisma: prisma as unknown as PrismaService };
}

function dungChat(tuyChon: { status?: string; tin?: unknown[] } = {}) {
  const kho = khoGia();
  const { daGhi, prisma } = prismaGia(tuyChon);
  const messaging = new MessagingService(
    prisma,
    new AnhKyService(kho.supabase),
    { tinNhanMoi: () => Promise.resolve() } as unknown as BookingNotifyService,
  );
  const anh = new ChatPhotoService(
    new AnhTaiLenService(kho.supabase),
    messaging,
  );
  return { kho, daGhi, messaging, anh };
}

describe('Ảnh chat đẩy vào kho riêng tư và lưu path', () => {
  it('lưu path mang dấu kho chat, không lưu URL công khai', async () => {
    const { kho, daGhi, anh } = dungChat();

    await anh.gui(CHU_NUOI, HOI_THOAI, [anhPng(), anhPng()]);

    const duong = daGhi[0].images as string[];
    expect(duong).toHaveLength(2);
    for (const d of duong) {
      expect(d).not.toMatch(/^https?:\/\//);
      expect(d).toMatch(/^chat\/hoi-1\/[0-9a-f-]+\.png$/);
      expect(khoCuaAnh(d)).toBe(BUCKET_ANH_CHAT);
    }
    expect(kho.daTao).toEqual([BUCKET_ANH_CHAT]);
    expect(kho.daDay.every((d) => d.bucket === BUCKET_ANH_CHAT)).toBe(true);
  });

  it('path không mang dấu chat vẫn thuộc kho đơn như cũ', () => {
    expect(khoCuaAnh('don-1/anh-0.jpg')).toBe(BUCKET_ANH_DON);
    expect(khoCuaAnh(ANH_CHAT_CU)).toBe(BUCKET_ANH_CHAT);
  });

  it('tin vừa gửi trả về đường ký chứ không trả path trần', async () => {
    const { daGhi, anh } = dungChat();

    const ra = await anh.gui(CHU_NUOI, HOI_THOAI, [anhPng()]);

    const duong = (daGhi[0].images as string[])[0];
    expect(ra.kyAnh.get(duong)).toBe(`https://ky/${BUCKET_ANH_CHAT}/${duong}`);
  });

  it('người ngoài đơn bị chặn TRƯỚC khi tệp chạm kho', async () => {
    const { kho, anh } = dungChat();

    await expect(anh.gui(NGUOI_LA, HOI_THOAI, [anhPng()])).rejects.toThrow(
      'Bạn không thuộc đơn này',
    );
    expect(kho.daDay).toHaveLength(0);
    expect(kho.daTao).toHaveLength(0);
  });

  it('đơn đã khép thì không nhận thêm tệp nào vào kho', async () => {
    const { kho, anh } = dungChat({ status: 'COMPLETED' });

    await expect(anh.gui(CHU_NUOI, HOI_THOAI, [anhPng()])).rejects.toThrow(
      'Cuộc trò chuyện đã kết thúc',
    );
    expect(kho.daDay).toHaveLength(0);
  });
});

describe('Trang tin ký ảnh theo kho, mỗi kho một lượt', () => {
  it('cả trang ảnh chat đi chung MỘT lượt ký đúng kho chat', async () => {
    const tin = Array.from({ length: 12 }, (_, i) =>
      tinDb([`chat/hoi-1/a-${i}.jpg`, `chat/hoi-1/b-${i}.jpg`], i),
    );
    const { kho, messaging } = dungChat({ tin });

    const trang = await messaging.tinNhan(CHU_NUOI, HOI_THOAI);

    expect(kho.luotKy).toHaveLength(1);
    expect(kho.luotKy[0].kho).toBe(BUCKET_ANH_CHAT);
    expect(kho.luotKy[0].duong).toHaveLength(24);
    expect(kho.luotKy[0].giay).toBe(GIAY_KY_ANH);
    expect(trang.items[0].images[0]).toBe(
      `https://ky/${BUCKET_ANH_CHAT}/chat/hoi-1/a-0.jpg`,
    );
  });

  it('cột trộn hai kho: mỗi kho đúng một lượt, không kho nào ký nhầm', async () => {
    const tin = [
      tinDb(['chat/hoi-1/a.jpg', 'chat/hoi-1/b.jpg'], 0),
      tinDb(['don-1/phien-0.jpg'], 1),
    ];
    const { kho, messaging } = dungChat({ tin });

    const trang = await messaging.tinNhan(CHU_NUOI, HOI_THOAI);

    expect(kho.luotKy).toHaveLength(2);
    const theoKho = new Map(kho.luotKy.map((l) => [l.kho, l.duong]));
    expect(theoKho.get(BUCKET_ANH_CHAT)).toEqual([
      'chat/hoi-1/a.jpg',
      'chat/hoi-1/b.jpg',
    ]);
    expect(theoKho.get(BUCKET_ANH_DON)).toEqual(['don-1/phien-0.jpg']);
    expect(trang.items[0].images).toEqual([
      `https://ky/${BUCKET_ANH_CHAT}/chat/hoi-1/a.jpg`,
      `https://ky/${BUCKET_ANH_CHAT}/chat/hoi-1/b.jpg`,
    ]);
    expect(trang.items[1].images).toEqual([
      `https://ky/${BUCKET_ANH_DON}/don-1/phien-0.jpg`,
    ]);
  });

  it('ảnh chat cũ dạng URL tuyệt đối vẫn ra được đường xem', async () => {
    const { kho, messaging } = dungChat({ tin: [tinDb([ANH_CHAT_CU], 0)] });

    const trang = await messaging.tinNhan(NGUOI_CHAM, HOI_THOAI);

    expect(kho.luotKy).toEqual([
      { kho: BUCKET_ANH_CHAT, duong: ['hoi-1/cu.jpg'], giay: GIAY_KY_ANH },
    ]);
    expect(trang.items[0].images).toEqual([
      `https://ky/${BUCKET_ANH_CHAT}/hoi-1/cu.jpg`,
    ]);
  });

  it('người ngoài đơn bị từ chối, KHÔNG tấm nào được ký', async () => {
    const tin = [tinDb(['chat/hoi-1/a.jpg'], 0)];
    const { kho, messaging } = dungChat({ tin });

    await expect(messaging.tinNhan(NGUOI_LA, HOI_THOAI)).rejects.toThrow(
      'Bạn không thuộc đơn này',
    );
    expect(kho.luotKy).toHaveLength(0);
  });
});
