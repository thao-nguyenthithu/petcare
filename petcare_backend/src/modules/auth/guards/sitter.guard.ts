import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';

export interface NccDaDuyet {
  id: string;
  userId: string;
  hiddenUntil: Date | null;
  hiddenCount: number;
  bannedAt: Date | null;
}

@Injectable()
export class SitterGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<{
      user?: { id?: string };
      sitter?: NccDaDuyet;
    }>();
    const userId = request.user?.id;
    if (!userId) {
      throw new ForbiddenException({
        code: 'CHUA_DANG_NHAP',
        message: 'Phiên đăng nhập không hợp lệ',
      });
    }

    const ncc = await this.prisma.sitter.findUnique({
      where: { userId },
      select: {
        id: true,
        userId: true,
        status: true,
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
    if (ncc.status !== 'APPROVED') {
      throw new ForbiddenException({
        code: 'NCC_CHUA_DUOC_DUYET',
        message: 'Hồ sơ nhà cung cấp chưa được duyệt',
      });
    }
    if (ncc.bannedAt) {
      throw new ForbiddenException({
        code: 'TAI_KHOAN_NCC_BI_KHOA',
        message: 'Hồ sơ người chăm của bạn đã bị khoá',
      });
    }

    const { status, ...hoSo } = ncc;
    request.sitter = hoSo;
    return true;
  }
}
