import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateProviderProfileDto } from './dto/create-provider-profile.dto';

@Injectable()
export class ProviderProfileService {
  constructor(private readonly prisma: PrismaService) {}

  // Gửi hồ sơ đăng ký NCC
  async submit(userId: string, dto: CreateProviderProfileDto) {
    const daCo = await this.prisma.serviceProvider.findUnique({
      where: { userId },
    });
    // Đã được duyệt rồi thì không cho gửi lại
    if (daCo?.status === 'APPROVED') {
      throw new ConflictException({
        code: 'HO_SO_DA_DUYET',
        message: 'Hồ sơ đã được duyệt, không thể gửi lại',
      });
    }
    // CCCD đã có ở hồ sơ của người khác
    const trungCccd = await this.prisma.serviceProvider.findUnique({
      where: { nationalId: dto.nationalId },
    });
    if (trungCccd && trungCccd.userId !== userId) {
      throw new ConflictException({
        code: 'CCCD_DA_DANG_KY',
        message: 'Số CCCD đã được đăng ký',
      });
    }

    const duLieu = {
      legalName: dto.legalName,
      gender: dto.gender,
      dateOfBirth: new Date(dto.dateOfBirth),
      nationalId: dto.nationalId,
      idIssuedPlace: dto.idIssuedPlace,
      idIssuedDate: new Date(dto.idIssuedDate),
      province: dto.province,
      addressDetail: dto.addressDetail,
      cccdFrontPath: dto.cccdFrontPath,
      cccdBackPath: dto.cccdBackPath,
      status: 'PENDING' as const,
      submittedAt: new Date(),
    };

    const hoSo = await this.prisma.serviceProvider.upsert({
      where: { userId },
      create: { userId, ...duLieu },
      update: duLieu,
    });
    return { status: hoSo.status, submittedAt: hoSo.submittedAt };
  }

  // Kiểm tra CCCD đã có ở hồ sơ người khác chưa
  async checkCccd(userId: string, nationalId: string) {
    const daCo = await this.prisma.serviceProvider.findUnique({
      where: { nationalId },
    });
    return { available: !daCo || daCo.userId === userId };
  }

  // Xem trạng thái hồ sơ của người dùng hiện tại
  async getMine(userId: string) {
    const hoSo = await this.prisma.serviceProvider.findUnique({
      where: { userId },
      select: {
        status: true,
        legalName: true,
        submittedAt: true,
        cccdFrontPath: true,
        cccdBackPath: true,
      },
    });
    if (!hoSo) {
      throw new NotFoundException({
        code: 'CHUA_CO_HO_SO',
        message: 'Chưa có hồ sơ nhà cung cấp',
      });
    }
    return hoSo;
  }
}
