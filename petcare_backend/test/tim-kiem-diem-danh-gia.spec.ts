import {
  DIEM_TOI_THIEU_KHOI_NOI_BAT,
  diemDanhGiaCoTrongSo,
  LUOT_TOI_THIEU,
} from '../src/modules/search/sitter-search.helpers';

// Cửa vào khối Được đánh giá cao ở trang chủ (bộ luật mục 9)
function quaCua(ratingAvg: number, totalReviews: number): boolean {
  return (
    totalReviews >= LUOT_TOI_THIEU &&
    diemDanhGiaCoTrongSo(ratingAvg, totalReviews) >= DIEM_TOI_THIEU_KHOI_NOI_BAT
  );
}

describe('Điểm đánh giá có trọng số', () => {
  it('chưa có lượt nào thì rơi về đúng mức trung bình hệ thống', () => {
    expect(diemDanhGiaCoTrongSo(0, 0)).toBe(4.5);
  });

  it('ít lượt bị kéo về gần trung bình, nhiều lượt giữ gần điểm thật', () => {
    expect(diemDanhGiaCoTrongSo(5, 1)).toBeLessThan(
      diemDanhGiaCoTrongSo(5, 100),
    );
  });

  it('4,8 sao của trăm lượt đứng trên 5 sao của một lượt', () => {
    expect(diemDanhGiaCoTrongSo(4.8, 100)).toBeGreaterThan(
      diemDanhGiaCoTrongSo(5, 1),
    );
  });
});

describe('Cửa vào khối Được đánh giá cao', () => {
  it('hồ sơ chưa có đánh giá nào thì không lọt', () => {
    expect(quaCua(0, 0)).toBe(false);
  });

  it('điểm đẹp nhưng chưa đủ 5 lượt thì không lọt', () => {
    expect(quaCua(5, 4)).toBe(false);
  });

  it('đủ lượt mà điểm dưới mức trung bình hệ thống thì không lọt', () => {
    expect(quaCua(4, 20)).toBe(false);
  });

  it('đủ lượt và điểm trên ngưỡng thì lọt', () => {
    expect(quaCua(4.9, 20)).toBe(true);
  });
});
