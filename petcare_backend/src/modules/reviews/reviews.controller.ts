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
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { NccHienTai } from '../auth/decorators/sitter.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SitterGuard, type NccDaDuyet } from '../auth/guards/sitter.guard';
import { CAU_HINH_ANH, type UploadedImage } from '../media/image-upload';
import { CreateReviewDto, SO_ANH_DANH_GIA } from './dto/create-review.dto';
import { ReplyReviewDto } from './dto/reply-review.dto';
import { ReviewsService } from './reviews.service';

// Đánh giá nhìn từ vai chủ nuôi, vai người chăm ở SitterReviewsController
@ApiTags('reviews')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class ReviewsController {
  constructor(private readonly service: ReviewsService) {}

  @Get('sitters/:id/reviews')
  @ApiOperation({ summary: 'Đánh giá của một người chăm, kèm số liệu tổng' })
  cuaNguoiCham(
    @Param('id') sitterId: string,
    @Query('truoc') truoc?: string,
    @Query('rating') rating?: string,
    @Query('service') service?: string,
    @Query('coAnh') coAnh?: string,
  ) {
    return this.service.cuaNguoiCham(sitterId, {
      truoc,
      rating: rating ? Number(rating) : undefined,
      service,
      coAnh: coAnh === 'true',
    });
  }

  @Get('reviews/mine')
  @ApiOperation({ summary: 'Đánh giá chính tôi đã viết' })
  cuaToi(@CurrentUser() user: { id: string }, @Query('truoc') truoc?: string) {
    return this.service.cuaToi(user.id, truoc);
  }

  // Đặt dưới tiền tố reviews vì bookings/:id đăng ký trước sẽ nuốt đường dẫn kia
  @Get('reviews/pending')
  @ApiOperation({ summary: 'Đơn đã xong mà tôi chưa đánh giá, còn trong hạn' })
  choDanhGia(@CurrentUser() user: { id: string }) {
    return this.service.donChoDanhGia(user.id);
  }

  @Post('bookings/:id/review')
  @ApiOperation({ summary: 'Viết đánh giá cho một đơn đã xong, kèm ảnh' })
  @UseInterceptors(FilesInterceptor('photos', SO_ANH_DANH_GIA, CAU_HINH_ANH))
  viet(
    @CurrentUser() user: { id: string },
    @Param('id') bookingId: string,
    @UploadedFiles() files: UploadedImage[],
    @Body() dto: CreateReviewDto,
  ) {
    return this.service.viet(user.id, bookingId, dto, files ?? []);
  }
}

@ApiTags('reviews')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SitterGuard)
@Controller('sitter/reviews')
export class SitterReviewsController {
  constructor(private readonly service: ReviewsService) {}

  @Get()
  @ApiOperation({ summary: 'Đánh giá về tôi' })
  veToi(@NccHienTai() ncc: NccDaDuyet, @Query('truoc') truoc?: string) {
    return this.service.veToi(ncc.id, { truoc });
  }

  @Post(':id/reply')
  @ApiOperation({ summary: 'Đáp lại một đánh giá, mỗi đánh giá một lần' })
  phanHoi(
    @NccHienTai() ncc: NccDaDuyet,
    @Param('id') reviewId: string,
    @Body() dto: ReplyReviewDto,
  ) {
    return this.service.phanHoi(ncc.id, reviewId, dto);
  }
}
