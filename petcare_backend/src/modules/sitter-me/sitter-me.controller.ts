import {
  Body,
  Controller,
  Delete,
  Get,
  Post,
  Put,
  UploadedFile,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { CAU_HINH_ANH } from '../media/image-upload';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { DeletePhotosDto } from './dto/delete-photos.dto';
import { UpdateSitterMeDto } from './dto/update-sitter-me.dto';
import { SitterMeService, type UploadedImage } from './sitter-me.service';

@ApiTags('sitter-profile-me')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('sitter/profile')
export class SitterMeController {
  constructor(private readonly service: SitterMeService) {}

  @Get()
  @ApiOperation({ summary: 'Xem trang cá nhân NCC (họ tên/giới thiệu/ảnh...)' })
  getProfile(@CurrentUser() user: { id: string }) {
    return this.service.getProfile(user.id);
  }

  @Put()
  @ApiOperation({ summary: 'Cập nhật họ tên/giới thiệu/số điện thoại' })
  update(@CurrentUser() user: { id: string }, @Body() dto: UpdateSitterMeDto) {
    return this.service.updateProfile(user.id, dto);
  }

  @Post('avatar')
  @ApiOperation({ summary: 'Tải ảnh đại diện' })
  @UseInterceptors(FileInterceptor('file', CAU_HINH_ANH))
  uploadAvatar(
    @CurrentUser() user: { id: string },
    @UploadedFile() file: UploadedImage,
  ) {
    return this.service.uploadAvatar(user.id, file);
  }

  @Post('photos')
  @ApiOperation({ summary: 'Thêm 1 hoặc nhiều ảnh vào thư viện (tối đa 20)' })
  @UseInterceptors(FilesInterceptor('files', 20, CAU_HINH_ANH))
  addPhotos(
    @CurrentUser() user: { id: string },
    @UploadedFiles() files: UploadedImage[],
  ) {
    return this.service.addPhotos(user.id, files);
  }

  @Delete('photos')
  @ApiOperation({ summary: 'Xoá 1 hoặc nhiều ảnh khỏi thư viện' })
  deletePhotos(
    @CurrentUser() user: { id: string },
    @Body() dto: DeletePhotosDto,
  ) {
    return this.service.deletePhotos(user.id, dto.ids);
  }
}
