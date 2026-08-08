import { describe, expect, it } from 'vitest';
import { tinhTrangHanDap } from '@/features/disputes/dispute-constants';
import { tinhTrangPhanHoi } from '@/features/reviews/review-constants';

const BAY_GIO = new Date('2026-08-08T10:00:00.000Z');

function conLai(gio: number) {
  return new Date(BAY_GIO.getTime() + gio * 3_600_000).toISOString();
}

describe('Hạn đáp hồ sơ khiếu nại làm tròn XUỐNG, một lượt đáp không được hứa dư', () => {
  it('còn 1 giờ 40 phút thì đọc là 1 giờ chứ không phải 2', () => {
    const ket = tinhTrangHanDap(
      { replyDeadline: conLai(1 + 40 / 60), sitterReplyAt: null },
      BAY_GIO,
    );

    expect(ket).toEqual({ kieu: 'conHan', soGio: 1 });
  });

  it('còn dưới một giờ vẫn đọc là 1 giờ, không bao giờ hiện 0', () => {
    const ket = tinhTrangHanDap(
      { replyDeadline: conLai(0.3), sitterReplyAt: null },
      BAY_GIO,
    );

    expect(ket).toEqual({ kieu: 'conHan', soGio: 1 });
  });

  it('hết hạn rồi thì không rơi lại vào nhánh còn hạn', () => {
    const ket = tinhTrangHanDap(
      { replyDeadline: conLai(-0.5), sitterReplyAt: null },
      BAY_GIO,
    );

    expect(ket).toEqual({ kieu: 'hetHan' });
  });
});

describe('Hạn phản hồi đánh giá cũng làm tròn XUỐNG, hết hạn là chốt luôn', () => {
  const DONG = { reply: null, replyAt: null };

  it('còn 2 ngày 20 giờ thì đọc là 2 ngày chứ không phải 3', () => {
    const ket = tinhTrangPhanHoi(
      { ...DONG, replyDeadline: conLai(2 * 24 + 20) },
      BAY_GIO,
    );

    expect(ket).toEqual({ kieu: 'conHan', soNgay: 2 });
  });

  it('còn vài giờ cuối vẫn đọc là 1 ngày, không hiện 0', () => {
    const ket = tinhTrangPhanHoi(
      { ...DONG, replyDeadline: conLai(5) },
      BAY_GIO,
    );

    expect(ket).toEqual({ kieu: 'conHan', soNgay: 1 });
  });
});
