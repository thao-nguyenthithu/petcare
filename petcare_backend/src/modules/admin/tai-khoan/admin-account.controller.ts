import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminAccountService } from './admin-account.service';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminAccountController {
  constructor(private readonly doc: AdminAccountService) {}

  // Không nhận id từ query hay body: nhận từ client là đọc được hồ sơ người khác
  @Get('account')
  @ApiOperation({ summary: 'Tài khoản quản trị đang đăng nhập' })
  layCuaToi(@CurrentUser() quanTri: QuanTriVien) {
    return this.doc.layCuaToi(quanTri.id);
  }
}
