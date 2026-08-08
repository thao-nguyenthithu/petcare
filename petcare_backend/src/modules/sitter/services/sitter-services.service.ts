import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { SystemSettingsService } from '../../admin/system-settings.service';
import { TRAN_BE_WALKING } from '../../bookings/booking-pricing';
import { UpdateServiceAreaDto } from './dto/update-service-area.dto';
import {
  GroomingConfigDto,
  UpdateServicesDto,
} from './dto/update-services.dto';

type PetKindDb = 'DOG' | 'CAT' | 'BOTH';
type ServiceTypeDb = 'WALKING' | 'BOARDING' | 'GROOMING';
type BangSo = Record<string, Record<string, number>>;

export const WALKING_DURATIONS = [30, 60];
export const GROOMING_PACKAGES = ['bath', 'bathAndTrim'];
export const WEIGHT_TIERS = ['duoi5', 'tu5den10', 'tu10den20', 'tren20'];
export const GROOMING_PHUT_TOI_THIEU = 30;
export const GROOMING_PHUT_TOI_DA = 240;

function loi(code: string, message: string): never {
  throw new BadRequestException({ code, message });
}

function toDbPetKind(s?: string): PetKindDb {
  switch (s) {
    case 'cat':
      return 'CAT';
    case 'both':
      return 'BOTH';
    default:
      return 'DOG';
  }
}

@Injectable()
export class SitterServicesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  private async layNccCuaToi(userId: string) {
    const ncc = await this.prisma.sitter.findUnique({
      where: { userId },
    });
    if (!ncc) {
      throw new ForbiddenException({
        code: 'CHUA_LA_NCC',
        message: 'Tài khoản chưa phải nhà cung cấp',
      });
    }
    return ncc;
  }

  // GET /sitter/services
  async getServices(userId: string) {
    const [, rows] = await Promise.all([
      this.layNccCuaToi(userId),
      this.prisma.sitterService.findMany({ where: { sitter: { userId } } }),
    ]);
    const out: Record<string, unknown> = {};
    for (const r of rows) {
      out[r.type.toLowerCase()] = {
        enabled: r.enabled,
        petKind: r.petKind.toLowerCase(),
        ...(r.pricing as Record<string, unknown>),
      };
    }
    return out;
  }

  // PUT /sitter/services
  async updateServices(userId: string, dto: UpdateServicesDto) {
    const ncc = await this.layNccCuaToi(userId);
    this.kiemTraCauHinh(dto);
    const jobs: Promise<unknown>[] = [];
    if (dto.walking) {
      jobs.push(
        this.upsertLoai(
          ncc.id,
          'WALKING',
          dto.walking.enabled,
          dto.walking.petKind,
          {
            priceByDuration: dto.walking.priceByDuration ?? {},
            additionalPetFee: dto.walking.additionalPetFee ?? null,
            maxPets: dto.walking.maxPets ?? null,
          },
        ),
      );
    }
    if (dto.boarding) {
      jobs.push(
        this.upsertLoai(
          ncc.id,
          'BOARDING',
          dto.boarding.enabled,
          dto.boarding.petKind,
          {
            pricePerDay: dto.boarding.pricePerDay ?? null,
            capacity: dto.boarding.capacity ?? null,
            additionalPetFee: dto.boarding.additionalPetFee ?? null,
            maxPets: dto.boarding.maxPets ?? null,
          },
        ),
      );
    }
    if (dto.grooming) {
      const bang = this.chuanHoaGrooming(dto.grooming);
      if (
        dto.grooming.enabled &&
        Object.keys(bang.priceByPackage).length === 0
      ) {
        loi('THIEU_BANG_GIA', 'Chưa cấu hình bảng giá cho grooming');
      }
      jobs.push(
        this.upsertLoai(
          ncc.id,
          'GROOMING',
          dto.grooming.enabled,
          dto.grooming.petKind,
          { ...bang, maxPets: dto.grooming.maxPets ?? null },
        ),
      );
    }
    await Promise.all(jobs);
    return this.getServices(userId);
  }

  private chuanHoaGrooming(dto: GroomingConfigDto) {
    const gia = dto.priceByPackage ?? {};
    const phut = dto.durationByPackage ?? {};
    const priceByPackage: BangSo = {};
    const durationByPackage: BangSo = {};
    for (const goi of GROOMING_PACKAGES) {
      const giaGoi = gia[goi];
      if (!giaGoi || typeof giaGoi !== 'object') continue;
      const phutGoi = phut[goi] ?? {};
      const mucGia: Record<string, number> = {};
      const mucPhut: Record<string, number> = {};
      for (const muc of WEIGHT_TIERS) {
        const tien = giaGoi[muc];
        if (tien === undefined || tien === null) continue;
        if (!Number.isInteger(tien) || tien <= 0) {
          loi('GIA_KHONG_HOP_LE', `Giá của mức ${muc} phải là số nguyên dương`);
        }
        mucGia[muc] = tien;
        const so = phutGoi[muc];
        if (so === undefined || so === null) {
          if (dto.enabled) {
            loi('THIEU_THOI_LUONG', `Chưa nhập thời lượng cho mức ${muc}`);
          }
          continue;
        }
        if (
          !Number.isInteger(so) ||
          so < GROOMING_PHUT_TOI_THIEU ||
          so > GROOMING_PHUT_TOI_DA
        ) {
          loi(
            'THOI_LUONG_KHONG_HOP_LE',
            `Thời lượng phải từ ${GROOMING_PHUT_TOI_THIEU} đến ${GROOMING_PHUT_TOI_DA} phút`,
          );
        }
        mucPhut[muc] = so;
      }
      if (Object.keys(mucGia).length === 0) continue;
      priceByPackage[goi] = mucGia;
      durationByPackage[goi] = mucPhut;
    }
    return { priceByPackage, durationByPackage };
  }

  // Validate luật giá phía server
  private kiemTraCauHinh(dto: UpdateServicesDto) {
    const kiemTraMaxPets = (
      maxPets?: number,
      capacity?: number | null,
      tran?: number,
    ) => {
      if (maxPets == null || maxPets < 1) {
        loi(
          'SO_BE_TOI_DA_KHONG_HOP_LE',
          'Số bé tối đa mỗi đơn phải từ 1 trở lên',
        );
      }
      if (tran != null && maxPets > tran) {
        loi('VUOT_TRAN_SO_BE', `Một lượt dắt nhận tối đa ${tran} bé`);
      }
      if (capacity != null && maxPets > capacity) {
        loi(
          'SO_BE_VUOT_SUC_CHUA',
          'Số bé tối đa mỗi đơn không được vượt sức chứa',
        );
      }
    };
    const kiemTraPhuPhi = (fee?: number, maxPets?: number) => {
      const nhieuBe = maxPets != null && maxPets >= 2;
      if (nhieuBe && fee == null) {
        loi(
          'THIEU_PHU_PHI_BE_THEM',
          'Cần đặt phụ phí mỗi bé thêm khi nhận từ 2 bé',
        );
      }
      if (fee != null && !nhieuBe) {
        loi('PHU_PHI_THUA', 'Chỉ đặt phụ phí khi nhận từ 2 bé mỗi đơn');
      }
    };
    if (dto.walking?.enabled) {
      const bangGia = dto.walking.priceByDuration ?? {};
      const thieu = WALKING_DURATIONS.filter(
        (phut) => typeof bangGia[phut] !== 'number',
      );
      if (thieu.length > 0) {
        loi('THIEU_GIA', `Chưa nhập giá cho lượt ${thieu.join(' và ')} phút`);
      }
      for (const phut of WALKING_DURATIONS) {
        const gia = bangGia[phut];
        if (!Number.isInteger(gia) || gia <= 0) {
          loi(
            'GIA_KHONG_HOP_LE',
            `Giá lượt ${phut} phút phải là số nguyên dương`,
          );
        }
      }
      kiemTraMaxPets(dto.walking.maxPets, null, TRAN_BE_WALKING);
      kiemTraPhuPhi(dto.walking.additionalPetFee, dto.walking.maxPets);
    }
    if (dto.boarding?.enabled) {
      if (dto.boarding.pricePerDay == null || dto.boarding.capacity == null) {
        loi('THIEU_GIA', 'Chưa nhập giá hoặc sức chứa');
      }
      kiemTraMaxPets(dto.boarding.maxPets, dto.boarding.capacity);
      kiemTraPhuPhi(dto.boarding.additionalPetFee, dto.boarding.maxPets);
    }
    if (dto.grooming?.enabled) {
      kiemTraMaxPets(dto.grooming.maxPets);
    }
  }

  private upsertLoai(
    sitterId: string,
    type: ServiceTypeDb,
    enabled: boolean,
    petKind: string,
    pricing: object,
  ) {
    const pk = toDbPetKind(petKind);
    return this.prisma.sitterService.upsert({
      where: { sitterId_type: { sitterId, type } },
      create: { sitterId, type, enabled, petKind: pk, pricing },
      update: { enabled, petKind: pk, pricing },
    });
  }

  // GET /sitter/onboarding thời điểm đã hoàn tất onboarding (null nếu chưa)
  async getOnboarding(userId: string) {
    const ncc = await this.layNccCuaToi(userId);
    return { onboardedAt: ncc.onboardedAt };
  }

  // POST /sitter/onboarding/complete đánh dấu bấm "Bắt đầu nhận đơn"
  async completeOnboarding(userId: string) {
    const ncc = await this.layNccCuaToi(userId);
    if (ncc.onboardedAt) return { onboardedAt: ncc.onboardedAt };
    const updated = await this.prisma.sitter.update({
      where: { userId },
      data: { onboardedAt: new Date() },
    });
    return { onboardedAt: updated.onboardedAt };
  }

  // GET /sitter/service-area
  async getServiceArea(userId: string) {
    const ncc = await this.layNccCuaToi(userId);
    return {
      address: ncc.serviceAddress,
      lat: ncc.lat,
      lng: ncc.lng,
      addressNote: ncc.serviceAddressNote,
      radiusKm: ncc.serviceRadiusKm,
    };
  }

  // PUT /sitter/service-area lưu khu vực phục vụ
  async updateServiceArea(userId: string, dto: UpdateServiceAreaDto) {
    await this.layNccCuaToi(userId);
    const banKinhToiDa = this.thamSo.so('search.radius_max_km');
    if (dto.radiusKm > banKinhToiDa) {
      throw new BadRequestException({
        code: 'VUOT_BAN_KINH_TOI_DA',
        message: `Bán kính phục vụ tối đa là ${banKinhToiDa} km`,
      });
    }
    const ncc = await this.prisma.sitter.update({
      where: { userId },
      data: {
        serviceAddress: dto.address ?? null,
        lat: dto.lat,
        lng: dto.lng,
        serviceAddressNote: dto.addressNote ?? null,
        serviceRadiusKm: dto.radiusKm,
      },
    });
    return {
      address: ncc.serviceAddress,
      lat: ncc.lat,
      lng: ncc.lng,
      addressNote: ncc.serviceAddressNote,
      radiusKm: ncc.serviceRadiusKm,
    };
  }
}
