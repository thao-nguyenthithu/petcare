import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateDoseDto } from './dto/create-dose.dto';
import { CreatePetDto } from './dto/create-pet.dto';
import { CreatePreventionDto } from './dto/create-prevention.dto';
import { DeletePhotosDto } from './dto/delete-photos.dto';
import { UpdateDoseDto } from './dto/update-dose.dto';
import { UpdatePetDto } from './dto/update-pet.dto';
import { PetsService } from './pets.service';
import { CAU_HINH_ANH } from '../media/image-upload';
import { type UploadedImage } from './pets.shared';
import { PreventionsService } from './preventions.service';

@ApiTags('pets')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('pets')
export class PetsController {
  constructor(
    private readonly service: PetsService,
    private readonly phongBenh: PreventionsService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Danh sách thú cưng của tôi' })
  list(@CurrentUser() user: { id: string }) {
    return this.service.list(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Hồ sơ chi tiết một bé' })
  detail(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.service.detail(user.id, id);
  }

  @Post()
  @ApiOperation({ summary: 'Thêm hồ sơ thú cưng' })
  create(@CurrentUser() user: { id: string }, @Body() dto: CreatePetDto) {
    return this.service.create(user.id, dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Sửa hồ sơ thú cưng' })
  update(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() dto: UpdatePetDto,
  ) {
    return this.service.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Xoá hồ sơ thú cưng' })
  remove(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.service.remove(user.id, id);
  }

  @Post(':id/photos')
  @ApiOperation({ summary: 'Thêm ảnh vào dải ảnh của bé (tối đa 10)' })
  @UseInterceptors(FilesInterceptor('files', 10, CAU_HINH_ANH))
  addPhotos(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @UploadedFiles() files: UploadedImage[],
  ) {
    return this.service.addPhotos(user.id, id, files);
  }

  @Delete(':id/photos')
  @ApiOperation({ summary: 'Xoá ảnh của bé' })
  deletePhotos(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() dto: DeletePhotosDto,
  ) {
    return this.service.deletePhotos(user.id, id, dto.ids);
  }

  @Patch(':id/photos/:photoId/avatar')
  @ApiOperation({ summary: 'Đặt ảnh làm đại diện của bé' })
  setAvatar(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Param('photoId') photoId: string,
  ) {
    return this.service.setAvatar(user.id, id, photoId);
  }

  @Post(':id/preventions')
  @ApiOperation({ summary: 'Thêm hạng mục phòng bệnh cho bé' })
  createPrevention(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() dto: CreatePreventionDto,
  ) {
    return this.phongBenh.create(user.id, id, dto);
  }

  @Delete(':id/preventions/:recordId')
  @ApiOperation({ summary: 'Xoá cả hạng mục phòng bệnh' })
  removePrevention(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Param('recordId') recordId: string,
  ) {
    return this.phongBenh.remove(user.id, id, recordId);
  }

  @Post(':id/preventions/:recordId/doses')
  @ApiOperation({ summary: 'Ghi một lần đã làm của hạng mục' })
  createDose(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Param('recordId') recordId: string,
    @Body() dto: CreateDoseDto,
  ) {
    return this.phongBenh.createDose(user.id, id, recordId, dto);
  }

  @Put(':id/preventions/:recordId/doses/:doseId')
  @ApiOperation({ summary: 'Sửa một lần đã ghi' })
  updateDose(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Param('recordId') recordId: string,
    @Param('doseId') doseId: string,
    @Body() dto: UpdateDoseDto,
  ) {
    return this.phongBenh.updateDose(user.id, id, recordId, doseId, dto);
  }

  @Delete(':id/preventions/:recordId/doses/:doseId')
  @ApiOperation({ summary: 'Xoá riêng một lần đã ghi' })
  removeDose(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Param('recordId') recordId: string,
    @Param('doseId') doseId: string,
  ) {
    return this.phongBenh.removeDose(user.id, id, recordId, doseId);
  }

  @Post(':id/preventions/:recordId/doses/:doseId/photos')
  @ApiOperation({ summary: 'Thêm ảnh phiếu cho một lần ghi (tối đa 5)' })
  @UseInterceptors(FilesInterceptor('files', 5, CAU_HINH_ANH))
  addDosePhotos(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Param('recordId') recordId: string,
    @Param('doseId') doseId: string,
    @UploadedFiles() files: UploadedImage[],
  ) {
    return this.phongBenh.addDosePhotos(user.id, id, recordId, doseId, files);
  }

  @Delete(':id/preventions/:recordId/doses/:doseId/photos')
  @ApiOperation({ summary: 'Xoá ảnh phiếu của một lần ghi' })
  deleteDosePhotos(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Param('recordId') recordId: string,
    @Param('doseId') doseId: string,
    @Body() dto: DeletePhotosDto,
  ) {
    return this.phongBenh.deleteDosePhotos(
      user.id,
      id,
      recordId,
      doseId,
      dto.ids,
    );
  }
}
