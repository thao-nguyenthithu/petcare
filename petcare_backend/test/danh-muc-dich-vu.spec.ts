import { DanhMucDichVuService } from '../src/modules/admin/danh-muc-dich-vu.service';
import type { PrismaService } from '../src/prisma/prisma.service';

function dungDichVu(dong: Array<Record<string, unknown>>) {
  const dieuKien: unknown[] = [];
  const prisma = {
    service: {
      findMany: (arg: unknown) => {
        dieuKien.push(arg);
        return Promise.resolve(dong);
      },
    },
  };
  return {
    service: new DanhMucDichVuService(prisma as unknown as PrismaService),
    dieuKien,
  };
}

describe('Danh mục dịch vụ công khai', () => {
  it('trả đúng mô tả quản trị đã nhập ở màn 07', async () => {
    const { service } = dungDichVu([
      { type: 'WALKING', name: 'Dắt đi dạo', description: 'Đón bé tại nhà' },
    ]);

    const ketQua = await service.congKhai();

    expect(ketQua).toEqual([
      { type: 'WALKING', name: 'Dắt đi dạo', description: 'Đón bé tại nhà' },
    ]);
  });

  it('mô tả rỗng hoặc chỉ có khoảng trắng thì trả null để app dùng câu của mình', async () => {
    const { service } = dungDichVu([
      { type: 'WALKING', name: 'Dắt đi dạo', description: null },
      { type: 'BOARDING', name: 'Trông giữ', description: '   ' },
      { type: 'GROOMING', name: 'Tắm và cắt tỉa', description: '' },
    ]);

    const ketQua = await service.congKhai();

    expect(ketQua.map((d) => d.description)).toEqual([null, null, null]);
  });

  it('chỉ kéo về ba trường app cần, không lộ giá hay thời lượng', async () => {
    const { service, dieuKien } = dungDichVu([]);

    await service.congKhai();

    expect(dieuKien[0]).toEqual({
      select: { type: true, name: true, description: true },
      orderBy: { type: 'asc' },
    });
  });
});
