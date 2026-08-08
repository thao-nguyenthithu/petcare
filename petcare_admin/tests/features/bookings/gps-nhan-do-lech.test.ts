import { describe, expect, it } from 'vitest';
import { tinhNhanDoLech } from '@/features/bookings/gps-deviation';
import type { GpsReportRow } from '@/features/bookings/types';

function dong(ghiDe: Partial<GpsReportRow> = {}): GpsReportRow {
  return {
    bookingCode: 'PC6Q5MT3',
    sitterId: 'ncc-1',
    sitterName: 'Trịnh Văn Nam',
    suspicionScore: null,
    flaggedForReview: false,
    suspicionNote: null,
    totalDistanceM: 2000,
    claimedDistanceKm: 2,
    totalWaypoints: 40,
    durationMinutes: 60,
    avgSpeedKmh: 4,
    mockedCount: 0,
    speedFlag: false,
    reviewedAt: null,
    createdAt: '2026-08-05T02:00:00.000Z',
    ...ghiDe,
  };
}

describe('Nhãn độ lệch lộ trình', () => {
  it('không điểm nào về thì kết luận máy không gửi toạ độ', () => {
    expect(tinhNhanDoLech(dong({ totalWaypoints: 0 }))).toBe('trackingOff');
  });

  it('lộ trình thưa nhưng vẫn có điểm thì KHÔNG kết luận tắt định vị', () => {
    // Ngưỡng thưa cũ 0,5 điểm mỗi phút là số web tự đặt, backend không có hằng nào
    expect(tinhNhanDoLech(dong({ totalWaypoints: 3, durationMinutes: 60 }))).not.toBe(
      'trackingOff',
    );
  });

  it('chưa khai quãng đường thì để trống kết luận chứ không gán trong sai số', () => {
    expect(tinhNhanDoLech(dong({ claimedDistanceKm: null }))).toBe('noClaim');
  });

  it('phải vượt đồng thời cả hai mốc mới gắn cờ (bộ luật mục 8)', () => {
    expect(tinhNhanDoLech(dong({ totalDistanceM: 2000, claimedDistanceKm: 5 }))).toBe(
      'twoThresholds',
    );
    // Lệch 0,4 km vượt mốc tuyệt đối nhưng chỉ 4 phần trăm, chưa đủ hai mốc
    expect(tinhNhanDoLech(dong({ totalDistanceM: 10000, claimedDistanceKm: 10.4 }))).toBe(
      'ratioOnly',
    );
    expect(tinhNhanDoLech(dong({ totalDistanceM: 2000, claimedDistanceKm: 2.1 }))).toBe(
      'withinError',
    );
  });
});
