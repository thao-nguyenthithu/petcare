import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';

@Injectable()
export class AdminAccountService {
  constructor(private readonly prisma: PrismaService) {}

  async layCuaToi(adminId: string) {
    const [taiKhoan, nhatKy] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id: adminId },
        // Không lấy passwordHash, số điện thoại hay ngày sinh: card không hiện
        select: {
          id: true,
          fullName: true,
          email: true,
          avatarUrl: true,
          createdAt: true,
          passwordChangedAt: true,
        },
      }),
      this.prisma.adminAuditLog.aggregate({
        where: { adminId },
        _count: { _all: true },
        _max: { createdAt: true },
      }),
    ]);

    if (!taiKhoan) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_TAI_KHOAN',
        message: 'Không tìm thấy tài khoản quản trị',
      });
    }

    return {
      id: taiKhoan.id,
      hoTen: taiKhoan.fullName,
      email: taiKhoan.email,
      avatarUrl: taiKhoan.avatarUrl,
      taoLuc: taiKhoan.createdAt,
      // Rỗng nghĩa là chưa đổi lần nào kể từ lúc tạo tài khoản
      doiMatKhauLuc: taiKhoan.passwordChangedAt,
      soThaoTacDaGhi: nhatKy._count._all,
      thaoTacGanNhatLuc: nhatKy._max.createdAt,
    };
  }
}
