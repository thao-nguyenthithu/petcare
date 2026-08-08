import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { MAX_PET_MOI_CHU } from '../../pets/pets.service';
import {
  MAX_HANG_MUC_MOI_BE,
  MAX_LAN_MOI_HANG_MUC,
} from '../../pets/preventions.service';

@Injectable()
export class AdminPetsService {
  constructor(private readonly prisma: PrismaService) {}

  // Sổ phòng bệnh tải riêng theo bé đang chọn, gộp vào đây là payload vô dụng
  async cuaChuNuoi(ownerId: string) {
    const [chu, ds] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id: ownerId },
        select: { id: true },
      }),
      this.prisma.pet.findMany({
        where: { ownerId },
        orderBy: { createdAt: 'desc' },
        take: MAX_PET_MOI_CHU,
        select: {
          id: true,
          name: true,
          species: true,
          breed: true,
          gender: true,
          birthDate: true,
          weightKg: true,
          isNeutered: true,
          underTreatment: true,
          chronicDisease: true,
          medication: true,
          careNote: true,
          avatarUrl: true,
          isActive: true,
          photos: {
            orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
            select: { id: true, url: true, sortOrder: true },
          },
          _count: { select: { preventions: true } },
        },
      }),
    ]);
    if (!chu) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_NGUOI_DUNG',
        message: 'Không tìm thấy người dùng này',
      });
    }
    return {
      items: ds.map(({ _count, ...pet }) => ({
        ...pet,
        preventionCount: _count.preventions,
      })),
    };
  }

  async soPhongBenh(petId: string) {
    const [pet, records] = await Promise.all([
      this.prisma.pet.findUnique({
        where: { id: petId },
        select: { id: true },
      }),
      this.prisma.preventionRecord.findMany({
        where: { petId },
        orderBy: { createdAt: 'asc' },
        take: MAX_HANG_MUC_MOI_BE,
        select: {
          id: true,
          code: true,
          customName: true,
          form: true,
          doses: {
            orderBy: { doneAt: 'desc' },
            take: MAX_LAN_MOI_HANG_MUC,
            select: {
              id: true,
              doneAt: true,
              place: true,
              nextDueAt: true,
              photos: { select: { url: true } },
            },
          },
        },
      }),
    ]);
    if (!pet) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_THU_CUNG',
        message: 'Không tìm thấy hồ sơ thú cưng này',
      });
    }
    return {
      items: records.map((r) => ({
        ...r,
        doses: r.doses.map((d) => ({
          id: d.id,
          doneAt: d.doneAt,
          place: d.place,
          nextDueAt: d.nextDueAt,
          photos: d.photos.map((a) => a.url),
        })),
      })),
    };
  }
}
