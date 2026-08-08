import { Injectable } from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { MOT_NGAY_MS } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { SystemSettingsService } from '../admin/system-settings.service';
import { SitterWarningNotifyService } from '../notifications/sitter-warning-notify.service';
import { TRANG_THAI_HUY } from './booking-enums';
import {
  CANH_CAO_BAT_DAU_NHAC,
  MucPhat,
  SO_LAN_TAM_AN_KHOA,
  THANG_DEM_LAN_TAM_AN,
  mocDemPhat,
  ngayTamAn,
} from './sitter-penalty-rules';

type DbClient = Prisma.TransactionClient;
@Injectable()
export class SitterPenaltyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhacCanhCao: SitterWarningNotifyService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  private ngayCuaSo(): number {
    return this.thamSo.so('penalty.window_days');
  }

  async ghiPhat(
    sitterId: string,
    bookingId: string,
    muc: MucPhat,
    lyDo: string | null,
    bayGio: number,
    db: DbClient,
  ) {
    const trangThai = muc.treoChoSoat ? 'PENDING_REVIEW' : 'ACTIVE';
    const ghi: Prisma.SitterPenaltyCreateManyInput[] = [];
    if (muc.tinhTyLeHuy) {
      ghi.push({
        sitterId,
        bookingId,
        kind: 'CANCEL_RATE',
        status: trangThai,
        reason: lyDo,
      });
    }
    if (muc.canhCao) {
      ghi.push({
        sitterId,
        bookingId,
        kind: 'WARNING',
        status: trangThai,
        reason: lyDo,
      });
    }
    if (ghi.length === 0) return { tamAn: false, khoa: false };
    await db.sitterPenalty.createMany({ data: ghi });
    return this.leoThang(sitterId, bayGio, db);
  }

  private async leoThang(sitterId: string, bayGio: number, db: DbClient) {
    const lanAn = await db.sitterPenalty.findFirst({
      where: { sitterId, kind: 'HIDE' },
      orderBy: { createdAt: 'desc' },
      select: { createdAt: true },
    });
    const mocDem = mocDemPhat(
      bayGio,
      this.ngayCuaSo(),
      lanAn?.createdAt ?? null,
    );
    const [canhCao, tongDon, donHuy] = await Promise.all([
      db.sitterPenalty.count({
        where: {
          sitterId,
          kind: 'WARNING',
          status: { not: 'WAIVED' },
          createdAt: { gt: mocDem },
        },
      }),
      db.booking.count({
        where: {
          sitterId,
          status: { notIn: ['PENDING', 'AWAITING_PAYMENT'] },
          createdAt: { gt: mocDem },
        },
      }),
      db.sitterPenalty.count({
        where: {
          sitterId,
          kind: 'CANCEL_RATE',
          status: { not: 'WAIVED' },
          createdAt: { gt: mocDem },
        },
      }),
    ]);
    const xetTyLe = tongDon >= this.thamSo.so('penalty.min_orders');
    const tyLe = tongDon === 0 ? 0 : donHuy / tongDon;
    const phaiTamAn =
      canhCao >= this.thamSo.so('penalty.warnings_to_hide') ||
      (xetTyLe && tyLe > this.thamSo.tiLe('penalty.cancel_rate_max'));
    if (!phaiTamAn) {
      if (canhCao >= CANH_CAO_BAT_DAU_NHAC) {
        await this.nhacCanhCao.sapBiAn(sitterId, canhCao);
      }
      return { tamAn: false, khoa: false };
    }

    const lyDoAn =
      canhCao >= this.thamSo.so('penalty.warnings_to_hide')
        ? `Đủ ${canhCao} cảnh cáo trong cửa sổ`
        : 'Tỷ lệ huỷ vượt ngưỡng';
    const khoa = await this.tamAn(sitterId, bayGio, lyDoAn, db);
    await this.nhacCanhCao.daBiAn(sitterId, khoa.soNgay, khoa.khoa);
    return { tamAn: true, khoa: khoa.khoa, soNgayAn: khoa.soNgay };
  }

  async tamAn(
    sitterId: string,
    bayGio: number,
    lyDo: string,
    db: DbClient,
    soNgayEp?: number,
  ) {
    const luc = new Date(bayGio);
    const ncc = await db.sitter.update({
      where: { id: sitterId },
      data: { hiddenCount: { increment: 1 }, lastHiddenAt: luc },
      select: { hiddenCount: true },
    });
    const soNgay = soNgayEp ?? ngayTamAn(ncc.hiddenCount);
    await db.sitter.update({
      where: { id: sitterId },
      data: { hiddenUntil: new Date(bayGio + soNgay * MOT_NGAY_MS) },
    });
    await db.sitterPenalty.create({
      data: { sitterId, kind: 'HIDE', status: 'ACTIVE', reason: lyDo },
      select: { id: true },
    });

    const tuThangTruoc = new Date(
      bayGio - THANG_DEM_LAN_TAM_AN * 30 * MOT_NGAY_MS,
    );
    const soLanAnGanDay = await db.sitterPenalty.count({
      where: {
        sitterId,
        kind: 'HIDE',
        status: { not: 'WAIVED' },
        createdAt: { gte: tuThangTruoc },
      },
    });
    const khoa = soLanAnGanDay >= SO_LAN_TAM_AN_KHOA;
    if (khoa) {
      await db.sitter.update({
        where: { id: sitterId },
        data: { bannedAt: luc },
      });
    }
    return { soNgay, khoa, hiddenCount: ncc.hiddenCount, soLanAnGanDay };
  }

  async hoSoUyTin(sitterId: string) {
    const tuNgay = new Date(Date.now() - this.ngayCuaSo() * MOT_NGAY_MS);
    const [tongDon, donHuy, canhCao, treo] = await Promise.all([
      this.prisma.booking.count({
        where: {
          sitterId,
          status: { notIn: ['PENDING', 'AWAITING_PAYMENT'] },
          createdAt: { gte: tuNgay },
        },
      }),
      this.prisma.sitterPenalty.count({
        where: {
          sitterId,
          kind: 'CANCEL_RATE',
          status: { not: 'WAIVED' },
          createdAt: { gte: tuNgay },
        },
      }),
      this.prisma.sitterPenalty.count({
        where: {
          sitterId,
          kind: 'WARNING',
          status: { not: 'WAIVED' },
          createdAt: { gte: tuNgay },
        },
      }),
      this.prisma.sitterPenalty.count({
        where: { sitterId, status: 'PENDING_REVIEW' },
      }),
    ]);
    const duMau = tongDon >= this.thamSo.so('penalty.min_orders');
    return {
      tyLeHuy: duMau && tongDon > 0 ? donHuy / tongDon : null,
      duMauXetTyLe: duMau,
      soCanhCao: canhCao,
      soDangChoSoat: treo,
      nguongTyLeHuy: this.thamSo.tiLe('penalty.cancel_rate_max'),
      soCanhCaoBiAn: this.thamSo.so('penalty.warnings_to_hide'),
    };
  }

  async tyLeNhanDon(sitterId: string): Promise<number> {
    const tuNgay = new Date(Date.now() - this.ngayCuaSo() * MOT_NGAY_MS);
    const trongCuaSo: Prisma.BookingWhereInput = {
      sitterId,
      createdAt: { gte: tuNgay },
      status: {
        notIn: ['PENDING', 'AWAITING_PAYMENT', 'CANCELLED_BY_OWNER'],
      },
    };
    const [mauSo, tuSo] = await Promise.all([
      this.prisma.booking.count({ where: trongCuaSo }),
      this.prisma.booking.count({
        where: { ...trongCuaSo, acceptedAt: { not: null } },
      }),
    ]);
    return mauSo === 0 ? 1 : tuSo / mauSo;
  }

  static laDonDaHuy(status: string) {
    return TRANG_THAI_HUY.includes(status as never);
  }
}
