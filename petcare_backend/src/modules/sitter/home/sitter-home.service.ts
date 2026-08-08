import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { LOAI_RA_APP } from '../../bookings/booking-enums';
import {
  conGiuCho,
  hanNhanDonCua,
  mocGuiNguoiCham,
} from '../../bookings/booking-time';
import { SitterPenaltyService } from '../../bookings/sitter-penalty.service';
import { layNccCuaToi } from '../orders/sitter-guard';
import { dauKy, phanTramDoi } from '../../wallet/ky-thong-ke';
import { dauThangVn } from '../../wallet/wallet.service';
import { WalletLedgerService } from '../../wallet/wallet-ledger.service';

const SO_DON_CHO = 10;
const TRAN_DOC_DON_CHO = 50;
@Injectable()
export class SitterHomeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: WalletLedgerService,
    private readonly penalty: SitterPenaltyService,
  ) {}

  async dashboard(userId: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const vi = await this.ledger.layVi(ncc.id);
    const bayGio = new Date();
    const dauTuan = dauKy('week', bayGio);
    const dauThang = dauThangVn(bayGio);

    const [thuNhap, donCho, gioLam, hoSo, donThang, tyLeNhan] =
      await Promise.all([
        this.prisma.walletTransaction.findMany({
          where: {
            walletId: vi.id,
            amount: { gt: 0 },
            createdAt: { gte: dauKy('week', new Date(dauTuan.getTime() - 1)) },
          },
          select: { amount: true, createdAt: true },
        }),
        this.donChoTraLoi(ncc.id),
        this.gioLamTuan(ncc.id, dauTuan, bayGio),
        this.prisma.sitter.findUnique({
          where: { id: ncc.id },
          select: { ratingAvg: true, province: true },
        }),
        this.prisma.booking.findMany({
          where: { sitterId: ncc.id, scheduledAt: { gte: dauThang } },
          select: { status: true },
        }),
        this.penalty.tyLeNhanDon(ncc.id),
      ]);

    const tuanNay = thuNhap.filter((g) => g.createdAt >= dauTuan);
    const tuanTruoc = thuNhap.filter((g) => g.createdAt < dauTuan);
    const tongTuan = tuanNay.reduce((t, g) => t + g.amount, 0);

    return {
      location: hoSo?.province ?? '',
      weekEarnings: tongTuan,
      earningsChangePercent: phanTramDoi(
        tongTuan,
        tuanTruoc.reduce((t, g) => t + g.amount, 0),
      ),
      ordersThisWeek: tuanNay.length,
      workedThisWeek: gioLam,
      rating: hoSo?.ratingAvg ?? 0,
      acceptRate: Math.round(tyLeNhan * 100),
      completedThisMonth: donThang.filter((d) => d.status === 'COMPLETED')
        .length,
      pendingTotal: donCho.length,
      pendingOrders: donCho.slice(0, SO_DON_CHO),
    };
  }

  private async donChoTraLoi(sitterId: string) {
    const bayGio = Date.now();
    const ds = (
      await this.prisma.booking.findMany({
        where: { sitterId, status: 'PENDING' },
        orderBy: { scheduledAt: 'asc' },
        take: TRAN_DOC_DON_CHO,
        select: {
          id: true,
          code: true,
          scheduledAt: true,
          durationMinutes: true,
          totalPrice: true,
          specialNotes: true,
          pickupDistanceKm: true,
          paidAt: true,
          createdAt: true,
          owner: {
            select: { fullName: true, avatarUrl: true, createdAt: true },
          },
          service: { select: { name: true, type: true } },
          address: { select: { ward: true, province: true } },
          pets: { select: { pet: { select: { name: true, species: true } } } },
        },
      })
    )
      .filter((d) => conGiuCho(mocGuiNguoiCham(d), d.scheduledAt, bayGio))
      .sort((a, b) => hanNhanDonCua(a).getTime() - hanNhanDonCua(b).getTime());
    return ds.map((d) => ({
      id: d.id,
      bookingCode: d.code,
      ownerName: d.owner.fullName,
      ownerAvatar: d.owner.avatarUrl ?? '',
      ownerSince: d.owner.createdAt.toISOString(),
      ownerArea: d.address?.ward ?? d.address?.province ?? '',
      serviceName: d.service.name,
      serviceType: LOAI_RA_APP[d.service.type],
      durationMinutes: d.durationMinutes,
      distanceKm: d.pickupDistanceKm,
      startAt: d.scheduledAt.toISOString(),
      price: d.totalPrice ?? 0,
      note: d.specialNotes ?? '',
      sentAt: (d.paidAt ?? d.createdAt).toISOString(),
      respondDeadline: hanNhanDonCua(d).toISOString(),
      pets: d.pets.map((e) => ({
        name: e.pet.name,
        species: e.pet.species === 'CAT' ? 'cat' : 'dog',
      })),
    }));
  }

  private async gioLamTuan(sitterId: string, tu: Date, den: Date) {
    const dons = await this.prisma.booking.findMany({
      where: { sitterId, status: 'COMPLETED', endedAt: { gte: tu, lte: den } },
      select: { startedAt: true, endedAt: true, durationMinutes: true },
    });
    const phut = dons.reduce((tong, d) => {
      if (d.startedAt && d.endedAt) {
        return tong + (d.endedAt.getTime() - d.startedAt.getTime()) / 60_000;
      }
      return tong + (d.durationMinutes ?? 0);
    }, 0);
    return Math.round(phut / 60);
  }
}
