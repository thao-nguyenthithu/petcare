import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';

@Injectable()
export class AddressesService {
  constructor(private readonly prisma: PrismaService) {}

  // Danh sách địa chỉ của tôi, giữ thứ tự theo thời gian tạo
  list(userId: string) {
    return this.prisma.address.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  // Thêm mới, địa chỉ đầu tiên tự thành mặc định
  async create(userId: string, dto: CreateAddressDto) {
    const soLuong = await this.prisma.address.count({ where: { userId } });
    return this.prisma.address.create({
      data: { userId, ...dto, isDefault: soLuong === 0 },
    });
  }

  // Sửa một địa chỉ
  async update(userId: string, id: string, dto: UpdateAddressDto) {
    await this.timCuaToi(userId, id);
    return this.prisma.address.update({ where: { id }, data: dto });
  }

  // Đặt làm mặc định, bỏ mặc định các địa chỉ khác
  async setDefault(userId: string, id: string) {
    await this.timCuaToi(userId, id);
    await this.prisma.$transaction([
      this.prisma.address.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      }),
      this.prisma.address.update({
        where: { id },
        data: { isDefault: true },
      }),
    ]);
    return { id, isDefault: true };
  }

  async remove(userId: string, id: string) {
    const diaChi = await this.timCuaToi(userId, id);
    await this.prisma.address.delete({ where: { id } });
    if (diaChi.isDefault) {
      const conLai = await this.prisma.address.findFirst({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      });
      if (conLai) {
        await this.prisma.address.update({
          where: { id: conLai.id },
          data: { isDefault: true },
        });
      }
    }
    return { id };
  }

  // Lấy địa chỉ và kiểm tra đúng, không thì báo không tìm thấy
  private async timCuaToi(userId: string, id: string) {
    const diaChi = await this.prisma.address.findUnique({ where: { id } });
    if (!diaChi || diaChi.userId !== userId) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DIA_CHI',
        message: 'Không tìm thấy địa chỉ',
      });
    }
    return diaChi;
  }
}
