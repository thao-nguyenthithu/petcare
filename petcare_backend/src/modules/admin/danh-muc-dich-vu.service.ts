import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export type DichVuCongKhai = {
  type: string;
  name: string;
  description: string | null;
};

// Danh mục ba dịch vụ cho app đọc, quản trị sửa tên và mô tả ở màn 07
@Injectable()
export class DanhMucDichVuService {
  constructor(private readonly prisma: PrismaService) {}

  async congKhai(): Promise<DichVuCongKhai[]> {
    const ds = await this.prisma.service.findMany({
      select: { type: true, name: true, description: true },
      orderBy: { type: 'asc' },
    });
    return ds.map((d) => ({
      type: d.type,
      name: d.name,
      // Chưa ai nhập thì để rỗng, app tự dùng câu mặc định của mình
      description: d.description?.trim() ? d.description : null,
    }));
  }
}
