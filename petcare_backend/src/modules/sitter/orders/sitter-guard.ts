import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';

export async function layNccCuaToi(prisma: PrismaService, userId: string) {
  const ncc = await prisma.sitter.findUnique({
    where: { userId },
    select: {
      id: true,
      userId: true,
      hiddenUntil: true,
      hiddenCount: true,
      bannedAt: true,
    },
  });
  if (!ncc) {
    throw new ForbiddenException({
      code: 'CHUA_LA_NCC',
      message: 'Tài khoản chưa phải nhà cung cấp',
    });
  }
  if (ncc.bannedAt) {
    throw new ForbiddenException({
      code: 'TAI_KHOAN_NCC_BI_KHOA',
      message: 'Hồ sơ người chăm của bạn đã bị khoá',
    });
  }
  return ncc;
}

export function khongTimThayDon(): never {
  throw new NotFoundException({
    code: 'KHONG_TIM_THAY_DON',
    message: 'Không tìm thấy đơn này',
  });
}
