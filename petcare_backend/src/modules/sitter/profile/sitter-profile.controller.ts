import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { THROTTLE_XAC_THUC } from '../../../common/gioi-han-ip/gioi-han-ip.constants';
import { CAU_HINH_ANH } from '../../media/image-upload';
import { Roles } from '../../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { CreateSitterProfileDto } from './dto/create-sitter-profile.dto';
import { ReviewSitterProfileDto } from './dto/review-sitter-profile.dto';
import {
  SitterProfileService,
  type UploadedImage,
} from './sitter-profile.service';

// Cố ý KHÔNG gắn SitterGuard vì đây là đường duy nhất để đăng ký làm người chăm
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
  @UseInterceptors(FileInterceptor('file', CAU_HINH_ANH))
  uploadCccd(@UploadedFile() file: UploadedImage, @Body('mat') mat: string) {
    return this.service.uploadCccd(file, mat);
  }

  @Get('check-cccd')
  @Throttle(THROTTLE_XAC_THUC)
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

  // Duyệt hồ sơ người khác nên userId nhận từ đường dẫn, chỉ quản trị viên gọi được
  @Patch(':userId/status')
  @UseGuards(RolesGuard)
  @Roles(['ADMIN'])
  @ApiOperation({ summary: 'Quản trị viên duyệt hoặc từ chối hồ sơ NCC' })
  review(@Param('userId') userId: string, @Body() dto: ReviewSitterProfileDto) {
    return this.service.review(userId, dto.status);
  }
}
