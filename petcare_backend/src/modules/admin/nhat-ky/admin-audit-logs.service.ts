import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { dungTrang, kepTrang } from '../chung/phan-trang';
import { LocNhatKyDto } from './dto/loc-nhat-ky.dto';

@Injectable()
export class AdminAuditLogsService {
  constructor(private readonly prisma: PrismaService) {}

  async danhSach(loc: LocNhatKyDto) {
    const khoang = kepTrang(loc.page, loc.limit);
    const where: Prisma.AdminAuditLogWhereInput = {
      ...(loc.action ? { action: loc.action } : {}),
      ...(loc.targetType ? { targetType: loc.targetType } : {}),
    };

    const [total, ds] = await Promise.all([
      this.prisma.adminAuditLog.count({ where }),
      this.prisma.adminAuditLog.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        // Không trả uuid của quản trị viên hay của đối tượng, bảng chỉ hiện mã đọc được
        select: {
          id: true,
          action: true,
          targetType: true,
          targetCode: true,
          reason: true,
          oldValue: true,
          newValue: true,
          createdAt: true,
          admin: { select: { fullName: true } },
        },
      }),
    ]);

    const items = ds.map(({ admin, ...ban }) => ({
      ...ban,
      adminName: admin.fullName,
    }));
    return dungTrang(items, total, khoang);
  }

  // Chỉ những mã ĐÃ có bản ghi, lọc theo mã chưa ai ghi thì luôn ra bảng rỗng
  async boLoc() {
    const [hanhDong, loaiDoiTuong] = await Promise.all([
      this.prisma.adminAuditLog.groupBy({ by: ['action'] }),
      this.prisma.adminAuditLog.groupBy({ by: ['targetType'] }),
    ]);
    return {
      actions: hanhDong.map((d) => d.action).sort(),
      targetTypes: loaiDoiTuong.map((d) => d.targetType).sort(),
    };
  }
}
