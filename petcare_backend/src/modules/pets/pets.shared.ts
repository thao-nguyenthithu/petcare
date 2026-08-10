import { BadRequestException, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { BookingStatus } from 'generated/prisma/enums';
import { PrismaService } from '../../prisma/prisma.service';
import { kiemTraAnh, type UploadedImage } from '../media/image-upload';
import { SupabaseService } from '../media/supabase.service';

export type { UploadedImage };

export const BUCKET_PET = 'pet-media';

// Đơn chưa kết thúc thì chặn xoá hồ sơ bé
export const DON_CHUA_XONG: BookingStatus[] = [
  BookingStatus.PENDING,
  BookingStatus.CONFIRMED,
  BookingStatus.AWAITING_OWNER_CONFIRM,
  BookingStatus.IN_PROGRESS,
];

// Lấy đủ hồ sơ một bé, kèm đơn chưa xong gần nhất để app chặn xoá từ sớm
export const HO_SO_DAY_DU = {
  photos: { orderBy: { sortOrder: 'asc' } },
  preventions: {
    orderBy: { createdAt: 'asc' },
    include: {
      doses: {
        orderBy: { doneAt: 'desc' },
        include: { photos: { orderBy: { createdAt: 'asc' } } },
      },
    },
  },
  bookings: {
    where: { booking: { status: { in: DON_CHUA_XONG } } },
    orderBy: { booking: { scheduledAt: 'desc' } },
    take: 1,
    select: {
      booking: {
        select: {
          id: true,
          code: true,
          scheduledAt: true,
          service: { select: { name: true } },
          sitter: {
            select: {
              user: { select: { fullName: true, avatarUrl: true } },
            },
          },
        },
      },
    },
  },
} as const;

export class PetsCommon {
  constructor(
    protected readonly prisma: PrismaService,
    protected readonly supabase: SupabaseService,
  ) {}

  // Hồ sơ đầy đủ của bé
  async layHoSo(userId: string, id: string) {
    const pet = await this.prisma.pet.findFirst({
      where: { id, ownerId: userId, isActive: true },
      include: HO_SO_DAY_DU,
    });
    if (!pet) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_THU_CUNG',
        message: 'Không tìm thấy hồ sơ thú cưng',
      });
    }
    return pet;
  }

  // Bé phải thuộc về đúng người đang đăng nhập
  protected async timCuaToi(userId: string, id: string) {
    const pet = await this.prisma.pet.findFirst({
      where: { id, ownerId: userId, isActive: true },
      select: { id: true },
    });
    if (!pet) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_THU_CUNG',
        message: 'Không tìm thấy hồ sơ thú cưng',
      });
    }
    return pet;
  }

  protected kiemTraCoAnh(files: UploadedImage[]) {
    if (!files?.length) {
      throw new BadRequestException({
        code: 'THIEU_ANH',
        message: 'Thiếu ảnh tải lên',
      });
    }
  }

  protected kiemTraGioiHanAnh(dangCo: number, them: number, toiDa: number) {
    if (dangCo + them > toiDa) {
      throw new BadRequestException({
        code: 'VUOT_GIOI_HAN_ANH',
        message: `Chỉ được tối đa ${toiDa} ảnh`,
      });
    }
  }

  protected async taiLenNhieu(files: UploadedImage[], thuMuc: string) {
    const daKiem = files.map((f) => ({ file: f, kieu: kiemTraAnh(f) }));
    await this.supabase.ensurePublicBucket(BUCKET_PET);
    const urls: string[] = [];
    for (const { file, kieu } of daKiem) {
      const path = `${thuMuc}/${randomUUID()}.${kieu.duoi}`;
      await this.supabase.uploadFile(
        BUCKET_PET,
        path,
        file.buffer!,
        kieu.contentType,
      );
      urls.push(this.supabase.getPublicUrl(BUCKET_PET, path));
    }
    return urls;
  }

  protected async xoaFileTheoUrl(urls: string[]) {
    for (const url of urls) {
      const path = url.split(`/${BUCKET_PET}/`)[1];
      if (!path) continue;
      try {
        await this.supabase.deleteFile(BUCKET_PET, path);
      } catch {
        // Xoá hụt một file trên storage không đáng chặn cả lượt xoá bản ghi
      }
    }
  }
}
