import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { BookingStatus } from 'generated/prisma/enums';
import { soTuoi } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { SupabaseService } from '../media/supabase.service';
import { CreatePetDto, TUOI_BE_TOI_DA } from './dto/create-pet.dto';
import { UpdatePetDto } from './dto/update-pet.dto';
import { HO_SO_DAY_DU, PetsCommon, type UploadedImage } from './pets.shared';

// Dải ảnh của bé tối đa
export const MAX_PET_PHOTOS = 10;

export const MAX_PET_MOI_CHU = 20;

// Đơn chưa kết thúc thì chặn xoá hồ sơ bé
const DON_CHUA_XONG: BookingStatus[] = [
  BookingStatus.PENDING,
  BookingStatus.CONFIRMED,
  BookingStatus.AWAITING_OWNER_CONFIRM,
  BookingStatus.IN_PROGRESS,
];

@Injectable()
export class PetsService extends PetsCommon {
  constructor(prisma: PrismaService, supabase: SupabaseService) {
    super(prisma, supabase);
  }

  // GET /pets danh sách bé còn hiệu lực
  list(userId: string) {
    return this.prisma.pet.findMany({
      where: { ownerId: userId, isActive: true },
      orderBy: { createdAt: 'asc' },
      include: HO_SO_DAY_DU,
    });
  }

  // GET /pets/:id hồ sơ một bé
  detail(userId: string, id: string) {
    return this.layHoSo(userId, id);
  }

  // POST /pets tạo hồ sơ bé
  async create(userId: string, dto: CreatePetDto) {
    const dangCo = await this.prisma.pet.count({
      where: { ownerId: userId, isActive: true },
    });
    if (dangCo >= MAX_PET_MOI_CHU) {
      throw new BadRequestException({
        code: 'VUOT_GIOI_HAN_THU_CUNG',
        message: `Mỗi tài khoản chỉ giữ tối đa ${MAX_PET_MOI_CHU} hồ sơ thú cưng`,
      });
    }
    const { birthDate, ...conLai } = dto;
    this.kiemTraNgaySinh(birthDate);
    return this.prisma.pet.create({
      data: {
        ownerId: userId,
        ...conLai,
        birthDate: birthDate ? new Date(birthDate) : null,
      },
      include: HO_SO_DAY_DU,
    });
  }

  private kiemTraNgaySinh(birthDate?: string) {
    if (!birthDate) return;
    const luc = new Date(birthDate);
    if (Number.isNaN(luc.getTime()) || luc.getTime() > Date.now()) {
      throw new BadRequestException({
        code: 'NGAY_SINH_KHONG_HOP_LE',
        message: 'Ngày sinh của bé phải là một ngày đã qua',
      });
    }
    if (soTuoi(luc) > TUOI_BE_TOI_DA) {
      throw new BadRequestException({
        code: 'TUOI_BE_QUA_LON',
        message: `Tuổi của bé không quá ${TUOI_BE_TOI_DA}`,
      });
    }
  }

  // PUT /pets/:id sửa hồ sơ
  async update(userId: string, id: string, dto: UpdatePetDto) {
    await this.timCuaToi(userId, id);
    const { birthDate, ...conLai } = dto;
    this.kiemTraNgaySinh(birthDate);
    return this.prisma.pet.update({
      where: { id },
      data: {
        ...conLai,
        ...(birthDate === undefined
          ? {}
          : { birthDate: birthDate ? new Date(birthDate) : null }),
      },
      include: HO_SO_DAY_DU,
    });
  }

  // DELETE /pets/:id xoá để đơn cũ vẫn tra được thông tin bé
  async remove(userId: string, id: string) {
    await this.timCuaToi(userId, id);
    const dangChay = await this.prisma.bookingPet.findFirst({
      where: { petId: id, booking: { status: { in: DON_CHUA_XONG } } },
      select: { bookingId: true },
    });
    if (dangChay) {
      throw new BadRequestException({
        code: 'BE_DANG_CO_DON',
        message: 'Bé đang có đơn chưa kết thúc, không xoá được hồ sơ',
      });
    }
    await this.prisma.pet.update({
      where: { id },
      data: { isActive: false },
    });
    return { id, daXoa: true };
  }

  // POST /pets/:id/photos thêm ảnh vào dải ảnh của bé
  async addPhotos(userId: string, id: string, files: UploadedImage[]) {
    await this.timCuaToi(userId, id);
    this.kiemTraCoAnh(files);
    const dangCo = await this.prisma.petPhoto.count({ where: { petId: id } });
    this.kiemTraGioiHanAnh(dangCo, files.length, MAX_PET_PHOTOS);
    let thuTu = dangCo;
    const taoMoi = (await this.taiLenNhieu(files, 'pets')).map((url) => ({
      petId: id,
      url,
      sortOrder: thuTu++,
    }));
    if (taoMoi.length) {
      await this.prisma.petPhoto.createMany({ data: taoMoi });
      if (dangCo === 0) {
        await this.prisma.pet.update({
          where: { id },
          data: { avatarUrl: taoMoi[0].url },
        });
      }
    }
    return this.layHoSo(userId, id);
  }

  // DELETE /pets/:id/photos xoá 1 hoặc nhiều ảnh của bé
  async deletePhotos(userId: string, id: string, ids: string[]) {
    await this.timCuaToi(userId, id);
    const rows = await this.prisma.petPhoto.findMany({
      where: { id: { in: ids }, petId: id },
      select: { id: true, url: true },
    });
    await this.xoaFileTheoUrl(rows.map((r) => r.url));
    await this.prisma.petPhoto.deleteMany({
      where: { id: { in: rows.map((r) => r.id) }, petId: id },
    });
    await this.datLaiAnhDaiDien(id);
    return this.layHoSo(userId, id);
  }

  // PATCH /pets/:id/photos/:photoId/avatar
  async setAvatar(userId: string, id: string, photoId: string) {
    await this.timCuaToi(userId, id);
    const anh = await this.prisma.petPhoto.findFirst({
      where: { id: photoId, petId: id },
    });
    if (!anh) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_ANH',
        message: 'Không tìm thấy ảnh của bé',
      });
    }
    const conLai = await this.prisma.petPhoto.findMany({
      where: { petId: id, id: { not: photoId } },
      orderBy: { sortOrder: 'asc' },
      select: { id: true },
    });
    await this.prisma.$transaction([
      this.prisma.petPhoto.update({
        where: { id: photoId },
        data: { sortOrder: 0 },
      }),
      ...conLai.map((r, i) =>
        this.prisma.petPhoto.update({
          where: { id: r.id },
          data: { sortOrder: i + 1 },
        }),
      ),
      this.prisma.pet.update({
        where: { id },
        data: { avatarUrl: anh.url },
      }),
    ]);
    return this.layHoSo(userId, id);
  }

  // Ảnh đại diện luôn là ảnh đứng đầu dải
  private async datLaiAnhDaiDien(petId: string) {
    const dau = await this.prisma.petPhoto.findFirst({
      where: { petId },
      orderBy: { sortOrder: 'asc' },
      select: { url: true },
    });
    await this.prisma.pet.update({
      where: { id: petId },
      data: { avatarUrl: dau?.url ?? null },
    });
  }
}
