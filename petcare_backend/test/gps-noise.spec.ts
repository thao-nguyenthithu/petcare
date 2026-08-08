import { danhDauNoise, DiemGps, tocDoKmh } from '../src/modules/gps/gps-noise';

// Noise là vượt ngưỡng ở CẢ hai chiều: đi nhanh thật thì nhanh liền mạch (mục 8)

// Mỗi 0,01 độ vĩ ~ 1,11km. Điểm cách nhau 15 giây.
function diem(lat: number, giay: number): DiemGps {
  return { lat, lng: 105.8, tsMs: giay * 1000 };
}

describe('tocDoKmh', () => {
  it('đi bộ 11m trong 15 giây ra ~2,7km/h', () => {
    const v = tocDoKmh(diem(21.0001, 0), diem(21.0002, 15));
    expect(v).toBeGreaterThan(2);
    expect(v).toBeLessThan(4);
  });

  it('hai điểm trùng mốc thời gian nhưng dời chỗ là tức thời', () => {
    expect(tocDoKmh(diem(21.0, 0), diem(21.01, 0))).toBe(Infinity);
  });

  it('đứng yên cùng mốc thời gian thì không phải spike', () => {
    expect(tocDoKmh(diem(21.0, 0), diem(21.0, 0))).toBe(0);
  });
});

describe('danhDauNoise', () => {
  it('điểm giữa nhảy xa rồi nhảy về bị đánh noise, hai điểm biên thì không', () => {
    // 21.0 → 21.01 (1,1km trong 15s ~ 267km/h) → về 21.0001
    const ketQua = danhDauNoise(null, [
      diem(21.0, 0),
      diem(21.01, 15),
      diem(21.0001, 30),
    ]);
    expect(ketQua).toEqual([false, true, false]);
  });

  it('đi nhanh thật một mạch (ngồi xe) không bị đánh noise cả dãy', () => {
    // Điểm biên chỉ có một chiều nên không kết luận được, dù bước nào cũng vượt ngưỡng
    const ketQua = danhDauNoise(null, [
      diem(21.0, 0),
      diem(21.01, 15),
      diem(21.02, 30),
    ]);
    // Điểm giữa vẫn dính luật hai chiều — chấp nhận, đi xe máy không phải phiên dắt
    expect(ketQua[0]).toBe(false);
    expect(ketQua[2]).toBe(false);
  });

  it('điểm đầu batch cũng có chiều vào nhờ nối điểm cuối đã lưu', () => {
    // Spike nằm ngay đầu batch vẫn bị bắt nhờ nối vào điểm đã lưu
    const ketQua = danhDauNoise(diem(21.0, 0), [
      diem(21.01, 15),
      diem(21.0001, 30),
    ]);
    expect(ketQua).toEqual([true, false]);
  });

  it('đi bộ bình thường không điểm nào bị noise', () => {
    const ketQua = danhDauNoise(null, [
      diem(21.0, 0),
      diem(21.0001, 15),
      diem(21.0002, 30),
      diem(21.0003, 45),
    ]);
    expect(ketQua).toEqual([false, false, false, false]);
  });

  it('kết quả luôn dài đúng bằng batch, không lẫn điểm cũ', () => {
    expect(danhDauNoise(diem(21.0, 0), [diem(21.0001, 15)])).toHaveLength(1);
    expect(danhDauNoise(null, [])).toHaveLength(0);
  });
});
