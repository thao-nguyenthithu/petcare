import {
  kmHienThi,
  lechDangKe,
  tiLeLech,
  tongQuangDuongKm,
  ToaDo,
} from '../src/modules/gps/gps-quang-duong';

// Server chốt quãng đường, số app gửi chỉ để đối chiếu: lệch thì gắn cờ, không chặn tiền

// Mỗi 0,01 độ vĩ ~ 1,11km ở vĩ độ Hà Nội
function diem(lat: number): ToaDo {
  return { lat, lng: 105.8 };
}

describe('tongQuangDuongKm', () => {
  it('dãy rỗng hoặc một điểm thì chưa đi được mét nào', () => {
    expect(tongQuangDuongKm([])).toBe(0);
    expect(tongQuangDuongKm([diem(21.0)])).toBe(0);
  });

  it('cộng dồn từng chặng chứ không đo đường chim bay đầu tới cuối', () => {
    // Đi 21.0 → 21.01 → quay về 21.0: đường chim bay bằng 0 nhưng đã đi ~2,2km
    const km = tongQuangDuongKm([diem(21.0), diem(21.01), diem(21.0)]);
    expect(km).toBeGreaterThan(2.1);
    expect(km).toBeLessThan(2.3);
  });
});

describe('kmHienThi', () => {
  it('dưới hai điểm thì trả null để màn hiện gạch ngang, không phải 0 km', () => {
    expect(kmHienThi(0, 0)).toBeNull();
    expect(kmHienThi(1, 0)).toBeNull();
  });

  it('làm tròn một số lẻ theo cách đọc của người dùng', () => {
    expect(kmHienThi(120, 2345)).toBe(2.3);
    expect(kmHienThi(120, 2350)).toBe(2.4);
  });
});

describe('lechDangKe', () => {
  it('sai số vài chục mét trên quãng ngắn thì bỏ qua', () => {
    expect(lechDangKe(2.0, 2.1)).toBe(false);
  });

  it('app báo gấp đôi số về tới server thì gắn cờ', () => {
    expect(lechDangKe(2.0, 4.0)).toBe(true);
  });

  it('quãng dài lệch 0,4km vẫn trong ngưỡng tỉ lệ nên không gắn cờ', () => {
    expect(lechDangKe(10.0, 10.4)).toBe(false);
  });

  it('app không gửi số nào thì không có gì để đối chiếu', () => {
    expect(lechDangKe(2.0, null)).toBe(false);
  });
});

describe('tiLeLech', () => {
  it('hai số khớp nhau thì tỉ lệ lệch bằng 0', () => {
    expect(tiLeLech(2.0, 2.0)).toBe(0);
  });

  it('không điểm nào về tới server mà app báo có đi thì lệch kịch trần', () => {
    expect(tiLeLech(0, 3.0)).toBe(1);
  });

  it('về được một nửa quãng app ghi nhận ra tỉ lệ tương ứng', () => {
    expect(tiLeLech(4.0, 2.0)).toBe(0.5);
  });

  it('app chưa khai thì trả rỗng, KHÔNG trả 0 vì 0 đọc thành khớp hoàn hảo', () => {
    expect(tiLeLech(2.0, null)).toBeNull();
  });
});
