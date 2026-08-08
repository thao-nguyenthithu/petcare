import { ConflictException, Injectable } from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { SystemSettingsService } from '../../admin/system-settings.service';
import {
  anhDuNet,
  CAU_TIENG_VIET,
  xuLySlot,
  type MaKetQuaAi,
} from '../../ai/ai-ket-luan';
import { SO_LAN_GOI_TOI_DA_MOI_DON } from '../../ai/ai.constants';
import { AnhKyService } from '../../media/anh-ky.service';
import {
  chotCuaSlot,
  conLai,
  cuaSlot,
  slotConThieu,
  duocTuXacNhan,
  xuLyCuaSlot,
  type DongQuet,
} from './checkin-scan.dem';
import {
  chiDichVu,
  SitterOrderStore,
  type DonMayTrangThai,
} from './sitter-order-store.service';

// Đọc kết quả quét check-in 
@Injectable()
export class PetSafetyScanReadService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly store: SitterOrderStore,
    private readonly thamSo: SystemSettingsService,
    private readonly kyAnh: AnhKyService,
  ) {}

  async docQuet(bookingId: string): Promise<DongQuet[]> {
    return this.prisma.petSafetyScan.findMany({
      where: { bookingId },
      select: {
        slotIndex: true,
        trangThai: true,
        code: true,
        confidence: true,
        canhDaiPx: true,
        tinhLuot: true,
        photoUrl: true,
        lat: true,
        lng: true,
      },
      orderBy: { chupLuc: 'asc' },
    });
  }

  async docXacNhan(bookingId: string): Promise<Set<number>> {
    const ds = await this.prisma.checkinSlotXacNhan.findMany({
      where: { bookingId },
      select: { slotIndex: true },
    });
    return new Set(ds.map((d) => d.slotIndex));
  }

  async trangThaiCaDan(userId: string, bookingId: string) {
    const { don } = await this.store.timDon(userId, bookingId);
    chiDichVu(don, 'walking');
    const [ds, daXacNhan] = await Promise.all([
      this.docQuet(don.id),
      this.docXacNhan(don.id),
    ]);
    return this.dungBaoCao(ds, daXacNhan, don._count.pets);
  }

  async docLo(userId: string, bookingId: string, batchId: string) {
    const { don } = await this.store.timDon(userId, bookingId);
    const lo = await this.prisma.checkinScanBatch.findFirst({
      where: { id: batchId, bookingId: don.id },
      select: { id: true, trangThai: true, xongLuc: true },
    });
    if (!lo) {
      throw new ConflictException({
        code: 'KHONG_TIM_THAY_LO_ANH',
        message: 'Không tìm thấy lô ảnh này',
      });
    }
    const [ds, daXacNhan] = await Promise.all([
      this.docQuet(don.id),
      this.docXacNhan(don.id),
    ]);
    return {
      batchId: lo.id,
      trangThai: lo.trangThai,
      xongLuc: lo.xongLuc,
      ...(await this.dungBaoCao(ds, daXacNhan, don._count.pets)),
    };
  }

  async baoCaoTheoDon(bookingId: string) {
    const [don, ds, daXacNhan] = await Promise.all([
      this.prisma.booking.findUnique({
        where: { id: bookingId },
        select: { _count: { select: { pets: true } } },
      }),
      this.docQuet(bookingId),
      this.docXacNhan(bookingId),
    ]);
    return this.dungBaoCao(ds, daXacNhan, don?._count.pets ?? 0);
  }

  async dungBaoCao(
    ds: DongQuet[],
    daXacNhan: ReadonlySet<number>,
    soBe: number,
  ) {
    const slots = Array.from({ length: soBe }, (_, i) => {
      const slot = i + 1;
      const chot = chotCuaSlot(ds, slot);
      const xuLy = xuLyCuaSlot(ds, slot);
      const duNet = anhDuNet(chot?.canhDaiPx);
      return {
        slotIndex: slot,
        xuLy,
        trangThai: chot?.trangThai ?? null,
        code: chot?.code ?? null,
        reason: chot?.code
          ? (CAU_TIENG_VIET[chot.code as MaKetQuaAi] ?? null)
          : null,
        confidence: chot?.confidence ?? null,
        anhDuNet: duNet,
        ghiChu:
          chot && !duNet && xuLy === 'TU_XAC_NHAN'
            ? CAU_TIENG_VIET.ANH_DO_PHAN_GIAI_THAP
            : null,
        anhUrl: chot?.photoUrl ?? null,
        soLanConLai: conLai(ds, slot),
        daTuXacNhan: daXacNhan.has(slot),
        duocTuXacNhan: duocTuXacNhan(
          ds,
          slot,
          ds.length < SO_LAN_GOI_TOI_DA_MOI_DON,
        ),
      };
    });
    const ky = await this.kyAnh.kyLo(slots.map((s) => s.anhUrl));
    return {
      soLuotConLaiCuaDon: Math.max(0, SO_LAN_GOI_TOI_DA_MOI_DON - ds.length),
      duDieuKienBatDau: !slotConThieu(ds, daXacNhan, soBe).length,
      slots: slots.map((s) => ({
        ...s,
        anhUrl: s.anhUrl ? (ky.get(s.anhUrl) ?? s.anhUrl) : null,
      })),
    };
  }

  async chanCheckIn(don: DonMayTrangThai) {
    const [ds, daXacNhan] = await Promise.all([
      this.docQuet(don.id),
      this.docXacNhan(don.id),
    ]);
    const thieu = slotConThieu(ds, daXacNhan, don._count.pets);
    if (thieu.length) {
      throw new ConflictException({
        code: 'CHUA_QUET_DU_CAC_BE',
        message: 'Còn bé chưa xác minh đủ rọ mõm và dây xích',
        slotIndexes: thieu,
      });
    }
  }

  async luuAnhBangChung(bookingId: string, soBe: number): Promise<string[]> {
    const [lo, ds, daXacNhan] = await Promise.all([
      this.prisma.checkinScanBatch.findFirst({
        where: { bookingId, anhCaDanUrl: { not: null } },
        select: { anhCaDanUrl: true },
        orderBy: { taoLuc: 'asc' },
      }),
      this.docQuet(bookingId),
      this.docXacNhan(bookingId),
    ]);
    const nhaAi = this.thamSo.nhaAi();
    const dong: Prisma.SessionPhotoCreateManyInput[] = [];
    if (lo?.anhCaDanUrl) {
      dong.push({
        bookingId,
        photoUrl: lo.anhCaDanUrl,
        phase: 'CHECK_IN',
        slotIndex: 0,
      });
    }
    for (let slot = 1; slot <= soBe; slot++) {
      const vanXa = daXacNhan.has(slot);
      const canLuu = vanXa ? cuaSlot(ds, slot) : [chotCuaSlot(ds, slot)];
      for (const tam of canLuu) {
        if (!tam) continue;
        dong.push({
          bookingId,
          photoUrl: tam.photoUrl,
          phase: 'CHECK_IN',
          slotIndex: slot,
          anhVanXa: vanXa,
          aiPassed: xuLySlot(tam) === 'DI_TIEP',
          aiProvider: nhaAi,
          aiConfidenceScore: tam.confidence,
          photoLat: tam.lat,
          photoLng: tam.lng,
        });
      }
    }
    if (!dong.length) return [];
    await this.prisma.sessionPhoto.createMany({ data: dong });
    return dong.map((d) => d.photoUrl);
  }
}
