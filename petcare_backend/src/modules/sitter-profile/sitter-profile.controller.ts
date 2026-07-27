import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateSitterProfileDto } from './dto/create-sitter-profile.dto';
import {
  SitterProfileService,
  type UploadedImage,
} from './sitter-profile.service';

@ApiTags('sitter-profile')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('sitter-profile')
export class SitterProfileController {
  constructor(private readonly service: SitterProfileService) {}

  @Post()
  @ApiOperation({ summary: 'Gửi hồ sơ đăng ký nhà cung cấp, chờ duyệt 24h' })
  submit(
    @CurrentUser() user: { id: string },
    @Body() dto: CreateSitterProfileDto,
  ) {
    return this.service.submit(user.id, dto);
  }

  @Post('cccd')
  @ApiOperation({ summary: 'Tải ảnh CCCD lên kho lưu trữ (qua service key)' })
  @UseInterceptors(FileInterceptor('file'))
  uploadCccd(@UploadedFile() file: UploadedImage, @Body('mat') mat: string) {
    return this.service.uploadCccd(file, mat);
  }

  @Get('check-cccd')
  @ApiOperation({ summary: 'Kiểm tra số CCCD đã có ở hồ sơ người khác chưa' })
  checkCccd(
    @CurrentUser() user: { id: string },
    @Query('nationalId') nationalId: string,
  ) {
    return this.service.checkCccd(user.id, nationalId);
  }

  @Get('me')
  @ApiOperation({ summary: 'Xem trạng thái hồ sơ NCC của tôi' })
  getMine(@CurrentUser() user: { id: string }) {
    return this.service.getMine(user.id);
  }
}
