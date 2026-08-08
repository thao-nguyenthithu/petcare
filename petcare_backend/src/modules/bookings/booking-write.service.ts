import { ConflictException, Injectable } from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { ServiceType } from 'generated/prisma/enums';
import { MOT_PHUT_MS } from '../../common/thoi-gian-vn';
import { phiNenTang } from '../../common/tien';
import { SystemSettingsService } from '../admin/system-settings.service';
import { GiaCuaBe, KetQuaGia } from './booking-pricing';
import { demGiuaHaiDon } from './booking-time';
import { BeCuaDon, MocDon } from './booking-validate';
import { CreateBookingDto, LoaiDichVuDto } from './dto/create-booking.dto';
import { SitterSlotsService } from './sitter-slots.service';

export const TRAN_DON_CHO_MOI_CHU = 10;
const SO_LAN_THU_MA = 5;

type DbClient = Prisma.TransactionClient;

const DANH_MUC: Record<
  ServiceType,
  { name: string; durationMinutes: number | null }
> = {
  WALKING: { name: 'Dắt đi dạo', durationMinutes: 60 },
  BOARDING: { name: 'Trông giữ', durationMinutes: null },
  GROOMING: { name: 'Tắm và cắt tỉa', durationMinutes: 90 },
};

@Injectable()
export class BookingWriteService {
  constructor(
    private readonly slots: SitterSlotsService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  async kiemTraBeRanh(
    userId: string,
    pets: BeCuaDon[],
    moc: MocDon,
    loai: LoaiDichVuDto,
    db: DbClient,
  ) {
    const dem = demGiuaHaiDon(loai) * MOT_PHUT_MS;
    const trung = await this.slots.donCuaBe(
      pets.map((p) => p.id),
      userId,
      new Date(moc.batDau.getTime() - dem),
      new Date(moc.ketThuc.getTime() + dem),
      db,
    );
    if (trung.length > 0) {
      throw new ConflictException({
        code: 'BE_DA_CO_DON',
        message:
          pets.length > 1
            ? 'Một trong các bé đã có đơn khác trong khung giờ này'
            : `${pets[0].name} đã có đơn khác trong khung giờ này`,
      });
    }
  }

  async kiemTraTranDonCho(userId: string, db: DbClient) {
    const dangCho = await db.booking.count({
      where: {
        ownerId: userId,
        status: { in: ['PENDING', 'AWAITING_PAYMENT'] },
      },
    });
    if (dangCho >= TRAN_DON_CHO_MOI_CHU) {
      throw new ConflictException({
        code: 'QUA_NHIEU_DON_CHO',
        message: `Bạn đang có ${dangCho} đơn chờ người chăm trả lời, xử lý bớt rồi đặt tiếp`,
      });
    }
  }

  async layDanhMuc(type: ServiceType, db: DbClient) {
    const dm = DANH_MUC[type];
    return db.service.upsert({
      where: { type },
      create: {
        type,
        name: dm.name,
        basePricePerHour: 0,
        durationMinutes: dm.durationMinutes,
      },
      update: {},
      select: { id: true },
    });
  }

  async ghiDon(
    p: {
      userId: string;
      sitterId: string;
      serviceId: string;
      moc: MocDon;
      gia: KetQuaGia;
      dto: CreateBookingDto;
      loai: LoaiDichVuDto;
      diaChi: {
        id: string;
        street: string;
        ward: string;
        province: string;
        lat: number;
        lng: number;
      };
      pets: BeCuaDon[];
      giaTheoBe: Map<string, GiaCuaBe>;
      pickupKm: number | null;
    },
    db: DbClient,
  ) {
    const ghiChu = p.dto.note?.trim();
    const phanTramNenTang = this.thamSo.so('platform.fee.percent');
    const duLieu = {
      ownerId: p.userId,
      sitterId: p.sitterId,
      serviceId: p.serviceId,
      scheduledAt: p.moc.batDau,
      scheduledEndAt: p.moc.ketThuc,
      totalPrice: p.gia.total,
      platformFee: phiNenTang(p.gia.total, phanTramNenTang),
      platformFeePercent: phanTramNenTang,
      cancelFeePercent: this.thamSo.so('cancel.fee.percent'),
      priceBreakdown: { lines: p.gia.lines, nights: p.moc.soDem },
      durationMinutes: p.gia.durationMinutes,
      specialNotes: ghiChu && ghiChu.length > 0 ? ghiChu : null,
      gearCommittedAt: p.loai === 'walking' ? new Date() : null,
      addressId: p.diaChi.id,
      addressText: [p.diaChi.street, p.diaChi.ward, p.diaChi.province]
        .filter((e) => e.trim().length > 0)
        .join(', '),
      addressLat: p.diaChi.lat,
      addressLng: p.diaChi.lng,
      pickupDistanceKm: p.pickupKm,
      pets: {
        create: p.pets.map((be) => {
          const rieng = p.giaTheoBe.get(be.id);
          return {
            petId: be.id,
            packageCode: rieng?.packageCode ?? null,
            durationMinutes: rieng?.durationMinutes ?? null,
            price: rieng?.price ?? null,
          };
        }),
      },
    };

    return db.booking.create({
      data: {
        ...duLieu,
        status: 'AWAITING_PAYMENT',
        code: await this.sinhMaDuyNhat(db),
      },
      select: {
        id: true,
        code: true,
        status: true,
        scheduledAt: true,
        scheduledEndAt: true,
        durationMinutes: true,
        totalPrice: true,
        createdAt: true,
      },
    });
  }

  private async sinhMaDuyNhat(db: DbClient): Promise<string> {
    const bang = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    for (let lan = 0; lan < SO_LAN_THU_MA; lan++) {
      let ma = 'PC';
      for (let i = 0; i < 6; i++) {
        ma += bang[Math.floor(Math.random() * bang.length)];
      }
      const daCo = await db.booking.findUnique({
        where: { code: ma },
        select: { id: true },
      });
      if (!daCo) return ma;
    }
    throw new ConflictException({
      code: 'KHONG_SINH_DUOC_MA_DON',
      message: 'Không tạo được mã đơn, thử lại giúp mình',
    });
  }
}
