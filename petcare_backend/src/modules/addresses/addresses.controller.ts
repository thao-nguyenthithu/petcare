import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AddressesService } from './addresses.service';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';

@ApiTags('addresses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('addresses')
export class AddressesController {
  constructor(private readonly service: AddressesService) {}

  @Get()
  @ApiOperation({ summary: 'Danh sách địa chỉ đã lưu của tôi' })
  list(@CurrentUser() user: { id: string }) {
    return this.service.list(user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Thêm địa chỉ mới (lấy từ bản đồ)' })
  create(@CurrentUser() user: { id: string }, @Body() dto: CreateAddressDto) {
    return this.service.create(user.id, dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Sửa địa chỉ' })
  update(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() dto: UpdateAddressDto,
  ) {
    return this.service.update(user.id, id, dto);
  }

  @Patch(':id/default')
  @ApiOperation({ summary: 'Đặt địa chỉ làm mặc định' })
  setDefault(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.service.setDefault(user.id, id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Xoá địa chỉ' })
  remove(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.service.remove(user.id, id);
  }
}
