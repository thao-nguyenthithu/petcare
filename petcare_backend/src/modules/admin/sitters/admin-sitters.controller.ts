import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminPenaltiesService } from './admin-penalties.service';
import { AdminSittersReadService } from './admin-sitters-read.service';
import { AdminSittersWriteService } from './admin-sitters-write.service';
import { LocKyLuatDto, SoatPhatDto } from './dto/loc-ky-luat.dto';
import {
  DuyetHoSoDto,
  KhoaVinhVienDto,
  LocNguoiChamDto,
  TamAnDto,
  YeuCauBoSungDto,
} from './dto/loc-nguoi-cham.dto';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminSittersController {
  constructor(
    private readonly doc: AdminSittersReadService,
    private readonly ghi: AdminSittersWriteService,
    private readonly kyLuat: AdminPenaltiesService,
  ) {}

  @Get('sitters')
  @ApiOperation({ summary: 'Danh sách hồ sơ người chăm theo bốn tab' })
  danhSach(@Query() loc: LocNguoiChamDto) {
    return this.doc.danhSach(loc);
  }

  // Khai TRƯỚC sitters/:id để counts không rơi vào lối chi tiết
  @Get('sitters/counts')
  @ApiOperation({ summary: 'Số đếm các tab hồ sơ người chăm' })
  demTab() {
    return this.doc.demTab();
  }

  @Get('sitters/:id')
  @ApiOperation({ summary: 'Chi tiết một hồ sơ người chăm' })
  chiTiet(@Param('id') id: string) {
    return this.doc.chiTiet(id);
  }

  @Patch('sitters/:id/status')
  @ApiOperation({ summary: 'Duyệt hoặc từ chối hồ sơ, từ chối bắt ghi lý do' })
  duyet(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: DuyetHoSoDto,
  ) {
    return this.ghi.duyetHoSo(id, dto, admin.id);
  }

  @Post('sitters/:id/supplement-request')
  @ApiOperation({ summary: 'Nhắn người chăm bổ sung, hồ sơ vẫn nằm chờ duyệt' })
  yeuCauBoSung(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: YeuCauBoSungDto,
  ) {
    return this.ghi.yeuCauBoSung(id, dto.reason, admin.id);
  }

  @Patch('sitters/:id/hidden')
  @ApiOperation({ summary: 'Tạm ẩn hồ sơ bằng tay, cộng vào số lần đã ẩn' })
  tamAn(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: TamAnDto,
  ) {
    return this.ghi.tamAn(id, dto.days, dto.reason, admin.id);
  }

  @Patch('sitters/:id/ban')
  @ApiOperation({ summary: 'Khoá vĩnh viễn hoặc gỡ khoá hồ sơ người chăm' })
  khoa(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: KhoaVinhVienDto,
  ) {
    return this.ghi.datKhoaVinhVien(id, dto.banned, dto.reason, admin.id);
  }

  @Get('penalties')
  @ApiOperation({ summary: 'Hàng chờ soát kỷ luật người chăm' })
  danhSachPhat(@Query() loc: LocKyLuatDto) {
    return this.kyLuat.danhSach(loc);
  }

  @Get('penalties/counts')
  @ApiOperation({ summary: 'Số đếm các tab kỷ luật' })
  demTabPhat() {
    return this.kyLuat.demTab();
  }

  @Patch('penalties/:id/review')
  @ApiOperation({ summary: 'Kết luận một đơn xin miễn phạt' })
  soat(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: SoatPhatDto,
  ) {
    return this.kyLuat.soat(id, dto.waived, dto.note, admin.id);
  }
}
