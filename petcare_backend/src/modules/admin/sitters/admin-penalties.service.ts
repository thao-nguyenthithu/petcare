import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { PenaltyKind, PenaltyStatus } from '../../../../generated/prisma/enums';
import { MOT_GIO_MS, MOT_NGAY_MS } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import {
  GIO_SUPPORT_SOAT,
  THANG_DEM_LAN_TAM_AN,
} from '../../bookings/sitter-penalty-rules';
import { SystemSettingsService } from '../system-settings.service';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { dungTrang, KetQuaTrang, kepTrang } from '../chung/phan-trang';
import { LocKyLuatDto } from './dto/loc-ky-luat.dto';

type UyTinNgan = {
  // Rỗng khi chưa đủ số đơn tối thiểu, KHÔNG lấp 0 (bộ luật mục 6)
  cancelRate: number | null;
  warningCount: number;
  hiddenTimesInWindow: number;
};

@Injectable()
export class AdminPenaltiesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  // Tỷ lệ huỷ và số cảnh cáo tính theo LÔ cho cả trang, đếm từng dòng là N+1
  private async uyTinTheoLo(sitterIds: string[]) {
    if (!sitterIds.length) return new Map<string, UyTinNgan>();
    const tuNgay = new Date(
      Date.now() - this.thamSo.so('penalty.window_days') * MOT_NGAY_MS,
    );
    // Mốc ẩn đếm trên cửa sổ SÁU THÁNG, khác hẳn cửa sổ của tỷ lệ huỷ (bộ luật mục 6)
    const tuLanAn = new Date(
      Date.now() - THANG_DEM_LAN_TAM_AN * 30 * MOT_NGAY_MS,
    );
    const [theoPhat, theoCanhCao, theoDon, theoLanAn] = await Promise.all([
      this.prisma.sitterPenalty.groupBy({
        by: ['sitterId'],
        where: {
          sitterId: { in: sitterIds },
          kind: PenaltyKind.CANCEL_RATE,
          status: { not: PenaltyStatus.WAIVED },
          createdAt: { gte: tuNgay },
        },
        _count: { _all: true },
      }),
      this.prisma.sitterPenalty.groupBy({
        by: ['sitterId'],
        where: {
          sitterId: { in: sitterIds },
          kind: PenaltyKind.WARNING,
          status: { not: PenaltyStatus.WAIVED },
          createdAt: { gte: tuNgay },
        },
        _count: { _all: true },
      }),
      this.prisma.booking.groupBy({
        by: ['sitterId'],
        where: {
          sitterId: { in: sitterIds },
          status: { notIn: ['PENDING', 'AWAITING_PAYMENT'] },
          createdAt: { gte: tuNgay },
        },
        _count: { _all: true },
      }),
      this.prisma.sitterPenalty.groupBy({
        by: ['sitterId'],
        where: {
          sitterId: { in: sitterIds },
          kind: PenaltyKind.HIDE,
          status: { not: PenaltyStatus.WAIVED },
          createdAt: { gte: tuLanAn },
        },
        _count: { _all: true },
      }),
    ]);

    const soDon = new Map(theoDon.map((d) => [d.sitterId, d._count._all]));
    const soLanAn = new Map(theoLanAn.map((d) => [d.sitterId, d._count._all]));
    const soCanhCao = new Map(
      theoCanhCao.map((d) => [d.sitterId, d._count._all]),
    );
    const toiThieu = this.thamSo.so('penalty.min_orders');
    const ket = new Map<string, UyTinNgan>();
    for (const id of sitterIds) {
      const tong = soDon.get(id) ?? 0;
      ket.set(id, {
        // Mẫu quá nhỏ thì tỷ lệ không nói lên gì, để trống chứ không nhận 0
        cancelRate: tong >= toiThieu ? 0 : null,
        warningCount: soCanhCao.get(id) ?? 0,
        hiddenTimesInWindow: soLanAn.get(id) ?? 0,
      });
    }
    for (const dong of theoPhat) {
      const muc = ket.get(dong.sitterId);
      if (!muc || muc.cancelRate === null) continue;
      const tong = soDon.get(dong.sitterId) ?? 0;
      muc.cancelRate = dong._count._all / tong;
    }
    return ket;
  }

  private dieuKien(loc: LocKyLuatDto): Prisma.SitterPenaltyWhereInput {
    const dieu: Prisma.SitterPenaltyWhereInput = {};
    if (loc.status) dieu.status = loc.status;
    if (loc.kind) dieu.kind = loc.kind;
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      dieu.sitter = {
        OR: [{ legalName: tim }, { user: { fullName: tim } }],
      };
    }
    return dieu;
  }

  async danhSach(loc: LocKyLuatDto): Promise<KetQuaTrang<unknown>> {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);
    const [total, ds] = await Promise.all([
      this.prisma.sitterPenalty.count({ where }),
      this.prisma.sitterPenalty.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          id: true,
          sitterId: true,
          kind: true,
          status: true,
          reason: true,
          createdAt: true,
          reviewedAt: true,
          booking: {
            select: { code: true, service: { select: { name: true } } },
          },
          sitter: {
            select: {
              legalName: true,
              hiddenUntil: true,
              hiddenCount: true,
              bannedAt: true,
              user: { select: { fullName: true } },
            },
          },
        },
      }),
    ]);

    const uyTin = await this.uyTinTheoLo([
      ...new Set(ds.map((d) => d.sitterId)),
    ]);
    const items = ds.map(({ booking, sitter, ...p }) => ({
      ...p,
      sitterName: sitter.user.fullName,
      legalName: sitter.legalName,
      bookingCode: booking?.code ?? null,
      serviceName: booking?.service.name ?? null,
      // Hạn soát chỉ có nghĩa với bản đang treo, bản đã kết luận thì bỏ trống
      reviewDeadline:
        p.status === PenaltyStatus.PENDING_REVIEW
          ? new Date(p.createdAt.getTime() + GIO_SUPPORT_SOAT * MOT_GIO_MS)
          : null,
      profile: {
        cancelRate: uyTin.get(p.sitterId)?.cancelRate ?? null,
        warningCount: uyTin.get(p.sitterId)?.warningCount ?? 0,
        hiddenTimesInWindow: uyTin.get(p.sitterId)?.hiddenTimesInWindow ?? 0,
        hiddenUntil: sitter.hiddenUntil,
        hiddenCount: sitter.hiddenCount,
        bannedAt: sitter.bannedAt,
      },
    }));
    return dungTrang(items, total, khoang);
  }

  async demTab() {
    const bayGio = new Date();
    const [theoTrangThai, dangAn] = await Promise.all([
      this.prisma.sitterPenalty.groupBy({
        by: ['status'],
        _count: { _all: true },
      }),
      this.prisma.sitter.count({
        where: { hiddenUntil: { gt: bayGio }, bannedAt: null },
      }),
    ]);
    const dem = (tt: PenaltyStatus) =>
      theoTrangThai.find((d) => d.status === tt)?._count._all ?? 0;
    return {
      pendingReview: dem(PenaltyStatus.PENDING_REVIEW),
      active: dem(PenaltyStatus.ACTIVE),
      waived: dem(PenaltyStatus.WAIVED),
      hidden: dangAn,
    };
  }

  private loiDaSoat() {
    return new NotFoundException({
      code: 'BAN_GHI_DA_SOAT',
      message: 'Bản ghi này đã được kết luận rồi',
    });
  }

  // Miễn một bản phải kéo theo bản sinh cùng lần huỷ đó, hai bản chung bookingId
  async soat(id: string, waived: boolean, note: string, adminId: string) {
    const ban = await this.prisma.sitterPenalty.findUnique({
      where: { id },
      select: {
        id: true,
        sitterId: true,
        bookingId: true,
        status: true,
        kind: true,
        booking: { select: { code: true } },
      },
    });
    if (!ban) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_BAN_GHI_PHAT',
        message: 'Không tìm thấy bản ghi kỷ luật này',
      });
    }
    if (ban.status !== PenaltyStatus.PENDING_REVIEW) throw this.loiDaSoat();

    const trangThai = waived ? PenaltyStatus.WAIVED : PenaltyStatus.ACTIVE;
    const cungLanHuy: Prisma.SitterPenaltyWhereInput = ban.bookingId
      ? { sitterId: ban.sitterId, bookingId: ban.bookingId }
      : { id: ban.id };

    await this.prisma.$transaction(async (db) => {
      const doi = await db.sitterPenalty.updateMany({
        where: { ...cungLanHuy, status: PenaltyStatus.PENDING_REVIEW },
        data: { status: trangThai, reviewedAt: new Date() },
      });
      // Không đổi được dòng nào mà vẫn ghi nhật ký là dựng chứng cho một lượt soát chưa xảy ra
      if (doi.count === 0) throw this.loiDaSoat();
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: waived ? 'MIEN_PHAT_NCC' : 'GIU_PHAT_NCC',
          targetType: 'PENALTY',
          targetId: ban.id,
          targetCode: ban.booking?.code ?? null,
          reason: note,
          oldValue: PenaltyStatus.PENDING_REVIEW,
          newValue: trangThai,
        },
        db,
      );
    });
    return { id: ban.id, status: trangThai };
  }

  // Bản treo quá hạn soát thì thành áp chính thức, KHÔNG tự miễn (bộ luật mục 6)
  async quaHanSoat(bayGio: Date = new Date()) {
    const han = new Date(bayGio.getTime() - GIO_SUPPORT_SOAT * MOT_GIO_MS);
    return this.prisma.sitterPenalty.count({
      where: {
        status: PenaltyStatus.PENDING_REVIEW,
        createdAt: { lt: han },
      },
    });
  }

  // Số lần tạm ẩn trong sáu tháng, con số quyết định khoá hẳn (bộ luật mục 6)
  async soLanAnTrongCuaSo(sitterId: string, thangCuaSo: number) {
    const tu = new Date(Date.now() - thangCuaSo * 30 * MOT_NGAY_MS);
    return this.prisma.sitterPenalty.count({
      where: {
        sitterId,
        kind: PenaltyKind.HIDE,
        status: { not: PenaltyStatus.WAIVED },
        createdAt: { gte: tu },
      },
    });
  }
}
