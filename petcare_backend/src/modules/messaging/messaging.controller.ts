import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CAU_HINH_ANH, type UploadedImage } from '../media/image-upload';
import { ChatPhotoService } from './chat-photo.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SendMessageDto } from './dto/send-message.dto';
import { MessagingGateway } from './messaging.gateway';
import { tinTheoVai, type VaiChat } from './messaging.mapper';
import { MessagingService } from './messaging.service';

@ApiTags('messaging')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('conversations')
export class MessagingController {
  constructor(
    private readonly service: MessagingService,
    private readonly photos: ChatPhotoService,
    private readonly gateway: MessagingGateway,
  ) {}

  private docVai(vai?: string): VaiChat {
    return vai === 'PROVIDER' || vai === 'sitter' ? 'PROVIDER' : 'OWNER';
  }

  @Get()
  @ApiOperation({ summary: 'Danh sách hội thoại của một vai' })
  danhSach(@CurrentUser() user: { id: string }, @Query('vai') vai?: string) {
    return this.service.danhSach(user.id, this.docVai(vai));
  }

  @Get('unread-count')
  @ApiOperation({ summary: 'Tổng tin chưa đọc, cho badge tab Tin nhắn' })
  demChuaDoc(@CurrentUser() user: { id: string }, @Query('vai') vai?: string) {
    return this.service.demChuaDoc(user.id, this.docVai(vai));
  }

  @Get('by-booking/:bookingId')
  @ApiOperation({ summary: 'Hội thoại của một đơn, mở từ màn chi tiết đơn' })
  theoDon(
    @CurrentUser() user: { id: string },
    @Param('bookingId') bookingId: string,
    @Query('vai') vai?: string,
  ) {
    return this.service.theoDon(user.id, bookingId, this.docVai(vai));
  }

  @Get(':id/messages')
  @ApiOperation({ summary: 'Một trang tin theo con trỏ thời gian' })
  tinNhan(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Query('truoc') truoc?: string,
  ) {
    return this.service.tinNhan(user.id, id, truoc);
  }

  @Post(':id/messages')
  @ApiOperation({ summary: 'Gửi một tin' })
  async gui(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() dto: SendMessageDto,
  ) {
    const ketQua = await this.service.gui(user.id, id, dto);
    await this.gateway.phatTinMoi(
      ketQua.conversationId,
      ketQua.tin,
      ketQua.kyAnh,
    );
    return tinTheoVai(ketQua.tin, ketQua.vaiNguoiGui, user.id, ketQua.kyAnh);
  }

  @Post(':id/photos')
  @ApiOperation({ summary: 'Gửi một lô ảnh trong chat' })
  @UseInterceptors(FilesInterceptor('photos', 6, CAU_HINH_ANH))
  async guiAnh(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @UploadedFiles() files: UploadedImage[],
    @Body('caption') caption?: string,
  ) {
    const ketQua = await this.photos.gui(user.id, id, files, caption);
    await this.gateway.phatTinMoi(
      ketQua.conversationId,
      ketQua.tin,
      ketQua.kyAnh,
    );
    return tinTheoVai(ketQua.tin, ketQua.vaiNguoiGui, user.id, ketQua.kyAnh);
  }

  @Post(':id/read')
  @ApiOperation({ summary: 'Đánh dấu đã đọc toàn bộ hội thoại' })
  async danhDauDaDoc(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
  ) {
    const ketQua = await this.service.danhDauDaDoc(user.id, id);
    this.gateway.phatDaDoc(id, user.id);
    return ketQua;
  }
}
