import { ConfigService } from '@nestjs/config';
import { CANH_DAI_DU_NET_PX } from '../src/modules/ai/ai.constants';
import { GioiHanService } from '../src/modules/admin/gioi-han/gioi-han.service';
import { TRAN_MOI_TRANG } from '../src/modules/admin/chung/phan-trang';
import { MAT_KHAU_TOI_THIEU } from '../src/modules/auth/auth.constants';
import { OTP_TTL_SECONDS } from '../src/modules/auth/otp.service';
import { TRAN_PHUT_GROOMING } from '../src/modules/bookings/booking-pricing';
import { hanNhanDonPhut } from '../src/modules/bookings/booking-time';
import { BAC_NGAY_TAM_AN } from '../src/modules/bookings/sitter-penalty-rules';
import { NGUONG_LECH_TY_LE } from '../src/modules/gps/gps.constants';
import { GIOI_HAN_ANH_BYTE } from '../src/modules/media/image-upload';
import { MAX_PET_MOI_CHU } from '../src/modules/pets/pets.service';
import { TY_LE_HUY_TOI_DA } from '../src/modules/search/sitter-trusted';
import type { NhomGioiHan } from '../src/modules/admin/gioi-han/gioi-han.types';

function dungService(hanPhien: string | undefined = '30d') {
  const config = {
    get: () => hanPhien,
  } as unknown as ConfigService;
  return new GioiHanService(config);
}

function timDong(nhom: NhomGioiHan[], ma: string) {
  for (const n of nhom) {
    const dong = n.items.find((i) => i.ma === ma);
    if (dong) return dong;
  }
  throw new Error(`Không có dòng "${ma}" trên màn 15b`);
}

describe('Giới hạn và hạn mức, màn 15b', () => {
  const nhom = dungService().danhSach();

  it('không đọc cơ sở dữ liệu nên gọi bao nhiêu lần cũng ra cùng một bản kê', () => {
    expect(dungService().danhSach()).toEqual(nhom);
  });

  it('mỗi nhóm nằm trọn một cột và khoá không trùng nhau', () => {
    const khoa = nhom.map((n) => n.key);
    expect(new Set(khoa).size).toBe(khoa.length);
    for (const n of nhom) {
      expect(['trai', 'phai']).toContain(n.cot);
      expect(n.items.length).toBeGreaterThan(0);
    }
  });

  it('mọi dòng đều có mã, chỉ nhóm chưa có trong code mới được bỏ trống giá trị', () => {
    for (const n of nhom) {
      for (const dong of n.items) {
        expect(dong.ma.trim()).not.toBe('');
        if (!n.chuaCoTrongCode) expect(dong.value.trim()).not.toBe('');
      }
    }
  });

  it('lấy số thẳng từ module đang thi hành chứ không giữ bản sao', () => {
    expect(timDong(nhom, 'taiKhoan.matKhauToiThieu').value).toBe(
      String(MAT_KHAU_TOI_THIEU),
    );
    expect(timDong(nhom, 'thuCung.soBeToiDaMoiTaiKhoan').value).toBe(
      String(MAX_PET_MOI_CHU),
    );
    expect(timDong(nhom, 'taiKhoan.hanDungMaXacMinh').value).toBe(
      String(OTP_TTL_SECONDS / 60),
    );
    expect(timDong(nhom, 'taiKhoan.dungLuongToiDaMoiAnh').value).toBe(
      String(GIOI_HAN_ANH_BYTE / 1024 / 1024),
    );
    expect(timDong(nhom, 'datLich.tranThoiLuongMotDonTamVaCatTia').value).toBe(
      String(TRAN_PHUT_GROOMING / 60),
    );
    expect(timDong(nhom, 'kyLuat.thoiGianTamAnHoSo').value).toBe(
      BAC_NGAY_TAM_AN.join(' · '),
    );
    expect(timDong(nhom, 'aiAnh.canhDaiAnhCoiLaDuNet').value).toBe(
      CANH_DAI_DU_NET_PX.toLocaleString('vi-VN'),
    );
    expect(timDong(nhom, 'hienThi.tranDongMoiTrang').value).toBe(
      String(TRAN_MOI_TRANG),
    );
  });

  it('bốn bậc hạn trả lời lấy bằng cách gọi hàm thật', () => {
    const bac = [
      hanNhanDonPhut(0),
      hanNhanDonPhut(7 * 60),
      hanNhanDonPhut(48 * 60),
      hanNhanDonPhut(30 * 24 * 60),
    ];
    expect(new Set(bac).size).toBe(4);
    expect(timDong(nhom, 'datLich.hanNguoiChamTraLoi').value).toBe(
      bac.map((p) => p.toLocaleString('vi-VN')).join(' · '),
    );
  });

  it('tỷ lệ ra phần trăm không lôi theo đuôi dấu phẩy động', () => {
    expect(timDong(nhom, 'dichVuLich.huyHieuTyLeHuyToiDa').value).toBe(
      String(Math.round(TY_LE_HUY_TOI_DA * 100)),
    );
    expect(timDong(nhom, 'gps.nguongLechTheoTyLe').value).toBe(
      String(Math.round(NGUONG_LECH_TY_LE * 100)),
    );
  });

  it('hạn phiên đọc từ cấu hình đang chạy, dạng lạ thì giữ nguyên chuỗi', () => {
    expect(
      timDong(dungService('30d').danhSach(), 'taiKhoan.phienDangNhap'),
    ).toEqual(expect.objectContaining({ value: '30', unit: 'ngay' }));
    expect(
      timDong(dungService('12h').danhSach(), 'taiKhoan.phienDangNhap'),
    ).toEqual(expect.objectContaining({ value: '12h', unit: '' }));
  });

  it('nhóm chưa có trong code không mang con số nào', () => {
    const chuaCo = nhom.find((n) => n.chuaCoTrongCode);
    expect(chuaCo).toBeDefined();
    for (const dong of chuaCo!.items) {
      expect(dong.value).toBe('');
    }
  });
});
