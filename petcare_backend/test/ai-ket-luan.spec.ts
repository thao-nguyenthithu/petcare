import {
  BaoCaoModel,
  CAU_MAC_DINH,
  CAU_TIENG_VIET,
  chuaXacMinhDuoc,
  docBaoCao,
  ketLuanTuBaoCao,
  laHeThongHong,
  maLoiTheoTrangThai,
  truLuotChupLai,
} from '../src/modules/ai/ai-ket-luan';
import { AiVerifyResult } from '../src/modules/ai/interfaces/ai-vision.interface';

// AI xác minh rọ mõm và dây xích (bộ luật mục 8); sai ở đây là thả bé ra đường

type Gear = BaoCaoModel['muzzle'];

const GEAR: Gear[] = ['PRESENT', 'ABSENT', 'UNCLEAR'];

type ToHop = {
  ten: string;
  bc: BaoCaoModel;
  datMongDoi: boolean;
};

function moTa(bc: BaoCaoModel): string {
  const co = bc.dog_visible ? 'thấy bé' : 'không thấy bé';
  const ro = bc.image_clear ? 'ảnh rõ' : 'ảnh mờ';
  return `${co}, ${ro}, rọ mõm ${bc.muzzle}, dây xích ${bc.leash}`;
}

function dungToHop(): ToHop[] {
  const ds: ToHop[] = [];
  for (const dogVisible of [true, false]) {
    for (const imageClear of [true, false]) {
      for (const muzzle of GEAR) {
        for (const leash of GEAR) {
          const bc: BaoCaoModel = {
            dog_visible: dogVisible,
            image_clear: imageClear,
            muzzle,
            leash,
            confidence: 0.9,
          };
          ds.push({
            ten: moTa(bc),
            bc,
            datMongDoi:
              dogVisible &&
              imageClear &&
              muzzle === 'PRESENT' &&
              leash === 'PRESENT',
          });
        }
      }
    }
  }
  return ds;
}

const TO_HOP = dungToHop();

// Adapter làm đúng hai bước này, test đi qua cả hai để không bỏ lọt chỗ nối
function quetMotAnh(tho: unknown): AiVerifyResult {
  const bc = docBaoCao(tho);
  if (!bc) return chuaXacMinhDuoc('KET_QUA_KHONG_DOC_DUOC');
  return ketLuanTuBaoCao(bc, {});
}

describe('không đường nào ra đạt ngoài đủ rọ mõm và dây xích', () => {
  it('quét đủ 36 tổ hợp, đúng một tổ hợp được đạt', () => {
    expect(TO_HOP).toHaveLength(36);
    expect(TO_HOP.filter((t) => t.datMongDoi)).toHaveLength(1);
  });

  it.each(TO_HOP)('$ten', ({ bc, datMongDoi }) => {
    const ket = ketLuanTuBaoCao(bc, {});
    expect(ket.isSafe).toBe(datMongDoi);
    expect(ket.trangThai === 'DAT').toBe(datMongDoi);
  });

  it.each(TO_HOP)('$ten - qua cả bước đọc báo cáo', ({ bc, datMongDoi }) => {
    expect(quetMotAnh(bc).isSafe).toBe(datMongDoi);
  });

  it('isSafe chỉ true khi trangThai là DAT, không có ngoại lệ', () => {
    for (const { bc } of TO_HOP) {
      const ket = ketLuanTuBaoCao(bc, {});
      if (ket.isSafe) expect(ket.trangThai).toBe('DAT');
      if (ket.trangThai !== 'DAT') expect(ket.isSafe).toBe(false);
    }
  });

  it('giữ nguyên độ tin của model khi kết luận được', () => {
    const bc: BaoCaoModel = {
      dog_visible: true,
      image_clear: true,
      muzzle: 'PRESENT',
      leash: 'PRESENT',
      confidence: 0.62,
    };
    expect(ketLuanTuBaoCao(bc, {}).confidence).toBe(0.62);
  });
});

describe('chưa xác minh được khác không đạt', () => {
  function bc(muzzle: Gear, leash: Gear): BaoCaoModel {
    return {
      dog_visible: true,
      image_clear: true,
      muzzle,
      leash,
      confidence: 0.9,
    };
  }

  it('rọ mõm UNCLEAR thì cho chụp lại chứ không ghi nhận vi phạm', () => {
    const ket = ketLuanTuBaoCao(bc('UNCLEAR', 'PRESENT'), {});
    expect(ket.trangThai).toBe('CHUA_XAC_MINH_DUOC');
    expect(ket.code).toBe('KHONG_RO_RO_MOM');
  });

  it('dây xích UNCLEAR thì cho chụp lại chứ không ghi nhận vi phạm', () => {
    const ket = ketLuanTuBaoCao(bc('PRESENT', 'UNCLEAR'), {});
    expect(ket.trangThai).toBe('CHUA_XAC_MINH_DUOC');
    expect(ket.code).toBe('KHONG_RO_DAY_XICH');
  });

  it('UNCLEAR đứng cạnh ABSENT vẫn là chưa xác minh được', () => {
    expect(ketLuanTuBaoCao(bc('UNCLEAR', 'ABSENT'), {}).trangThai).toBe(
      'CHUA_XAC_MINH_DUOC',
    );
  });

  it('không tổ hợp UNCLEAR nào rơi vào KHONG_DAT', () => {
    const coUnclear = TO_HOP.filter(
      (t) =>
        t.bc.dog_visible &&
        t.bc.image_clear &&
        (t.bc.muzzle === 'UNCLEAR' || t.bc.leash === 'UNCLEAR'),
    );
    expect(coUnclear.length).toBeGreaterThan(0);
    for (const { bc: bao } of coUnclear) {
      expect(ketLuanTuBaoCao(bao, {}).trangThai).toBe('CHUA_XAC_MINH_DUOC');
    }
  });

  it('không thấy bé và ảnh mờ đều là chưa xác minh được, độ tin về 0', () => {
    const khongThay = ketLuanTuBaoCao(
      { ...bc('PRESENT', 'PRESENT'), dog_visible: false },
      {},
    );
    expect(khongThay.code).toBe('KHONG_THAY_CHO');
    expect(khongThay.confidence).toBe(0);
    const anhMo = ketLuanTuBaoCao(
      { ...bc('PRESENT', 'PRESENT'), image_clear: false },
      {},
    );
    expect(anhMo.code).toBe('ANH_MO');
  });

  it('thiếu thật thì mới là KHONG_DAT, đủ ba nhánh', () => {
    expect(ketLuanTuBaoCao(bc('ABSENT', 'PRESENT'), {}).code).toBe(
      'THIEU_RO_MOM',
    );
    expect(ketLuanTuBaoCao(bc('PRESENT', 'ABSENT'), {}).code).toBe(
      'THIEU_DAY_XICH',
    );
    expect(ketLuanTuBaoCao(bc('ABSENT', 'ABSENT'), {}).code).toBe(
      'THIEU_CA_HAI',
    );
    for (const cap of [
      ['ABSENT', 'PRESENT'],
      ['PRESENT', 'ABSENT'],
      ['ABSENT', 'ABSENT'],
    ] as [Gear, Gear][]) {
      expect(ketLuanTuBaoCao(bc(cap[0], cap[1]), {}).trangThai).toBe(
        'KHONG_DAT',
      );
    }
  });
});

describe('dữ liệu model trả về hỏng', () => {
  const RAC: [string, unknown][] = [
    ['null', null],
    ['undefined', undefined],
    ['chuỗi rỗng', ''],
    ['văn xuôi', 'con chó có rọ mõm rồi'],
    ['số', 7],
    ['mảng', []],
    ['vật rỗng', {}],
    [
      'thiếu leash',
      { dog_visible: true, image_clear: true, muzzle: 'PRESENT' },
    ],
    [
      'thiếu dog_visible',
      { image_clear: true, muzzle: 'PRESENT', leash: 'PRESENT' },
    ],
    [
      'cờ là chuỗi thay vì boolean',
      {
        dog_visible: 'true',
        image_clear: true,
        muzzle: 'PRESENT',
        leash: 'PRESENT',
      },
    ],
    [
      'gear là giá trị lạ',
      {
        dog_visible: true,
        image_clear: true,
        muzzle: 'MAYBE',
        leash: 'PRESENT',
      },
    ],
    [
      'gear viết thường',
      {
        dog_visible: true,
        image_clear: true,
        muzzle: 'present',
        leash: 'present',
      },
    ],
    [
      'gear là null',
      { dog_visible: true, image_clear: true, muzzle: null, leash: 'PRESENT' },
    ],
  ];

  it.each(RAC)('%s thì docBaoCao trả null và không ném', (_ten, tho) => {
    expect(() => docBaoCao(tho)).not.toThrow();
    expect(docBaoCao(tho)).toBeNull();
  });

  it.each(RAC)('%s thì kết quả là chưa xác minh được', (_ten, tho) => {
    const ket = quetMotAnh(tho);
    expect(ket.trangThai).toBe('CHUA_XAC_MINH_DUOC');
    expect(ket.isSafe).toBe(false);
  });

  it('thiếu confidence vẫn đọc được, độ tin coi như 0', () => {
    const bc = docBaoCao({
      dog_visible: true,
      image_clear: true,
      muzzle: 'PRESENT',
      leash: 'PRESENT',
    });
    expect(bc?.confidence).toBe(0);
  });

  it('confidence ngoài khoảng bị kẹp về 0 đến 1', () => {
    const chung = { dog_visible: true, image_clear: true, muzzle: 'PRESENT' };
    expect(
      docBaoCao({ ...chung, leash: 'PRESENT', confidence: 9 })?.confidence,
    ).toBe(1);
    expect(
      docBaoCao({ ...chung, leash: 'PRESENT', confidence: -3 })?.confidence,
    ).toBe(0);
  });
});

describe('mã lỗi theo trạng thái HTTP', () => {
  it.each([
    [401, 'KHOA_API_KHONG_DUNG'],
    [403, 'KHOA_API_KHONG_DUNG'],
    [429, 'HET_HAN_MUC'],
    [408, 'QUA_HAN_CHO'],
    [504, 'QUA_HAN_CHO'],
    [400, 'LOI_DICH_VU_AI'],
    [500, 'LOI_DICH_VU_AI'],
    [503, 'LOI_DICH_VU_AI'],
  ] as [number, string][])('%s ra %s', (status, mong) => {
    expect(maLoiTheoTrangThai(status)).toBe(mong);
  });

  it('không có trạng thái, tức lỗi mạng, vẫn ra mã đọc được', () => {
    expect(maLoiTheoTrangThai(undefined)).toBe('LOI_DICH_VU_AI');
  });

  it('khoá sai và hết hạn mức không được lẫn nhau', () => {
    expect(maLoiTheoTrangThai(401)).not.toBe(maLoiTheoTrangThai(429));
  });

  it('mọi mã lỗi HTTP đều dẫn về chưa xác minh được', () => {
    for (const status of [401, 403, 408, 429, 500, 503, 504, undefined]) {
      const ket = chuaXacMinhDuoc(maLoiTheoTrangThai(status));
      expect(ket.trangThai).toBe('CHUA_XAC_MINH_DUOC');
      expect(ket.isSafe).toBe(false);
    }
  });
});

describe('hai kiểu chưa xác minh được đi hai đường khác nhau', () => {
  // Ảnh không dùng được thì chụp lại có ích, hệ thống hỏng thì tấm sau hỏng y hệt
  const ANH_KHONG_DUNG_DUOC = [
    'ANH_MO',
    'KHONG_THAY_CHO',
    'KHONG_RO_RO_MOM',
    'KHONG_RO_DAY_XICH',
  ] as (keyof typeof CAU_TIENG_VIET)[];

  const HE_THONG_HONG = [
    'THIEU_KHOA_API',
    'KHOA_API_KHONG_DUNG',
    'HET_HAN_MUC',
    'QUA_HAN_CHO',
    'LOI_DICH_VU_AI',
    'KET_QUA_KHONG_DOC_DUOC',
    'ANH_KHONG_TAI_DUOC',
    'ANH_QUA_LON',
    'KIEU_ANH_KHONG_HO_TRO',
  ] as (keyof typeof CAU_TIENG_VIET)[];

  it.each(ANH_KHONG_DUNG_DUOC)('%s trừ lượt chụp lại của bé', (ma) => {
    expect(laHeThongHong(ma)).toBe(false);
    expect(truLuotChupLai(ma)).toBe(true);
  });

  it.each(HE_THONG_HONG)('%s KHÔNG trừ lượt chụp lại của bé', (ma) => {
    expect(laHeThongHong(ma)).toBe(true);
    expect(truLuotChupLai(ma)).toBe(false);
  });

  it('mã kết luận thật của AI luôn trừ lượt, không lẫn sang nhóm hệ thống hỏng', () => {
    for (const ma of [
      'DAT',
      'THIEU_RO_MOM',
      'THIEU_DAY_XICH',
      'THIEU_CA_HAI',
    ] as (keyof typeof CAU_TIENG_VIET)[]) {
      expect(truLuotChupLai(ma)).toBe(true);
    }
  });

  it('mọi mã đều thuộc đúng một trong hai đường, không mã nào lọt ngoài', () => {
    const daXep = new Set([...ANH_KHONG_DUNG_DUOC, ...HE_THONG_HONG]);
    for (const ma of Object.keys(
      CAU_TIENG_VIET,
    ) as (keyof typeof CAU_TIENG_VIET)[]) {
      expect(laHeThongHong(ma)).toBe(HE_THONG_HONG.includes(ma));
      // Mã chưa xếp nhóm mà rơi vào nhánh trừ lượt là oan người chăm, phải cố ý mới được
      if (!daXep.has(ma)) expect(truLuotChupLai(ma)).toBe(true);
    }
  });

  it('mọi mã lỗi HTTP đều rơi vào nhóm hệ thống hỏng', () => {
    for (const status of [401, 403, 408, 429, 500, 503, 504, undefined]) {
      expect(laHeThongHong(maLoiTheoTrangThai(status))).toBe(true);
    }
  });
});

describe('câu tiếng Việt trả cho người chăm', () => {
  const MA = Object.keys(CAU_TIENG_VIET) as (keyof typeof CAU_TIENG_VIET)[];

  // Viết bằng mã điểm vì dấu kết hợp dán thẳng vào nguồn thì mắt thường không soi được
  const DAU_KET_HOP = new RegExp('[\\u0300-\\u036f]', 'g');

  function coDau(cau: string): boolean {
    return cau !== cau.normalize('NFD').replace(DAU_KET_HOP, '');
  }

  it.each(MA)('%s có câu tiếng Việt có dấu, không emoji', (ma) => {
    const cau = CAU_TIENG_VIET[ma];
    expect(cau.trim().length).toBeGreaterThan(0);
    expect(coDau(cau)).toBe(true);
    expect(/\p{Extended_Pictographic}/u.test(cau)).toBe(false);
  });

  it('mọi mã sinh ra từ luật kết luận đều có câu riêng, không rơi về câu mặc định', () => {
    const daGap = new Set<string>();
    for (const { bc } of TO_HOP) {
      const ket = ketLuanTuBaoCao(bc, {});
      daGap.add(ket.code);
      expect(ket.reason).not.toBe(CAU_MAC_DINH);
    }
    expect(daGap).toEqual(
      new Set([
        'DAT',
        'THIEU_RO_MOM',
        'THIEU_DAY_XICH',
        'THIEU_CA_HAI',
        'KHONG_THAY_CHO',
        'ANH_MO',
        'KHONG_RO_RO_MOM',
        'KHONG_RO_DAY_XICH',
      ]),
    );
  });

  it('mã của cụm tải ảnh và cụm gọi dịch vụ cũng có câu riêng', () => {
    for (const ma of [
      'ANH_KHONG_TAI_DUOC',
      'ANH_QUA_LON',
      'ANH_DO_PHAN_GIAI_THAP',
      'KIEU_ANH_KHONG_HO_TRO',
      'THIEU_KHOA_API',
      'KHOA_API_KHONG_DUNG',
      'HET_HAN_MUC',
      'QUA_HAN_CHO',
      'KET_QUA_KHONG_DOC_DUOC',
      'LOI_DICH_VU_AI',
    ] as (keyof typeof CAU_TIENG_VIET)[]) {
      expect(chuaXacMinhDuoc(ma).reason).not.toBe(CAU_MAC_DINH);
    }
  });

  it('thiếu khoá và hết hạn mức không được nói người chăm chụp lại vô ích', () => {
    expect(chuaXacMinhDuoc('THIEU_KHOA_API').reason).not.toMatch(/chụp lại/);
    expect(chuaXacMinhDuoc('HET_HAN_MUC').reason).not.toMatch(/chụp lại/);
  });

  it('giữ lại dấu vết để tra soát, không nhét payload thô', () => {
    const ket = ketLuanTuBaoCao(
      {
        dog_visible: true,
        image_clear: true,
        muzzle: 'PRESENT',
        leash: 'PRESENT',
        confidence: 0.8,
      },
      { nhaCungCap: 'anthropic', tokenVao: 1234 },
    );
    expect(ket.rawResponse).toMatchObject({ nhaCungCap: 'anthropic' });
  });
});
