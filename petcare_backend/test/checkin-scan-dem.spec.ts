import { anhDuNet, xuLySlot } from '../src/modules/ai/ai-ket-luan';
import {
  CANH_DAI_DU_NET_PX,
  LUOT_HONG_MO_VAN_XA,
  NGUONG_TIN_CAY_DAT,
  NGUONG_TIN_CAY_TU_XAC_NHAN,
  SO_LUOT_GUI_MOI_DON,
} from '../src/modules/ai/ai.constants';
import {
  conLai,
  duocTuXacNhan,
  loHongHaTang,
  luotDaTru,
  slotConThieu,
  slotDaDat,
  slotXong,
  tranAnhMoiLuot,
  xuLyCuaSlot,
  type DongQuet,
} from '../src/modules/sitter/orders/checkin-scan.dem';

// Ba mức tin cậy và bộ đếm lượt gửi chung cả đơn, theo bộ luật mục 8

function dong(v: Partial<DongQuet> & { slotIndex: number }): DongQuet {
  return {
    batchId: 'lo-1',
    trangThai: 'DAT',
    code: 'DAT',
    confidence: 0.9,
    canhDaiPx: 2000,
    tinhLuot: true,
    photoUrl: 'https://kho/anh.jpg',
    lat: null,
    lng: null,
    ...v,
  };
}

// Máy yếu không được thành hàng rào tư cách: ảnh nhỏ hạ mức chứ không bị chặn
describe('ảnh dưới ngưỡng nét thì hạ mức, không chặn', () => {
  it('máy chắc chắn nhưng ảnh nhỏ thì cao nhất chỉ tới tự xác nhận', () => {
    expect(xuLySlot({ trangThai: 'DAT', confidence: 1, canhDaiPx: 1280 })).toBe(
      'TU_XAC_NHAN',
    );
  });

  it('đúng ngưỡng là đủ nét, dưới một điểm ảnh là hạ mức', () => {
    expect(anhDuNet(CANH_DAI_DU_NET_PX)).toBe(true);
    expect(anhDuNet(CANH_DAI_DU_NET_PX - 1)).toBe(false);
    expect(
      xuLySlot({
        trangThai: 'DAT',
        confidence: 0.9,
        canhDaiPx: CANH_DAI_DU_NET_PX,
      }),
    ).toBe('DI_TIEP');
  });

  it('xuLy KHÔNG được trùng tên với trangThai, đó là bẫy đọc nhầm', () => {
    const nhoMaChac = {
      trangThai: 'DAT',
      confidence: 1,
      canhDaiPx: 1280,
    };
    expect(nhoMaChac.trangThai).toBe('DAT');
    expect(xuLySlot(nhoMaChac)).not.toBe(nhoMaChac.trangThai);
  });

  it('chưa đo được cạnh dài thì coi như chưa đủ nét, không được chốt đạt', () => {
    expect(anhDuNet(null)).toBe(false);
    expect(xuLySlot({ trangThai: 'DAT', confidence: 1, canhDaiPx: null })).toBe(
      'TU_XAC_NHAN',
    );
  });

  it('ảnh nhỏ mà máy cũng không chắc thì vẫn là chụp lại', () => {
    expect(
      xuLySlot({ trangThai: 'DAT', confidence: 0.3, canhDaiPx: 1280 }),
    ).toBe('CHUP_LAI');
  });

  it('ảnh nhỏ KHÔNG bao giờ tự nó thành chụp lại, người máy yếu vẫn đi tiếp được', () => {
    for (const doTin of [0.5, 0.6, 0.75, 0.9, 1]) {
      expect(
        xuLySlot({ trangThai: 'DAT', confidence: doTin, canhDaiPx: 480 }),
      ).toBe('TU_XAC_NHAN');
    }
  });

  it('ảnh nhỏ vẫn mở được van xả nên không có đơn nào kẹt cứng', () => {
    const ds = [dong({ slotIndex: 1, confidence: 1, canhDaiPx: 720 })];
    expect(xuLyCuaSlot(ds, 1)).toBe('TU_XAC_NHAN');
    expect(duocTuXacNhan(ds, 1, true)).toBe(true);
    expect(slotXong(ds, new Set([1]), 1)).toBe(true);
  });
});

describe('ba mức tin cậy', () => {
  it('chỉ xét độ tin cậy khi máy thấy rõ rọ mõm', () => {
    for (const doTin of [0, 0.4, 0.6, 0.9, 1]) {
      expect(xuLySlot({ trangThai: 'KHONG_DAT', confidence: doTin })).toBe(
        'CHUP_LAI',
      );
      expect(
        xuLySlot({ trangThai: 'CHUA_XAC_MINH_DUOC', confidence: doTin }),
      ).toBe('CHUP_LAI');
    }
  });

  it.each([
    [1, 'DI_TIEP'],
    [0.9, 'DI_TIEP'],
    [NGUONG_TIN_CAY_DAT, 'DI_TIEP'],
    [0.74, 'TU_XAC_NHAN'],
    [0.6, 'TU_XAC_NHAN'],
    [NGUONG_TIN_CAY_TU_XAC_NHAN, 'TU_XAC_NHAN'],
    [0.49, 'CHUP_LAI'],
    [0.2, 'CHUP_LAI'],
    [0, 'CHUP_LAI'],
  ] as [number, string][])('thấy rõ rọ mõm ở %s thì %s', (doTin, mong) => {
    expect(
      xuLySlot({ trangThai: 'DAT', confidence: doTin, canhDaiPx: 2000 }),
    ).toBe(mong);
  });

  it('hai ngưỡng là biên dưới, đứng đúng biên vẫn thuộc mức trên', () => {
    expect(
      xuLySlot({
        trangThai: 'DAT',
        confidence: NGUONG_TIN_CAY_DAT,
        canhDaiPx: 2000,
      }),
    ).toBe('DI_TIEP');
    expect(
      xuLySlot({
        trangThai: 'DAT',
        confidence: NGUONG_TIN_CAY_DAT - 0.001,
        canhDaiPx: 2000,
      }),
    ).not.toBe('DI_TIEP');
  });

  it('thiếu độ tin cậy thì coi như 0, không được rơi vào DAT', () => {
    expect(
      xuLySlot({ trangThai: 'DAT', confidence: null, canhDaiPx: 2000 }),
    ).toBe('CHUP_LAI');
  });
});

describe('bộ đếm đếm theo lượt gửi của cả đơn', () => {
  it('một lô gửi nhiều tấm vẫn chỉ là một lượt', () => {
    const ds = [
      dong({ slotIndex: 1, batchId: 'lo-1' }),
      dong({ slotIndex: 2, batchId: 'lo-1', trangThai: 'KHONG_DAT' }),
      dong({ slotIndex: 3, batchId: 'lo-1', trangThai: 'KHONG_DAT' }),
    ];
    expect(luotDaTru(ds)).toBe(1);
    expect(conLai(ds)).toBe(SO_LUOT_GUI_MOI_DON - 1);
  });

  it('mỗi lô gửi mới trừ thêm một lượt, hết ba lô là hết lượt', () => {
    expect(SO_LUOT_GUI_MOI_DON).toBe(3);
    const luot: DongQuet[] = [];
    for (const [lo, mong] of [
      ['lo-1', 2],
      ['lo-2', 1],
      ['lo-3', 0],
    ] as [string, number][]) {
      luot.push(dong({ slotIndex: 1, batchId: lo, trangThai: 'KHONG_DAT' }));
      expect(conLai(luot)).toBe(mong);
    }
    expect(duocTuXacNhan(luot, 1, true)).toBe(true);
  });

  it('lô toàn lỗi hạ tầng không trừ lượt', () => {
    const ds = [
      dong({ slotIndex: 1, batchId: 'lo-1', trangThai: 'KHONG_DAT' }),
      dong({
        slotIndex: 1,
        batchId: 'lo-2',
        trangThai: 'CHUA_XAC_MINH_DUOC',
        code: 'HET_HAN_MUC',
        tinhLuot: false,
      }),
    ];
    expect(luotDaTru(ds)).toBe(1);
    expect(loHongHaTang(ds)).toBe(1);
  });

  it('lô có tấm tính lượt lẫn tấm lỗi hạ tầng thì là lô tính lượt', () => {
    const ds = [
      dong({ slotIndex: 1, batchId: 'lo-1', trangThai: 'KHONG_DAT' }),
      dong({
        slotIndex: 2,
        batchId: 'lo-1',
        trangThai: 'CHUA_XAC_MINH_DUOC',
        code: 'QUA_HAN_CHO',
        tinhLuot: false,
      }),
    ];
    expect(luotDaTru(ds)).toBe(1);
    expect(loHongHaTang(ds)).toBe(0);
  });

  it('dòng treo chưa có kết luận thì không phải chốt của slot', () => {
    const treo = [
      dong({ slotIndex: 4, trangThai: null, code: null, tinhLuot: false }),
    ];
    expect(xuLyCuaSlot(treo, 4)).toBeNull();
    expect(slotDaDat(treo, 4)).toBe(false);
  });

  it('lấy lượt chốt gần nhất chứ không lấy lượt đầu', () => {
    const sua = [
      dong({
        slotIndex: 5,
        batchId: 'lo-1',
        trangThai: 'KHONG_DAT',
        code: 'THIEU_RO_MOM',
      }),
      dong({ slotIndex: 5, batchId: 'lo-2', confidence: 0.95 }),
    ];
    expect(xuLyCuaSlot(sua, 5)).toBe('DI_TIEP');
  });
});

describe('slot xong và cửa chặn check-in', () => {
  const trong = new Set<number>();

  it('máy cho qua hoặc người chăm đã ký, hai đường đều là xong', () => {
    const ds = [dong({ slotIndex: 1 })];
    expect(slotXong(ds, trong, 1)).toBe(true);
    expect(slotXong([], new Set([2]), 2)).toBe(true);
  });

  it('mức tự xác nhận mà chưa ký thì CHƯA xong', () => {
    const ds = [dong({ slotIndex: 1, confidence: 0.6 })];
    expect(xuLyCuaSlot(ds, 1)).toBe('TU_XAC_NHAN');
    expect(slotXong(ds, trong, 1)).toBe(false);
    expect(slotXong(ds, new Set([1]), 1)).toBe(true);
  });

  it('liệt kê đúng các bé còn thiếu để màn chỉ đích danh', () => {
    const ds = [
      dong({ slotIndex: 1 }),
      dong({ slotIndex: 3, trangThai: 'KHONG_DAT', code: 'THIEU_RO_MOM' }),
    ];
    expect(slotConThieu(ds, trong, 3)).toEqual([2, 3]);
    expect(slotConThieu(ds, new Set([2, 3]), 3)).toEqual([]);
  });

  it('chưa quét gì thì mọi bé đều thiếu, không mở phiên được', () => {
    expect(slotConThieu([], trong, 3)).toEqual([1, 2, 3]);
  });
});

describe('van xả tự xác nhận mở từ lượt hỏng thứ hai', () => {
  it('bé đã đạt thì không có gì để tự xác nhận', () => {
    expect(duocTuXacNhan([dong({ slotIndex: 1 })], 1, true)).toBe(false);
  });

  it('mức tin cậy vừa thì mở ngay từ lượt đầu', () => {
    const ds = [dong({ slotIndex: 1, confidence: 0.6 })];
    expect(duocTuXacNhan(ds, 1, true)).toBe(true);
  });

  it('mới hỏng một lượt thì phải chụp lại đã, chưa được ký', () => {
    const ds = [
      dong({ slotIndex: 1, trangThai: 'KHONG_DAT', code: 'THIEU_RO_MOM' }),
    ];
    expect(duocTuXacNhan(ds, 1, true)).toBe(false);
  });

  it('hỏng đủ hai lượt là van xả mở, chưa cần cạn ba lượt', () => {
    expect(LUOT_HONG_MO_VAN_XA).toBe(2);
    const ds = [
      dong({ slotIndex: 1, batchId: 'lo-1', trangThai: 'KHONG_DAT' }),
      dong({ slotIndex: 1, batchId: 'lo-2', trangThai: 'KHONG_DAT' }),
    ];
    expect(conLai(ds)).toBe(1);
    expect(duocTuXacNhan(ds, 1, true)).toBe(true);
  });

  it('hai lô lỗi hạ tầng liên tiếp cũng mở van, dù chưa trừ lượt nào', () => {
    const ds = ['lo-1', 'lo-2'].map((lo) =>
      dong({
        slotIndex: 1,
        batchId: lo,
        trangThai: 'CHUA_XAC_MINH_DUOC',
        code: 'HET_HAN_MUC',
        tinhLuot: false,
      }),
    );
    expect(luotDaTru(ds)).toBe(0);
    expect(loHongHaTang(ds)).toBe(2);
    expect(duocTuXacNhan(ds, 1, true)).toBe(true);
  });

  it('hết ba lượt thì chỉ còn đường tự xác nhận', () => {
    const ds = ['lo-1', 'lo-2', 'lo-3'].map((lo) =>
      dong({ slotIndex: 1, batchId: lo, trangThai: 'KHONG_DAT' }),
    );
    expect(conLai(ds)).toBe(0);
    expect(duocTuXacNhan(ds, 1, true)).toBe(true);
  });

  it('chạm trần lượt gọi của đơn thì mở van xả dù còn lượt gửi', () => {
    const ds = [
      dong({ slotIndex: 1, trangThai: 'KHONG_DAT', code: 'THIEU_RO_MOM' }),
    ];
    expect(duocTuXacNhan(ds, 1, false)).toBe(true);
  });

  it('chưa quét lượt nào thì không được ký khống', () => {
    expect(duocTuXacNhan([], 1, true)).toBe(false);
  });
});

describe('trần ảnh mỗi lượt gửi', () => {
  it('theo lượt gửi chứ không theo đơn, đủ chỗ cho lô bù', () => {
    expect(tranAnhMoiLuot(3)).toBe(8);
    expect(tranAnhMoiLuot(1)).toBe(4);
    expect(tranAnhMoiLuot(5)).toBe(12);
  });

  it('lô đầu n cộng 1 tấm luôn nằm dưới trần', () => {
    for (const soBe of [1, 2, 3, 4, 5]) {
      expect(soBe + 1).toBeLessThanOrEqual(tranAnhMoiLuot(soBe));
    }
  });
});
