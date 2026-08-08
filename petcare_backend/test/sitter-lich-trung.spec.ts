import { BookingStatus } from 'generated/prisma/enums';
import {
  DonTrenLich,
  chongGio,
  hetCuaNhan,
  vuotSucChua,
} from '../src/modules/sitter/orders/sitter-lich-trung';

// Dắt và grooming phải CÓ MẶT nên không chồng giờ, chỉ trông giữ xét theo số chỗ

function don(
  loai: 'WALKING' | 'BOARDING' | 'GROOMING',
  batDau: string,
  opts: {
    phut?: number;
    ketThuc?: string;
    be?: number;
    status?: BookingStatus;
  } = {},
): DonTrenLich {
  return {
    id: `${loai}-${batDau}`,
    status: opts.status ?? 'CONFIRMED',
    createdAt: new Date('2026-08-01T00:00:00Z'),
    paidAt: new Date('2026-08-01T00:00:00Z'),
    scheduledAt: new Date(batDau),
    scheduledEndAt: opts.ketThuc ? new Date(opts.ketThuc) : null,
    durationMinutes: opts.phut ?? null,
    service: { type: loai, durationMinutes: 60 },
    _count: { pets: opts.be ?? 1 },
  };
}

describe('chồng giờ của đơn dắt và grooming', () => {
  it('hai buổi dắt cùng khung là chồng nhau', () => {
    const a = don('WALKING', '2026-08-06T03:00:00Z', { phut: 30 });
    const b = don('WALKING', '2026-08-06T03:00:00Z', { phut: 30 });
    expect(chongGio(a, b)).toBe(true);
  });

  it('cách nhau 5 phút vẫn tính là chồng vì có đệm di chuyển', () => {
    const a = don('WALKING', '2026-08-06T03:00:00Z', { phut: 30 });
    const b = don('WALKING', '2026-08-06T03:35:00Z', { phut: 30 });
    expect(chongGio(a, b)).toBe(true);
  });

  it('cách nhau hơn đệm hai đầu thì nhận được cả hai', () => {
    const a = don('WALKING', '2026-08-06T03:00:00Z', { phut: 30 });
    const b = don('WALKING', '2026-08-06T04:05:00Z', { phut: 30 });
    expect(chongGio(a, b)).toBe(false);
  });
});

describe('sức chứa của kỳ trông giữ', () => {
  const ky = (batDau: string, ketThuc: string, be: number) =>
    don('BOARDING', batDau, { ketThuc, be });

  it('còn chỗ thì nhận thêm kỳ chồng đêm là bình thường', () => {
    const moi = ky('2026-08-07T01:00:00Z', '2026-08-08T03:00:00Z', 2);
    const daNhan = [ky('2026-08-07T01:00:00Z', '2026-08-08T03:00:00Z', 1)];
    expect(vuotSucChua(moi, daNhan, 5)).toBe(false);
  });

  it('một đêm kín chỗ là cả kỳ không nhận được', () => {
    const moi = ky('2026-08-07T01:00:00Z', '2026-08-08T03:00:00Z', 2);
    const daNhan = [ky('2026-08-07T01:00:00Z', '2026-08-08T03:00:00Z', 3)];
    expect(vuotSucChua(moi, daNhan, 4)).toBe(true);
  });
});

describe('đơn chờ nào chết sau khi người chăm nhận đơn khác', () => {
  it('đơn dắt chờ trùng khung với đơn dắt vừa nhận thì hết cửa', () => {
    const vuaNhan = don('WALKING', '2026-08-06T03:00:00Z', { phut: 30 });
    const ung = don('WALKING', '2026-08-06T03:00:00Z', {
      phut: 30,
      status: 'PENDING',
    });
    expect(hetCuaNhan(ung, vuaNhan, [vuaNhan], 0)).toBe(true);
  });

  it('grooming chờ trùng khung với đơn dắt vừa nhận cũng hết cửa', () => {
    const vuaNhan = don('WALKING', '2026-08-06T03:00:00Z', { phut: 30 });
    const ung = don('GROOMING', '2026-08-06T03:15:00Z', {
      phut: 90,
      status: 'PENDING',
    });
    expect(hetCuaNhan(ung, vuaNhan, [vuaNhan], 0)).toBe(true);
  });

  it('đơn dắt khung giờ khác vẫn sống', () => {
    const vuaNhan = don('WALKING', '2026-08-06T03:00:00Z', { phut: 30 });
    const ung = don('WALKING', '2026-08-06T07:00:00Z', {
      phut: 30,
      status: 'PENDING',
    });
    expect(hetCuaNhan(ung, vuaNhan, [vuaNhan], 0)).toBe(false);
  });

  it('kỳ trông giữ đang chạy KHÔNG giết đơn dắt chờ: hai việc khác nhau', () => {
    const vuaNhan = don('BOARDING', '2026-08-06T01:00:00Z', {
      ketThuc: '2026-08-08T03:00:00Z',
    });
    const ung = don('WALKING', '2026-08-06T03:00:00Z', {
      phut: 30,
      status: 'PENDING',
    });
    expect(hetCuaNhan(ung, vuaNhan, [vuaNhan], 3)).toBe(false);
  });

  it('kỳ trông giữ chờ chỉ chết khi đã hết chỗ', () => {
    const vuaNhan = don('BOARDING', '2026-08-07T01:00:00Z', {
      ketThuc: '2026-08-08T03:00:00Z',
      be: 3,
    });
    const ung = don('BOARDING', '2026-08-07T01:00:00Z', {
      ketThuc: '2026-08-08T03:00:00Z',
      be: 2,
      status: 'PENDING',
    });
    expect(hetCuaNhan(ung, vuaNhan, [vuaNhan], 4)).toBe(true);
    expect(hetCuaNhan(ung, vuaNhan, [vuaNhan], 6)).toBe(false);
  });
});
