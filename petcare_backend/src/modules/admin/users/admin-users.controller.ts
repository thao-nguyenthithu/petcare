import { Body, Controller, Get, Param, Patch, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { DatTrangThaiDto } from '../chung/dto/dat-trang-thai.dto';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminPetsService } from './admin-pets.service';
import { AdminUserDetailService } from './admin-user-detail.service';
import { AdminUsersReadService } from './admin-users-read.service';
import { AdminUsersWriteService } from './admin-users-write.service';
import { LocNguoiDungDto } from './dto/loc-nguoi-dung.dto';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminUsersController {
  constructor(
    private readonly doc: AdminUsersReadService,
    private readonly chiTiet: AdminUserDetailService,
    private readonly ghi: AdminUsersWriteService,
    private readonly thuCung: AdminPetsService,
  ) {}

  @Get('users')
  @ApiOperation({ summary: 'Danh sách người dùng, lọc và phân trang' })
  danhSach(@Query() loc: LocNguoiDungDto) {
    return this.doc.danhSach(loc);
  }

  // Phải khai TRƯỚC users/:id, không thì counts rơi vào lối chi tiết
  @Get('users/counts')
  @ApiOperation({ summary: 'Số đếm bốn tab của màn người dùng' })
  demTab() {
    return this.doc.demTab();
  }

  @Get('provinces')
  @ApiOperation({ summary: 'Danh mục tỉnh dựng từ địa chỉ mặc định đang có' })
  danhSachTinh() {
    return this.doc.danhSachTinh();
  }

  @Get('users/:id')
  @ApiOperation({ summary: 'Hồ sơ một người dùng kèm chỉ số và đơn gần nhất' })
  xem(@Param('id') id: string) {
    return this.chiTiet.chiTiet(id);
  }

  @Get('users/:id/pets')
  @ApiOperation({ summary: 'Hồ sơ thú cưng của một chủ nuôi' })
  danhSachThuCung(@Param('id') id: string) {
    return this.thuCung.cuaChuNuoi(id);
  }

  @Get('pets/:id/preventions')
  @ApiOperation({ summary: 'Sổ phòng bệnh của một bé' })
  soPhongBenh(@Param('id') id: string) {
    return this.thuCung.soPhongBenh(id);
  }

  @Patch('users/:id/active')
  @ApiOperation({ summary: 'Khoá hoặc mở khoá một tài khoản' })
  datTrangThai(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: DatTrangThaiDto,
  ) {
    return this.ghi.datTrangThai(id, dto.isActive, dto.reason, admin.id);
  }

  @Patch('pets/:id/active')
  @ApiOperation({ summary: 'Ẩn hoặc hiện lại một hồ sơ thú cưng' })
  datTrangThaiThuCung(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: DatTrangThaiDto,
  ) {
    return this.ghi.datTrangThaiThuCung(id, dto.isActive, dto.reason, admin.id);
  }
}
