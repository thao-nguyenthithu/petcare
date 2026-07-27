import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { SupabaseService } from '../media/supabase.service';
import { UpdateSitterMeDto } from './dto/update-sitter-me.dto';

// Bucket PUBLIC chứa ảnh đại diện + thư viện ảnh NCC
const BUCKET = 'sitter-media';
const MAX_PHOTOS = 20;

// Ảnh upload từ multipart
export interface UploadedImage {
  buffer?: Buffer;
  mimetype?: string;
}

// Vận hành trang cá nhân NCC (họ tên/giới thiệu/số điện thoại + ảnh)
@Injectable()
export class SitterMeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly supabase: SupabaseService,
  ) {}

  // Chỉ tài khoản đã là NCC (có hồ sơ) mới có trang cá nhân
  private async layNcc(userId: string) {
    const ncc = await this.prisma.sitter.findUnique({ where: { userId } });
    if (!ncc) {
      throw new ForbiddenException({
        code: 'CHUA_LA_NCC',
        message: 'Tài khoản chưa phải nhà cung cấp',
      });
    }
    return ncc;
  }

  private layAnh(sitterId: string) {
    return this.prisma.sitterPhoto.findMany({
      where: { sitterId },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
      select: { id: true, url: true, sortOrder: true },
    });
  }

  // GET /sitter/profile
  async getProfile(userId: string) {
    const ncc = await this.layNcc(userId);
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { fullName: true, email: true, phone: true, avatarUrl: true },
    });
    const [photos, completedOrders] = await Promise.all([
      this.layAnh(ncc.id),
      this.prisma.booking.count({
        where: { sitterId: ncc.id, status: 'COMPLETED' },
      }),
    ]);
    return {
      fullName: user?.fullName ?? null,
      email: user?.email ?? null,
      phone: user?.phone ?? null,
      avatarUrl: user?.avatarUrl ?? null,
      bio: ncc.bio,
      dateOfBirth: ncc.dateOfBirth,
      gender: ncc.gender,
      ratingAvg: ncc.ratingAvg,
      totalReviews: ncc.totalReviews,
      completedOrders,
      photos,
    };
  }

  // PUT /sitter/profile cập nhật trang cá nhân NCC
  async updateProfile(userId: string, dto: UpdateSitterMeDto) {
    await this.layNcc(userId);
    const ten = dto.fullName.trim();
    if (!ten) {
      throw new BadRequestException({
        code: 'THIEU_HO_TEN',
        message: 'Vui lòng nhập họ và tên',
      });
    }
    const sdt = dto.phone?.trim();
    const bio = dto.bio?.trim();
    try {
      await this.prisma.$transaction([
        this.prisma.user.update({
          where: { id: userId },
          data: { fullName: ten, phone: sdt ? sdt : null },
        }),
        this.prisma.sitter.update({
          where: { userId },
          data: { bio: bio ? bio : null },
        }),
      ]);
    } catch (e) {
      // Số điện thoại trùng người khác
      if ((e as { code?: string })?.code === 'P2002') {
        throw new ConflictException({
          code: 'SDT_DA_DUOC_DUNG',
          message: 'Số điện thoại đã được người khác sử dụng',
        });
      }
      throw e;
    }
    return this.getProfile(userId);
  }

  // POST /sitter/profile/avatar tải ảnh đại diện
  async uploadAvatar(userId: string, file: UploadedImage) {
    await this.layNcc(userId);
    if (!file?.buffer) {
      throw new BadRequestException({
        code: 'THIEU_ANH',
        message: 'Thiếu ảnh tải lên',
      });
    }
    await this.supabase.ensurePublicBucket(BUCKET);
    const path = `avatars/${randomUUID()}.jpg`;
    await this.supabase.uploadFile(
      BUCKET,
      path,
      file.buffer,
      file.mimetype || 'image/jpeg',
    );
    const url = this.supabase.getPublicUrl(BUCKET, path);
    await this.prisma.user.update({
      where: { id: userId },
      data: { avatarUrl: url },
    });
    return { avatarUrl: url };
  }

  // POST /sitter/profile/photos thêm 1 hoặc nhiều ảnh
  async addPhotos(userId: string, files: UploadedImage[]) {
    const ncc = await this.layNcc(userId);
    if (!files?.length) {
      throw new BadRequestException({
        code: 'THIEU_ANH',
        message: 'Thiếu ảnh tải lên',
      });
    }
    const dangCo = await this.prisma.sitterPhoto.count({
      where: { sitterId: ncc.id },
    });
    if (dangCo + files.length > MAX_PHOTOS) {
      throw new BadRequestException({
        code: 'VUOT_GIOI_HAN_ANH',
        message: `Thư viện chỉ được tối đa ${MAX_PHOTOS} ảnh`,
      });
    }
    await this.supabase.ensurePublicBucket(BUCKET);
    let thuTu = dangCo;
    const taoMoi: { sitterId: string; url: string; sortOrder: number }[] = [];
    for (const f of files) {
      if (!f?.buffer) continue;
      const path = `photos/${randomUUID()}.jpg`;
      await this.supabase.uploadFile(
        BUCKET,
        path,
        f.buffer,
        f.mimetype || 'image/jpeg',
      );
      const url = this.supabase.getPublicUrl(BUCKET, path);
      taoMoi.push({ sitterId: ncc.id, url, sortOrder: thuTu++ });
    }
    if (taoMoi.length) {
      await this.prisma.sitterPhoto.createMany({ data: taoMoi });
    }
    return this.layAnh(ncc.id);
  }

  // DELETE /sitter/profile/photos xoá 1 hoặc nhiều ảnh 
  async deletePhotos(userId: string, ids: string[]) {
    const ncc = await this.layNcc(userId);
    // Chỉ xoá ảnh thuộc về NCC hiện tại
    const rows = await this.prisma.sitterPhoto.findMany({
      where: { id: { in: ids }, sitterId: ncc.id },
      select: { id: true, url: true },
    });
    for (const r of rows) {
      const path = r.url.split(`/${BUCKET}/`)[1];
      if (path) {
        try {
          await this.supabase.deleteFile(BUCKET, path);
        } catch {
        }
      }
    }
    await this.prisma.sitterPhoto.deleteMany({
      where: { id: { in: rows.map((r) => r.id) }, sitterId: ncc.id },
    });
    return this.layAnh(ncc.id);
  }
}
