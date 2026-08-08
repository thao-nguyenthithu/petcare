import { applyDecorators, UseGuards } from '@nestjs/common';
import { ApiBearerAuth } from '@nestjs/swagger';
import { Roles } from '../../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';

// Thiếu RolesGuard là mọi tài khoản đã đăng nhập đọc được dữ liệu người khác
export function QuanTri() {
  return applyDecorators(
    UseGuards(JwtAuthGuard, RolesGuard),
    Roles(['ADMIN']),
    ApiBearerAuth(),
  );
}

// Người đang đăng nhập, lấy từ JWT chứ không từ body
export type QuanTriVien = { id: string; role: string };
