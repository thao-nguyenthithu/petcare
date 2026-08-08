import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  ParseUUIDPipe,
  Post,
  Query,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import {
  FileFieldsInterceptor,
  FilesInterceptor,
} from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SitterGuard } from '../../auth/guards/sitter.guard';
import { CAU_HINH_ANH, type UploadedImage } from '../../media/image-upload';
import { CheckinBatchDto, ToaDoDto } from './dto/checkin-batch.dto';
import {
  AcceptBookingDto,
  ArriveDto,
  DailyUpdateDto,
  FinishDto,
  HandoverDto,
  IncidentDto,
  LateReportDto,
  ListSitterBookingsDto,
  RejectBookingDto,
  SitterCancelDto,
} from './dto/sitter-order.dto';
import { PetSafetyScanReadService } from './pet-safety-scan-read.service';
import { PetSafetyScanService } from './pet-safety-scan.service';
import { SitterActionsService } from './sitter-actions.service';
import { SitterBookingsService } from './sitter-bookings.service';
import { SitterCancelService } from './sitter-cancel.service';
import { SitterSessionService } from './sitter-session.service';

const SO_ANH = 12;

const TRUONG_ANH_PHIEN = [
  { name: 'photos', maxCount: SO_ANH },
  { name: 'itemPhotos', maxCount: SO_ANH },
];

type AnhPhienTheoTruong = {
  photos?: UploadedImage[];
  itemPhotos?: UploadedImage[];
};

@ApiTags('sitter-orders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SitterGuard)
@Controller('sitter/bookings')
export class SitterOrdersController {
  constructor(
    private readonly bookings: SitterBookingsService,
    private readonly actions: SitterActionsService,
    private readonly session: SitterSessionService,
    private readonly cancel: SitterCancelService,
    private readonly scan: PetSafetyScanService,
    private readonly scanDoc: PetSafetyScanReadService,
  ) {}

  @Get()
  @ApiOperation({
    summary: 'Danh sách đơn của chính người chăm, lọc theo chip',
  })
  danhSach(
    @CurrentUser() user: { id: string },
    @Query() dto: ListSitterBookingsDto,
  ) {
    return this.bookings.danhSach(user.id, dto);
  }

  @Get('summary')
  @ApiOperation({
    summary:
      'Số đơn chờ xác nhận và giờ đơn kế tiếp, cho thẻ và sheet chuyển chế độ',
  })
  tomTat(@CurrentUser() user: { id: string }) {
    return this.bookings.tomTat(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Chi tiết một đơn của chính người chăm' })
  chiTiet(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookings.chiTiet(user.id, id);
  }

  @Post(':id/accept')
  @ApiOperation({ summary: 'Nhận đơn, đơn dắt phải kèm cam kết dụng cụ' })
  nhanDon(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AcceptBookingDto,
  ) {
    return this.actions.nhanDon(user.id, id, dto);
  }

  @Post(':id/reject')
  @ApiOperation({ summary: 'Từ chối đơn còn trong hạn nhận' })
  tuChoi(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RejectBookingDto,
  ) {
    return this.actions.tuChoi(user.id, id, dto);
  }

  @Post(':id/depart')
  @ApiOperation({ summary: 'Bấm xuất phát, mở trước giờ hẹn (bộ luật mục 5)' })
  xuatPhat(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.actions.xuatPhat(user.id, id);
  }

  @Post(':id/arrive')
  @ApiOperation({ summary: 'Bấm đã tới, server tự đo geofence 200 m' })
  daToi(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ArriveDto,
  ) {
    return this.actions.daToi(user.id, id, dto);
  }

  @Post(':id/late')
  @ApiOperation({ summary: 'Báo đến muộn, mỗi đơn một lần' })
  baoMuon(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: LateReportDto,
  ) {
    return this.actions.baoMuon(user.id, id, dto);
  }

  @Post(':id/gear-missing')
  @ApiOperation({
    summary: 'Báo bé thiếu rọ mõm hoặc dây xích, bắt buộc kèm ảnh thấy được bé',
  })
  @UseInterceptors(FilesInterceptor('photos', SO_ANH, CAU_HINH_ANH))
  baoThieuDungCu(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFiles() files: UploadedImage[],
  ) {
    return this.cancel.baoThieuDungCu(user.id, id, files);
  }

  @Post(':id/gear-cancel')
  @ApiOperation({ summary: 'Hết ân hạn dụng cụ, huỷ đơn và nhận bù công' })
  huyViThieuDungCu(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.cancel.huyViThieuDungCu(user.id, id);
  }

  @Post(':id/no-show')
  @ApiOperation({
    summary: 'Báo chủ nuôi vắng mặt sau khi chờ đủ 15 phút, bắt buộc kèm ảnh',
  })
  @UseInterceptors(FilesInterceptor('photos', SO_ANH, CAU_HINH_ANH))
  baoVangMat(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFiles() files: UploadedImage[],
  ) {
    return this.cancel.baoVangMat(user.id, id, files);
  }

  @Post(':id/cancel')
  @ApiOperation({ summary: 'Người chăm huỷ đơn đã nhận, chưa xuất phát' })
  huyDon(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SitterCancelDto,
  ) {
    return this.cancel.huyDon(user.id, id, dto);
  }

  @Post(':id/abort')
  @ApiOperation({
    summary: 'Không thể tiếp nhận sau khi đã xuất phát, bắt buộc kèm ảnh',
  })
  @UseInterceptors(FilesInterceptor('photos', SO_ANH, CAU_HINH_ANH))
  khongTheTiepNhan(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SitterCancelDto,
    @UploadedFiles() files: UploadedImage[],
  ) {
    return this.cancel.khongTheTiepNhan(user.id, id, dto, files);
  }

  @Post(':id/checkin-batch')
  @ApiOperation({
    summary: 'Gửi cả lô ảnh check-in, AI chấm nền rồi bắn kết quả qua socket',
  })
  @UseInterceptors(FilesInterceptor('photos', SO_ANH, CAU_HINH_ANH))
  guiLoAnh(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFiles() files: UploadedImage[],
    @Body() dto: CheckinBatchDto,
  ) {
    return this.scan.nhanLo(user.id, id, files, dto.slotIndexes, dto);
  }

  @Get(':id/checkin-batch/:batchId')
  @ApiOperation({ summary: 'Đọc lại kết quả một lô, dùng khi rớt socket' })
  docLoAnh(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Param('batchId', ParseUUIDPipe) batchId: string,
  ) {
    return this.scanDoc.docLo(user.id, id, batchId);
  }

  @Get(':id/safety-scan')
  @ApiOperation({
    summary: 'Trạng thái quét cả đàn, để mở lại ứng dụng vẫn đúng số lượt',
  })
  trangThaiQuet(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.scanDoc.trangThaiCaDan(user.id, id);
  }

  @Post(':id/slots/:slotIndex/self-confirm')
  @ApiOperation({
    summary: 'Người chăm tự xác nhận một bé, ghi kèm giờ và vị trí',
  })
  tuXacNhanSlot(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Param('slotIndex', ParseIntPipe) slotIndex: number,
    @Body() dto: ToaDoDto,
  ) {
    return this.scan.tuXacNhan(user.id, id, slotIndex, dto);
  }

  @Post(':id/check-in')
  @ApiOperation({ summary: 'Nhận bé và mở phiên, kèm ảnh check-in' })
  @UseInterceptors(FileFieldsInterceptor(TRUONG_ANH_PHIEN, CAU_HINH_ANH))
  batDauPhien(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFiles() files: AnhPhienTheoTruong,
    @Body() dto: HandoverDto,
  ) {
    return this.session.batDauPhien(
      user.id,
      id,
      files?.photos ?? [],
      dto,
      files?.itemPhotos ?? [],
    );
  }

  @Post(':id/incident')
  @ApiOperation({
    summary: 'Báo sự cố khi phiên đã chạy, chỉ mở hồ sơ cho đội hỗ trợ',
  })
  @UseInterceptors(FilesInterceptor('photos', SO_ANH, CAU_HINH_ANH))
  baoSuCo(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFiles() files: UploadedImage[],
    @Body() dto: IncidentDto,
  ) {
    return this.session.baoSuCo(user.id, id, files ?? [], dto);
  }

  @Post(':id/photos')
  @ApiOperation({ summary: 'Gửi ảnh cho chủ nuôi giữa phiên' })
  @UseInterceptors(FilesInterceptor('photos', SO_ANH, CAU_HINH_ANH))
  guiAnhPhien(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFiles() files: UploadedImage[],
  ) {
    return this.session.guiAnhPhien(user.id, id, files);
  }

  @Post(':id/daily-update')
  @ApiOperation({ summary: 'Bản cập nhật hằng ngày của kỳ trông giữ' })
  @UseInterceptors(FilesInterceptor('photos', SO_ANH, CAU_HINH_ANH))
  capNhatNgay(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFiles() files: UploadedImage[],
    @Body() dto: DailyUpdateDto,
  ) {
    return this.session.capNhatNgay(user.id, id, files, dto);
  }

  @Post(':id/finish')
  @ApiOperation({ summary: 'Kết thúc phiên, kèm ảnh và ghi chú gửi chủ nuôi' })
  @UseInterceptors(FileFieldsInterceptor(TRUONG_ANH_PHIEN, CAU_HINH_ANH))
  ketThuc(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFiles() files: AnhPhienTheoTruong,
    @Body() dto: FinishDto,
  ) {
    return this.session.ketThuc(
      user.id,
      id,
      files?.photos ?? [],
      dto,
      files?.itemPhotos ?? [],
    );
  }
}
