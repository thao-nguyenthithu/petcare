import { BadRequestException } from '@nestjs/common';
import { type UploadedImage } from '../src/modules/media/image-upload';
import {
  phaiCoAnhHaiDauPhien,
  phaiHopLeAnhDoDung,
  phaiHopLeAnhSuCo,
  SO_ANH_DO_DUNG,
} from '../src/modules/sitter/orders/sitter-order-store.service';
import { SO_ANH_MO_KHIEU_NAI } from '../src/modules/wallet/dto/wallet.dto';

function anh(so: number): UploadedImage[] {
  return Array.from({ length: so }, () => ({}));
}

// Kiểm mã lỗi chứ không kiểm lớp: hai nhánh cùng ném 400 nên lớp không phân biệt được
function maLoi(chay: () => void): string {
  try {
    chay();
  } catch (loi) {
    const than = (loi as BadRequestException).getResponse();
    return (than as { code?: string }).code ?? '';
  }
  return '';
}

describe('Ảnh đồ dùng của kỳ trông giữ', () => {
  it('không gửi tấm nào vẫn qua, đây là loại ảnh không bắt buộc', () => {
    expect(() => phaiHopLeAnhDoDung([], 'boarding')).not.toThrow();
    expect(() => phaiHopLeAnhDoDung([], 'walking')).not.toThrow();
  });

  it('kỳ trông giữ nhận tới đúng trần của bộ luật', () => {
    expect(() =>
      phaiHopLeAnhDoDung(anh(SO_ANH_DO_DUNG), 'boarding'),
    ).not.toThrow();
  });

  it('quá trần thì chặn', () => {
    expect(
      maLoi(() => phaiHopLeAnhDoDung(anh(SO_ANH_DO_DUNG + 1), 'boarding')),
    ).toBe('VUOT_GIOI_HAN_ANH');
  });

  it('dắt dạo và cắt tỉa gửi lên thì từ chối chứ không lặng lẽ bỏ qua', () => {
    for (const loai of ['walking', 'grooming'] as const) {
      expect(maLoi(() => phaiHopLeAnhDoDung(anh(1), loai))).toBe(
        'KHONG_CO_ANH_DO_DUNG',
      );
    }
  });

  it('ảnh báo sự cố dùng chung trần với lối chủ nuôi mở hồ sơ', () => {
    expect(() => phaiHopLeAnhSuCo(anh(SO_ANH_MO_KHIEU_NAI))).not.toThrow();
    expect(maLoi(() => phaiHopLeAnhSuCo(anh(SO_ANH_MO_KHIEU_NAI + 1)))).toBe(
      'VUOT_GIOI_HAN_ANH',
    );
    // Không bắt buộc và cho ít chỗ là hai chuyện khác nhau (bộ luật mục 7)
    expect(() => phaiHopLeAnhSuCo([])).not.toThrow();
  });

  it('trần ảnh đồ dùng KHÔNG ăn vào trần ảnh các bé', () => {
    // Đơn 2 bé: ảnh các bé nhận từ 2 tới 4 tấm, ảnh đồ dùng đi đường riêng
    expect(() => phaiCoAnhHaiDauPhien(anh(4), 2, 'boarding')).not.toThrow();
    expect(() => phaiHopLeAnhDoDung(anh(4), 'boarding')).not.toThrow();
    // Gộp chung một mảng như trước là 8 tấm trên trần 4, hỏng đúng ở đây
    expect(maLoi(() => phaiCoAnhHaiDauPhien(anh(8), 2, 'boarding'))).toBe(
      'SAI_SO_ANH_BAT_BUOC',
    );
  });
});
