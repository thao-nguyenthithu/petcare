import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { MOT_PHUT_MS } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { BookingNotifyService } from '../notifications/booking-notify.service';
import { PaymentsService } from '../payments/payments.service';
import { LOAI_RA_DB } from './booking-enums';
import { hanGiuCho } from './booking-time';
import {
  BeCuaDon,
  dungMocThoiGian,
  kiemTraBanKinh,
  kiemTraLich,
  kiemTraLoaiBe,
  kiemTraSoBe,
  kmDiemHenToiNcc,
  tinhTien,
} from './booking-validate';
import { BookingWriteService } from './booking-write.service';
import { CreateBookingDto, LoaiDichVuDto } from './dto/create-booking.dto';
import { SitterSlotsService } from './sitter-slots.service';

@Injectable()
export class BookingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly slots: SitterSlotsService,
    private readonly notify: BookingNotifyService,
    private readonly payments: PaymentsService,
    private readonly ghi: BookingWriteService,
  ) {}

  async taoDon(userId: string, dto: CreateBookingDto) {
    const loai = dto.serviceType;
    const ncc = await this.slots.layNccCongKhai(
      dto.sitterId,
      undefined,
      userId,
    );
    // 3 tra cứu độc lập nhau, chạy song song bớt round-trip DB. Dùng allSettled rồi tự
    // xét lỗi theo đúng thứ tự cũ (dịch vụ trước, bé, địa chỉ sau) — Promise.all thường sẽ
    // ném lỗi của lệnh nào reject nhanh nhất, thứ tự đổi bất định giữa các lần gọi
    const [rDichVu, rPets, rDiaChi] = await Promise.allSettled([
      this.layDichVuNcc(ncc.id, loai),
      this.layBeCuaToi(userId, dto.petIds),
      this.layDiaChiCuaToi(userId, dto.addressId),
    ]);
    if (rDichVu.status === 'rejected') throw rDichVu.reason;
    if (rPets.status === 'rejected') throw rPets.reason;
    if (rDiaChi.status === 'rejected') throw rDiaChi.reason;
    const dichVuNcc = rDichVu.value;
    const pets = rPets.value;
    const diaChi = rDiaChi.value;
    const pricing = (dichVuNcc.pricing as Record<string, unknown>) ?? {};

    kiemTraLoaiBe(pets, loai, dichVuNcc.petKind);
    kiemTraSoBe(pets.length, pricing, loai);
    if (loai === 'walking' && dto.gearCommitted !== true) {
      throw new BadRequestException({
        code: 'THIEU_CAM_KET_DUNG_CU',
        message: 'Cần cam kết đủ rọ mõm và dây xích cho các bé',
      });
    }

    if (loai !== 'boarding') {
      kiemTraBanKinh(diaChi, ncc);
    }

    const moc = dungMocThoiGian(dto, loai);
    const gia = tinhTien(loai, pricing, pets, dto, moc);
    if (loai !== 'boarding') {
      moc.ketThuc = new Date(
        moc.batDau.getTime() + (gia.durationMinutes ?? 0) * MOT_PHUT_MS,
      );
    }
    const giaTheoBe = new Map(gia.perPet.map((e) => [e.petId, e]));
    const don = await this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${userId}))`;
      const lich = await this.slots.layLich(
        ncc.id,
        moc.ngayDau,
        loai === 'boarding' ? moc.ngayCuoi : moc.ngayDau,
        { db: tx },
      );
      kiemTraLich(lich.days, loai, moc, gia.durationMinutes, pets.length);
      await this.ghi.kiemTraBeRanh(userId, pets, moc, loai, tx);
      await this.ghi.kiemTraTranDonCho(userId, tx);
      const dichVu = await this.ghi.layDanhMuc(LOAI_RA_DB[loai], tx);
      return this.ghi.ghiDon(
        {
          userId,
          sitterId: ncc.id,
          serviceId: dichVu.id,
          moc,
          gia,
          dto,
          loai,
          diaChi,
          pets,
          giaTheoBe,
          pickupKm: kmDiemHenToiNcc(diaChi, ncc),
        },
        tx,
      );
    });
    const hetHan = hanGiuCho(don.createdAt);
    await this.payments.henDonGiuCho(don.id, hetHan);
    return {
      id: don.id,
      code: don.code,
      status: don.status,
      serviceType: loai,
      scheduledAt: don.scheduledAt,
      scheduledEndAt: don.scheduledEndAt,
      durationMinutes: don.durationMinutes,
      totalPrice: don.totalPrice,
      nights: loai === 'boarding' ? moc.soDem : null,
      createdAt: don.createdAt,
      paymentExpiresAt: hetHan,
    };
  }

  // Dịch vụ người chăm đang bật nhận đơn
  private async layDichVuNcc(sitterId: string, loai: LoaiDichVuDto) {
    const dv = await this.prisma.sitterService.findUnique({
      where: { sitterId_type: { sitterId, type: LOAI_RA_DB[loai] } },
      select: { enabled: true, petKind: true, pricing: true },
    });
    if (!dv?.enabled) {
      throw new ConflictException({
        code: 'NCC_KHONG_NHAN_DICH_VU',
        message: 'Người chăm hiện không nhận dịch vụ này',
      });
    }
    return dv;
  }

  // Chỉ lấy bé của chính chủ nuôi đang đăng nhập
  private async layBeCuaToi(
    userId: string,
    petIds: string[],
  ): Promise<BeCuaDon[]> {
    const pets = await this.prisma.pet.findMany({
      where: { id: { in: petIds }, ownerId: userId, isActive: true },
      select: { id: true, name: true, species: true, weightKg: true },
    });
    if (pets.length !== petIds.length) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_THU_CUNG',
        message: 'Không tìm thấy một trong các hồ sơ thú cưng đã chọn',
      });
    }
    return pets;
  }

  private async layDiaChiCuaToi(userId: string, id: string) {
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
