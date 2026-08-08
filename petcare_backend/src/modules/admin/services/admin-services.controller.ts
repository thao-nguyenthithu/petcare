import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  ParseEnumPipe,
  Patch,
  Put,
  Query,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { ServiceType } from '../../../../generated/prisma/enums';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminServicesReadService } from './admin-services-read.service';
import { AdminServicesWriteService } from './admin-services-write.service';
import {
  DatBatCauHinhDto,
  LocCauHinhDto,
  SuaDichVuDto,
} from './dto/loc-dich-vu.dto';

const PIPE_LOAI_DICH_VU = new ParseEnumPipe(ServiceType, {
  exceptionFactory: () =>
    new BadRequestException({
      code: 'LOAI_DICH_VU_KHONG_HOP_LE',
      message: 'Loại dịch vụ không hợp lệ',
    }),
});

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminServicesController {
  constructor(
    private readonly doc: AdminServicesReadService,
    private readonly ghi: AdminServicesWriteService,
  ) {}

  @Get('services')
  @ApiOperation({ summary: 'Ba loại dịch vụ và số người chăm đang bật' })
  danhMuc() {
    return this.doc.danhMuc();
  }

  @Get('service-constraints')
  @ApiOperation({ summary: 'Ràng buộc cố định, chỉ đổi được bằng lần deploy' })
  rangBuoc() {
    return this.doc.rangBuoc();
  }

  @Put('services/:type')
  @ApiOperation({ summary: 'Đổi tên và mô tả một loại dịch vụ' })
  suaDanhMuc(
    @CurrentUser() admin: QuanTriVien,
    @Param('type', PIPE_LOAI_DICH_VU) type: ServiceType,
    @Body() dto: SuaDichVuDto,
  ) {
    return this.ghi.suaDanhMuc(type, dto, admin.id);
  }

  @Get('sitter-services')
  @ApiOperation({ summary: 'Bảng giá từng người chăm đã khai' })
  cauHinh(@Query() loc: LocCauHinhDto) {
    return this.doc.cauHinh(loc);
  }

  @Patch('sitter-services/:id/enabled')
  @ApiOperation({ summary: 'Khoá hoặc mở lại một cấu hình giá' })
  datBat(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: DatBatCauHinhDto,
  ) {
    return this.ghi.datBat(id, dto.enabled, dto.reason, admin.id);
  }
}
