import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { khuVucHaiCap, lamTronToaDo } from '../../../common/khu-vuc';
import { PrismaService } from '../../../prisma/prisma.service';
import { SitterPenaltyService } from '../../bookings/sitter-penalty.service';
import { dieuKienNccCongKhai, TRUONG_USER_CONG_KHAI } from './sitter-public';

@Injectable()
export class SittersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly penalty: SitterPenaltyService,
  ) {}

  async getPublicProfile(id: string, xemBoiUserId?: string) {
    const ncc = await this.prisma.sitter.findFirst({
      where: { id, ...dieuKienNccCongKhai() },
      select: {
        id: true,
        userId: true,
        bio: true,
        ratingAvg: true,
        totalReviews: true,
        trustedBadge: true,
        serviceAddress: true,
        lat: true,
        lng: true,
        serviceAddressNote: true,
        serviceRadiusKm: true,
        user: { select: TRUONG_USER_CONG_KHAI },
        photos: {
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
          select: { id: true, url: true, sortOrder: true, createdAt: true },
        },
        services: {
          select: { type: true, enabled: true, petKind: true, pricing: true },
        },
      },
    });
    if (!ncc) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_NCC',
        message: 'Không tìm thấy nhà cung cấp',
      });
    }
    if (xemBoiUserId && ncc.userId === xemBoiUserId) {
      throw new ForbiddenException({
        code: 'KHONG_TU_DAT_CHINH_MINH',
        message: 'Đây là hồ sơ người chăm của chính bạn, xem ở mục Hồ sơ',
      });
    }
    const [completedOrders, tyLeNhanDon] = await Promise.all([
      this.prisma.booking.count({
        where: { sitterId: ncc.id, status: 'COMPLETED' },
      }),
      this.penalty.tyLeNhanDon(ncc.id),
    ]);
    const services: Record<string, unknown> = {};
    for (const s of ncc.services) {
      services[s.type.toLowerCase()] = {
        enabled: s.enabled,
        petKind: s.petKind.toLowerCase(),
        ...(s.pricing as Record<string, unknown>),
      };
    }
    return {
      id: ncc.id,
      fullName: ncc.user?.fullName ?? null,
      avatarUrl: ncc.user?.avatarUrl ?? null,
      bio: ncc.bio,
      ratingAvg: ncc.ratingAvg,
      totalReviews: ncc.totalReviews,
      completedOrders,
      acceptRate: Math.round(tyLeNhanDon * 100),
      trusted: ncc.trustedBadge,
      photos: ncc.photos,
      services,
      serviceArea: {
        area: khuVucHaiCap(ncc.serviceAddress),
        lat: lamTronToaDo(ncc.lat),
        lng: lamTronToaDo(ncc.lng),
        addressNote: ncc.serviceAddressNote,
        radiusKm: ncc.serviceRadiusKm,
      },
    };
  }
}
